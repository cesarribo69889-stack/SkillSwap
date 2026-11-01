package com.skillswap.repository;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.ListenerRegistration;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.firestore.WriteBatch;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.firebase.FirestoreCollections;
import com.skillswap.model.AppNotification;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/** Centro interno de notificaciones (coleccion "notifications"). */
public class NotificationRepository {

    private static NotificationRepository instance;

    public static synchronized NotificationRepository get() {
        if (instance == null) instance = new NotificationRepository();
        return instance;
    }

    private NotificationRepository() {
    }

    /** Crea una notificacion interna para un usuario. */
    public void push(String userId, String type, String title, String body, String referenceId) {
        if (userId == null || userId.isEmpty()) return;
        AppNotification n = new AppNotification(userId, type, title, body, referenceId);
        DocumentReference ref = FirestoreCollections.notifications().document();
        n.setId(ref.getId());
        ref.set(n);
    }

    /** Escucha en tiempo real las notificaciones del usuario. */
    public ListenerRegistration listen(String userId, final RepoCallback<List<AppNotification>> callback) {
        return FirestoreCollections.notifications()
                .whereEqualTo("userId", userId)
                .limit(100)
                .addSnapshotListener(new EventListener<QuerySnapshot>() {
                    @Override
                    public void onEvent(@Nullable QuerySnapshot snapshots,
                                        @Nullable FirebaseFirestoreException e) {
                        if (e != null) {
                            callback.onError(FirebaseErrors.translate(e));
                            return;
                        }
                        List<AppNotification> list = new ArrayList<>();
                        if (snapshots != null) {
                            for (QueryDocumentSnapshot doc : snapshots) {
                                AppNotification n = doc.toObject(AppNotification.class);
                                n.setId(doc.getId());
                                list.add(n);
                            }
                        }
                        Collections.sort(list, new Comparator<AppNotification>() {
                            @Override
                            public int compare(AppNotification a, AppNotification b) {
                                return Long.compare(b.getCreatedAt(), a.getCreatedAt());
                            }
                        });
                        callback.onSuccess(list);
                    }
                });
    }

    public void markRead(String notificationId) {
        if (notificationId == null || notificationId.isEmpty()) return;
        FirestoreCollections.notifications().document(notificationId).update("read", true);
    }

    public void markAllRead(final List<AppNotification> list) {
        if (list == null || list.isEmpty()) return;
        WriteBatch batch = FirebaseManager.db().batch();
        int count = 0;
        for (AppNotification n : list) {
            if (n.isRead()) continue;
            batch.update(FirestoreCollections.notifications().document(n.getId()), "read", true);
            count++;
            if (count >= 400) break;
        }
        if (count > 0) batch.commit();
    }

    public void delete(String notificationId, @NonNull final RepoCallback<Boolean> callback) {
        FirestoreCollections.notifications().document(notificationId).delete()
                .addOnSuccessListener(unused -> callback.onSuccess(Boolean.TRUE))
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }
}
