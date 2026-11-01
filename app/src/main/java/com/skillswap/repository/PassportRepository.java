package com.skillswap.repository;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.ListenerRegistration;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.firestore.Transaction;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.firebase.FirestoreCollections;
import com.skillswap.model.PassportEntry;
import com.skillswap.utils.Constants;
import com.skillswap.utils.SkillCatalog;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * INNOVACION 2 - Pasaporte de Habilidades (coleccion "skillPassport").
 * Registra actividad real dentro de SkillSwap.
 * NO es una certificacion academica.
 */
public class PassportRepository {

    private static PassportRepository instance;

    public static synchronized PassportRepository get() {
        if (instance == null) instance = new PassportRepository();
        return instance;
    }

    private PassportRepository() {
    }

    public static String entryId(String uid, String skill, String role) {
        return uid + "__" + SkillCatalog.slug(skill) + "__" + role;
    }

    /** Suma una actividad al pasaporte (crea la entrada si no existe). */
    public void registerActivity(final String uid, final String skillName, final String role) {
        if (uid == null || uid.isEmpty() || skillName == null || skillName.trim().isEmpty()) return;

        final String id = entryId(uid, skillName, role);
        final DocumentReference ref = FirestoreCollections.passport().document(id);

        FirebaseManager.db().runTransaction(new Transaction.Function<Void>() {
            @Override
            public Void apply(@NonNull Transaction transaction)
                    throws com.google.firebase.firestore.FirebaseFirestoreException {
                DocumentSnapshot snap = transaction.get(ref);
                PassportEntry entry;
                if (snap.exists()) {
                    entry = snap.toObject(PassportEntry.class);
                    if (entry == null) entry = new PassportEntry();
                } else {
                    entry = new PassportEntry();
                    entry.setCreatedAt(System.currentTimeMillis());
                }
                entry.setId(id);
                entry.setUserId(uid);
                entry.setSkillName(skillName);
                entry.setCategory(SkillCatalog.categoryOf(skillName));
                entry.setRole(role);
                entry.setExchangesCount(entry.getExchangesCount() + 1);
                entry.setSessionsCount(entry.getSessionsCount() + 1);
                entry.setLevel(levelFor(entry.getExchangesCount()));
                entry.setProgress(progressFor(entry.getExchangesCount()));
                entry.setLastActivity(System.currentTimeMillis());
                transaction.set(ref, entry);
                return null;
            }
        });
    }

    /** Actualiza el promedio de calificacion de una habilidad ensenada. */
    public void registerRating(final String uid, final String skillName, final float stars) {
        if (uid == null || skillName == null || skillName.trim().isEmpty()) return;
        final String id = entryId(uid, skillName, PassportEntry.ROLE_TAUGHT);
        final DocumentReference ref = FirestoreCollections.passport().document(id);

        FirebaseManager.db().runTransaction(new Transaction.Function<Void>() {
            @Override
            public Void apply(@NonNull Transaction transaction)
                    throws com.google.firebase.firestore.FirebaseFirestoreException {
                DocumentSnapshot snap = transaction.get(ref);
                if (!snap.exists()) return null;
                PassportEntry entry = snap.toObject(PassportEntry.class);
                if (entry == null) return null;
                double avg = entry.getAverageRating();
                int count = entry.getRatingsCount();
                double newAvg = ((avg * count) + stars) / (count + 1);
                entry.setAverageRating(Math.round(newAvg * 100d) / 100d);
                entry.setRatingsCount(count + 1);
                transaction.set(ref, entry);
                return null;
            }
        });
    }

    /** Entradas del pasaporte de un usuario, en tiempo real. */
    public ListenerRegistration listen(String uid, final RepoCallback<List<PassportEntry>> callback) {
        return FirestoreCollections.passport()
                .whereEqualTo("userId", uid)
                .limit(200)
                .addSnapshotListener(new EventListener<QuerySnapshot>() {
                    @Override
                    public void onEvent(@Nullable QuerySnapshot snapshots,
                                        @Nullable FirebaseFirestoreException e) {
                        if (e != null) {
                            callback.onError(FirebaseErrors.translate(e));
                            return;
                        }
                        List<PassportEntry> list = new ArrayList<>();
                        if (snapshots != null) {
                            for (QueryDocumentSnapshot doc : snapshots) {
                                PassportEntry p = doc.toObject(PassportEntry.class);
                                p.setId(doc.getId());
                                list.add(p);
                            }
                        }
                        Collections.sort(list, new Comparator<PassportEntry>() {
                            @Override
                            public int compare(PassportEntry a, PassportEntry b) {
                                int byCount = Integer.compare(b.getExchangesCount(), a.getExchangesCount());
                                if (byCount != 0) return byCount;
                                return Long.compare(b.getLastActivity(), a.getLastActivity());
                            }
                        });
                        callback.onSuccess(list);
                    }
                });
    }

    public static String levelFor(int exchanges) {
        if (exchanges >= 5) return Constants.LEVEL_ADVANCED;
        if (exchanges >= 2) return Constants.LEVEL_INTERMEDIATE;
        return Constants.LEVEL_BASIC;
    }

    public static int progressFor(int exchanges) {
        return Math.min(100, exchanges * 20);
    }
}
