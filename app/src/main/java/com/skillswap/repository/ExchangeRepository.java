package com.skillswap.repository;

import androidx.annotation.Nullable;

import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.ListenerRegistration;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.skillswap.firebase.FirestoreCollections;
import com.skillswap.model.AppNotification;
import com.skillswap.model.Chat;
import com.skillswap.model.Exchange;
import com.skillswap.model.ExchangeRequest;
import com.skillswap.model.PassportEntry;
import com.skillswap.utils.Constants;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Intercambios activos e historial (coleccion "exchanges"). */
public class ExchangeRepository {

    private static ExchangeRepository instance;

    public static synchronized ExchangeRepository get() {
        if (instance == null) instance = new ExchangeRepository();
        return instance;
    }

    private ExchangeRepository() {
    }

    /**
     * Crea el intercambio a partir de una solicitud aceptada y habilita el chat.
     * A = quien envio la solicitud, B = quien la acepto.
     */
    public void createFromRequest(final ExchangeRequest req, final RepoCallback<Exchange> callback) {
        final DocumentReference ref = FirestoreCollections.exchanges().document();
        final Exchange ex = new Exchange();
        ex.setId(ref.getId());
        ex.setRequestId(req.getId());
        ex.setUserAId(req.getFromUserId());
        ex.setUserAName(req.getFromUserName());
        ex.setUserAPhoto(req.getFromUserPhoto());
        ex.setUserBId(req.getToUserId());
        ex.setUserBName(req.getToUserName());
        ex.setUserBPhoto(req.getToUserPhoto());
        ex.setParticipants(new ArrayList<>(Arrays.asList(req.getFromUserId(), req.getToUserId())));
        ex.setSkillFromA(req.getSkillOffered());
        ex.setSkillFromB(req.getSkillWanted());
        ex.setModality(req.getModality());
        ex.setSchedule(req.getSchedule());
        ex.setStatus(Exchange.STATUS_UPCOMING);
        ex.setProgress(0);
        ex.setStartDate(System.currentTimeMillis());
        ex.setCreatedAt(System.currentTimeMillis());
        ex.setUpdatedAt(ex.getCreatedAt());

        ref.set(ex)
                .addOnSuccessListener(unused -> ChatRepository.get().createChat(ex, new RepoCallback<Chat>() {
                    @Override
                    public void onSuccess(Chat chat) {
                        ex.setChatId(chat.getId());
                        ref.update("chatId", chat.getId());
                        callback.onSuccess(ex);
                    }

                    @Override
                    public void onError(String message) {
                        // El intercambio existe aunque el chat falle: se reintenta al abrirlo.
                        callback.onSuccess(ex);
                    }
                }))
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    /** Todos los intercambios del usuario, en tiempo real. */
    public ListenerRegistration listenByUser(String uid, final RepoCallback<List<Exchange>> callback) {
        return FirestoreCollections.exchanges()
                .whereArrayContains("participants", uid)
                .limit(100)
                .addSnapshotListener(new EventListener<QuerySnapshot>() {
                    @Override
                    public void onEvent(@Nullable QuerySnapshot snapshots,
                                        @Nullable FirebaseFirestoreException e) {
                        if (e != null) {
                            callback.onError(FirebaseErrors.translate(e));
                            return;
                        }
                        List<Exchange> list = new ArrayList<>();
                        if (snapshots != null) {
                            for (QueryDocumentSnapshot doc : snapshots) {
                                Exchange x = doc.toObject(Exchange.class);
                                x.setId(doc.getId());
                                list.add(x);
                            }
                        }
                        Collections.sort(list, new Comparator<Exchange>() {
                            @Override
                            public int compare(Exchange a, Exchange b) {
                                return Long.compare(b.getUpdatedAt(), a.getUpdatedAt());
                            }
                        });
                        callback.onSuccess(list);
                    }
                });
    }

    public ListenerRegistration listenById(String id, final RepoCallback<Exchange> callback) {
        return FirestoreCollections.exchanges().document(id)
                .addSnapshotListener((snapshot, e) -> {
                    if (e != null) {
                        callback.onError(FirebaseErrors.translate(e));
                        return;
                    }
                    if (snapshot == null || !snapshot.exists()) {
                        callback.onError("El intercambio ya no existe");
                        return;
                    }
                    Exchange x = snapshot.toObject(Exchange.class);
                    if (x != null) x.setId(snapshot.getId());
                    callback.onSuccess(x);
                });
    }

    public void fetchById(String id, final RepoCallback<Exchange> callback) {
        FirestoreCollections.exchanges().document(id).get()
                .addOnSuccessListener(doc -> {
                    if (!doc.exists()) {
                        callback.onError("El intercambio ya no existe");
                        return;
                    }
                    Exchange x = doc.toObject(Exchange.class);
                    if (x != null) x.setId(doc.getId());
                    callback.onSuccess(x);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    /** Avanza el progreso y marca el intercambio como EN PROCESO. */
    public void updateProgress(final Exchange ex, int sessionsDone, final RepoCallback<Boolean> callback) {
        int total = Math.max(1, ex.getSessionsTotal());
        int done = Math.max(0, Math.min(total, sessionsDone));
        int progress = (int) Math.round((done * 100.0) / total);

        Map<String, Object> data = new HashMap<>();
        data.put("sessionsDone", done);
        data.put("progress", progress);
        data.put("status", progress >= 100 ? Exchange.STATUS_IN_PROGRESS : Exchange.STATUS_IN_PROGRESS);
        data.put("updatedAt", System.currentTimeMillis());

        FirestoreCollections.exchanges().document(ex.getId())
                .update(data)
                .addOnSuccessListener(unused -> callback.onSuccess(Boolean.TRUE))
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    public void start(final Exchange ex, final RepoCallback<Boolean> callback) {
        Map<String, Object> data = new HashMap<>();
        data.put("status", Exchange.STATUS_IN_PROGRESS);
        data.put("updatedAt", System.currentTimeMillis());
        FirestoreCollections.exchanges().document(ex.getId())
                .update(data)
                .addOnSuccessListener(unused -> callback.onSuccess(Boolean.TRUE))
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    /**
     * Marca el intercambio como completado por el usuario indicado.
     * Cuando ambos lo confirman se cierra, se suman SkillPoints y se
     * actualiza el Pasaporte de Habilidades.
     */
    public void markCompleted(final Exchange ex, final String uid, final RepoCallback<Exchange> callback) {
        if (ex == null) {
            callback.onError("Intercambio no válido");
            return;
        }
        final boolean isA = ex.getUserAId().equals(uid);
        final boolean otherDone = isA ? ex.isCompletedByB() : ex.isCompletedByA();

        Map<String, Object> data = new HashMap<>();
        data.put(isA ? "completedByA" : "completedByB", true);
        data.put("updatedAt", System.currentTimeMillis());

        if (otherDone) {
            data.put("status", Exchange.STATUS_COMPLETED);
            data.put("progress", 100);
            data.put("endDate", System.currentTimeMillis());
        } else {
            data.put("status", Exchange.STATUS_IN_PROGRESS);
        }

        FirestoreCollections.exchanges().document(ex.getId())
                .update(data)
                .addOnSuccessListener(unused -> {
                    if (isA) ex.setCompletedByA(true);
                    else ex.setCompletedByB(true);

                    if (otherDone) {
                        ex.setStatus(Exchange.STATUS_COMPLETED);
                        ex.setProgress(100);
                        onExchangeClosed(ex);
                    } else {
                        ex.setStatus(Exchange.STATUS_IN_PROGRESS);
                        NotificationRepository.get().push(
                                ex.getPartnerId(uid),
                                AppNotification.TYPE_EXCHANGE_COMPLETED,
                                "Tu compañero marcó el intercambio como terminado",
                                "Confirma para cerrarlo y calificar la experiencia",
                                ex.getId());
                    }
                    callback.onSuccess(ex);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    /** Efectos secundarios al cerrar un intercambio. */
    private void onExchangeClosed(Exchange ex) {
        UserRepository.get().incrementExchanges(ex.getUserAId());
        UserRepository.get().incrementExchanges(ex.getUserBId());

        GamificationRepository.get().award(ex.getUserAId(),
                Constants.POINTS_EXCHANGE_COMPLETED, "Intercambio completado", ex.getId());
        GamificationRepository.get().award(ex.getUserBId(),
                Constants.POINTS_EXCHANGE_COMPLETED, "Intercambio completado", ex.getId());

        // Pasaporte: lo que cada uno enseno y aprendio.
        PassportRepository p = PassportRepository.get();
        p.registerActivity(ex.getUserAId(), ex.getSkillFromA(), PassportEntry.ROLE_TAUGHT);
        p.registerActivity(ex.getUserAId(), ex.getSkillFromB(), PassportEntry.ROLE_LEARNED);
        p.registerActivity(ex.getUserBId(), ex.getSkillFromB(), PassportEntry.ROLE_TAUGHT);
        p.registerActivity(ex.getUserBId(), ex.getSkillFromA(), PassportEntry.ROLE_LEARNED);

        GamificationRepository.get().unlockBadge(ex.getUserAId(),
                com.skillswap.utils.GamificationEngine.BADGE_FIRST_SWAP);
        GamificationRepository.get().unlockBadge(ex.getUserBId(),
                com.skillswap.utils.GamificationEngine.BADGE_FIRST_SWAP);

        NotificationRepository.get().push(ex.getUserAId(),
                AppNotification.TYPE_EXCHANGE_COMPLETED,
                "Intercambio completado 🎉",
                "Ganaste " + Constants.POINTS_EXCHANGE_COMPLETED + " SkillPoints. Califica a "
                        + ex.getUserBName(), ex.getId());
        NotificationRepository.get().push(ex.getUserBId(),
                AppNotification.TYPE_EXCHANGE_COMPLETED,
                "Intercambio completado 🎉",
                "Ganaste " + Constants.POINTS_EXCHANGE_COMPLETED + " SkillPoints. Califica a "
                        + ex.getUserAName(), ex.getId());
    }

    public void markRated(String exchangeId, boolean isA) {
        FirestoreCollections.exchanges().document(exchangeId)
                .update(isA ? "ratedByA" : "ratedByB", true);
    }

    public void attachContract(String exchangeId, String contractId, int sessions) {
        Map<String, Object> data = new HashMap<>();
        data.put("contractId", contractId);
        data.put("sessionsTotal", sessions);
        data.put("updatedAt", System.currentTimeMillis());
        FirestoreCollections.exchanges().document(exchangeId).update(data);
    }

    public void cancel(String exchangeId, final RepoCallback<Boolean> callback) {
        Map<String, Object> data = new HashMap<>();
        data.put("status", Exchange.STATUS_CANCELLED);
        data.put("updatedAt", System.currentTimeMillis());
        FirestoreCollections.exchanges().document(exchangeId).update(data)
                .addOnSuccessListener(unused -> callback.onSuccess(Boolean.TRUE))
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }
}
