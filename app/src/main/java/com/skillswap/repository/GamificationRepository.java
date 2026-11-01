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
import com.google.firebase.firestore.SetOptions;
import com.google.firebase.firestore.Transaction;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.firebase.FirestoreCollections;
import com.skillswap.model.AppNotification;
import com.skillswap.model.Badge;
import com.skillswap.model.PointEntry;
import com.skillswap.model.SkillPointsAccount;
import com.skillswap.utils.GamificationEngine;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * INNOVACION 4 - SkillPoints e insignias.
 * Los SkillPoints NO representan dinero.
 */
public class GamificationRepository {

    private static GamificationRepository instance;

    public static synchronized GamificationRepository get() {
        if (instance == null) instance = new GamificationRepository();
        return instance;
    }

    private GamificationRepository() {
    }

    public void ensureAccount(final String uid) {
        if (uid == null || uid.isEmpty()) return;
        final DocumentReference ref = FirestoreCollections.skillPoints().document(uid);
        ref.get().addOnSuccessListener(doc -> {
            if (!doc.exists()) ref.set(new SkillPointsAccount(uid));
        });
    }

    /** Suma SkillPoints y registra el movimiento en el historial. */
    public void award(final String uid, final int points, final String reason, final String referenceId) {
        if (uid == null || uid.isEmpty() || points == 0) return;
        final DocumentReference ref = FirestoreCollections.skillPoints().document(uid);

        FirebaseManager.db().runTransaction(new Transaction.Function<SkillPointsAccount>() {
            @Override
            public SkillPointsAccount apply(@NonNull Transaction transaction)
                    throws com.google.firebase.firestore.FirebaseFirestoreException {
                DocumentSnapshot snap = transaction.get(ref);
                SkillPointsAccount account = snap.exists()
                        ? snap.toObject(SkillPointsAccount.class)
                        : new SkillPointsAccount(uid);
                if (account == null) account = new SkillPointsAccount(uid);
                account.setUserId(uid);
                account = GamificationEngine.applyPoints(account, points);
                transaction.set(ref, account);
                return account;
            }
        }).addOnSuccessListener(account -> {
            PointEntry entry = new PointEntry(uid, points, reason, referenceId);
            DocumentReference hRef = FirestoreCollections.pointsHistory(uid).document();
            entry.setId(hRef.getId());
            hRef.set(entry);

            Map<String, Object> userData = new HashMap<>();
            userData.put("skillPoints", account.getPoints());
            userData.put("gamificationLevel", account.getLevel());
            FirestoreCollections.user(uid).set(userData, SetOptions.merge());

            if (GamificationEngine.LEVEL_MASTER.equals(account.getLevel())) {
                unlockBadge(uid, GamificationEngine.BADGE_MASTER);
            }
        });
    }

    public ListenerRegistration listenAccount(String uid, final RepoCallback<SkillPointsAccount> callback) {
        return FirestoreCollections.skillPoints().document(uid)
                .addSnapshotListener((snapshot, e) -> {
                    if (e != null) {
                        callback.onError(FirebaseErrors.translate(e));
                        return;
                    }
                    SkillPointsAccount acc = (snapshot != null && snapshot.exists())
                            ? snapshot.toObject(SkillPointsAccount.class)
                            : new SkillPointsAccount(uid);
                    callback.onSuccess(acc);
                });
    }

    public void fetchHistory(String uid, final RepoCallback<List<PointEntry>> callback) {
        FirestoreCollections.pointsHistory(uid).limit(60).get()
                .addOnSuccessListener(snapshots -> {
                    List<PointEntry> list = new ArrayList<>();
                    for (QueryDocumentSnapshot doc : snapshots) {
                        PointEntry p = doc.toObject(PointEntry.class);
                        p.setId(doc.getId());
                        list.add(p);
                    }
                    Collections.sort(list, new Comparator<PointEntry>() {
                        @Override
                        public int compare(PointEntry a, PointEntry b) {
                            return Long.compare(b.getCreatedAt(), a.getCreatedAt());
                        }
                    });
                    callback.onSuccess(list);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    /** Desbloquea una insignia si el usuario aun no la tiene. */
    public void unlockBadge(final String uid, final String code) {
        if (uid == null || uid.isEmpty() || code == null) return;
        final Badge template = GamificationEngine.findInCatalog(code);
        if (template == null) return;

        final String id = uid + "__" + code;
        final DocumentReference ref = FirestoreCollections.badges().document(id);
        ref.get().addOnSuccessListener(doc -> {
            if (doc.exists() && Boolean.TRUE.equals(doc.getBoolean("unlocked"))) return;
            template.setId(id);
            template.setUserId(uid);
            template.setUnlocked(true);
            template.setUnlockedAt(System.currentTimeMillis());
            ref.set(template);

            NotificationRepository.get().push(uid, AppNotification.TYPE_BADGE,
                    "Nueva insignia: " + template.getName(),
                    template.getDescription(), id);
        });
    }

    /** Insignias del usuario mezcladas con el catalogo completo. */
    public ListenerRegistration listenBadges(final String uid, final RepoCallback<List<Badge>> callback) {
        return FirestoreCollections.badges()
                .whereEqualTo("userId", uid)
                .addSnapshotListener(new EventListener<QuerySnapshot>() {
                    @Override
                    public void onEvent(@Nullable QuerySnapshot snapshots,
                                        @Nullable FirebaseFirestoreException e) {
                        if (e != null) {
                            callback.onError(FirebaseErrors.translate(e));
                            return;
                        }
                        Map<String, Badge> unlocked = new HashMap<>();
                        if (snapshots != null) {
                            for (QueryDocumentSnapshot doc : snapshots) {
                                Badge b = doc.toObject(Badge.class);
                                b.setId(doc.getId());
                                unlocked.put(b.getCode(), b);
                            }
                        }
                        List<Badge> all = new ArrayList<>();
                        for (Badge template : GamificationEngine.catalog()) {
                            Badge got = unlocked.get(template.getCode());
                            all.add(got != null ? got : template);
                        }
                        callback.onSuccess(all);
                    }
                });
    }
}
