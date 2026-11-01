#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
R="$J/repository"
mkdir -p "$R"

# ============================================================ RatingRepository
cat > "$R/RatingRepository.java" <<'EOF'
package com.skillswap.repository;

import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.skillswap.firebase.FirestoreCollections;
import com.skillswap.model.AppNotification;
import com.skillswap.model.Exchange;
import com.skillswap.model.Rating;
import com.skillswap.model.User;
import com.skillswap.utils.Constants;
import com.skillswap.utils.GamificationEngine;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/** Calificaciones entre estudiantes (coleccion "ratings"). */
public class RatingRepository {

    private static RatingRepository instance;

    public static synchronized RatingRepository get() {
        if (instance == null) instance = new RatingRepository();
        return instance;
    }

    private RatingRepository() {
    }

    /** Registra la calificacion y actualiza la reputacion del calificado. */
    public void submit(final User me, final Exchange exchange, final Rating rating,
                       final RepoCallback<Rating> callback) {
        if (me == null || exchange == null) {
            callback.onError("Intercambio no disponible");
            return;
        }
        if (rating.getStars() <= 0) {
            callback.onError("Selecciona al menos una estrella");
            return;
        }

        final String toUserId = exchange.getPartnerId(me.getUid());
        DocumentReference ref = FirestoreCollections.ratings().document();
        rating.setId(ref.getId());
        rating.setExchangeId(exchange.getId());
        rating.setFromUserId(me.getUid());
        rating.setFromUserName(me.getFullName());
        rating.setFromUserPhoto(me.getPhotoUrl());
        rating.setToUserId(toUserId);
        rating.setSkillTaught(exchange.getSkillILearn(me.getUid()));
        rating.setCreatedAt(System.currentTimeMillis());

        final float overall = rating.getOverall();

        ref.set(rating)
                .addOnSuccessListener(unused -> {
                    UserRepository.get().applyRating(toUserId, overall, new RepoCallback<Boolean>() {
                        @Override
                        public void onSuccess(Boolean data) {
                        }

                        @Override
                        public void onError(String message) {
                        }
                    });

                    ExchangeRepository.get().markRated(exchange.getId(),
                            exchange.getUserAId().equals(me.getUid()));

                    if (overall >= 4f) {
                        GamificationRepository.get().award(toUserId,
                                Constants.POINTS_GOOD_RATING, "Buena calificación", exchange.getId());
                    }
                    if (rating.getStars() >= 5f) {
                        GamificationRepository.get().unlockBadge(toUserId,
                                GamificationEngine.BADGE_FIVE_STARS);
                    }

                    NotificationRepository.get().push(toUserId,
                            AppNotification.TYPE_NEW_RATING,
                            "Recibiste una calificación",
                            me.getShortName() + " te calificó con "
                                    + String.format(java.util.Locale.getDefault(), "%.1f", overall) + " ⭐",
                            exchange.getId());

                    callback.onSuccess(rating);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    /** Calificaciones recibidas por un usuario. */
    public void fetchReceived(String uid, final RepoCallback<List<Rating>> callback) {
        FirestoreCollections.ratings()
                .whereEqualTo("toUserId", uid)
                .limit(100)
                .get()
                .addOnSuccessListener(snapshots -> {
                    List<Rating> list = new ArrayList<>();
                    for (QueryDocumentSnapshot doc : snapshots) {
                        Rating r = doc.toObject(Rating.class);
                        r.setId(doc.getId());
                        list.add(r);
                    }
                    Collections.sort(list, new Comparator<Rating>() {
                        @Override
                        public int compare(Rating a, Rating b) {
                            return Long.compare(b.getCreatedAt(), a.getCreatedAt());
                        }
                    });
                    callback.onSuccess(list);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    /** Calificacion que el usuario dio en un intercambio concreto. */
    public void fetchForExchange(String exchangeId, String fromUserId,
                                 final RepoCallback<Rating> callback) {
        FirestoreCollections.ratings()
                .whereEqualTo("exchangeId", exchangeId)
                .whereEqualTo("fromUserId", fromUserId)
                .limit(1)
                .get()
                .addOnSuccessListener(snapshots -> {
                    if (snapshots.isEmpty()) {
                        callback.onSuccess(null);
                        return;
                    }
                    Rating r = snapshots.getDocuments().get(0).toObject(Rating.class);
                    if (r != null) r.setId(snapshots.getDocuments().get(0).getId());
                    callback.onSuccess(r);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }
}
EOF

# ============================================================ PassportRepository
cat > "$R/PassportRepository.java" <<'EOF'
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
            public Void apply(@NonNull Transaction transaction) {
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
            public Void apply(@NonNull Transaction transaction) {
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
EOF

# ============================================================ GamificationRepository
cat > "$R/GamificationRepository.java" <<'EOF'
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
            public SkillPointsAccount apply(@NonNull Transaction transaction) {
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
EOF

echo "Repositorios (ratings/pasaporte/gamificacion) generados."
