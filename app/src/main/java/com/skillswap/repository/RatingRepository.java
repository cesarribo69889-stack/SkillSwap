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
