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
import com.skillswap.model.Exchange;
import com.skillswap.model.ExchangeRequest;
import com.skillswap.model.User;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Solicitudes de intercambio (coleccion "exchangeRequests"). */
public class ExchangeRequestRepository {

    private static ExchangeRequestRepository instance;

    public static synchronized ExchangeRequestRepository get() {
        if (instance == null) instance = new ExchangeRequestRepository();
        return instance;
    }

    private ExchangeRequestRepository() {
    }

    /** Envia una solicitud de intercambio. */
    public void send(final User me, final User target, final String skillWanted,
                     final String skillOffered, final String message, final String modality,
                     final String schedule, final int matchScore,
                     final RepoCallback<ExchangeRequest> callback) {

        if (me == null || target == null) {
            callback.onError("Perfil no disponible");
            return;
        }
        if (skillWanted == null || skillWanted.trim().isEmpty()) {
            callback.onError("Elige la habilidad que quieres aprender");
            return;
        }
        if (skillOffered == null || skillOffered.trim().isEmpty()) {
            callback.onError("Elige la habilidad que puedes enseñar");
            return;
        }

        final ExchangeRequest req = new ExchangeRequest();
        DocumentReference ref = FirestoreCollections.requests().document();
        req.setId(ref.getId());
        req.setFromUserId(me.getUid());
        req.setFromUserName(me.getFullName());
        req.setFromUserPhoto(me.getPhotoUrl());
        req.setToUserId(target.getUid());
        req.setToUserName(target.getFullName());
        req.setToUserPhoto(target.getPhotoUrl());
        req.setParticipants(new ArrayList<>(Arrays.asList(me.getUid(), target.getUid())));
        req.setSkillWanted(skillWanted);
        req.setSkillOffered(skillOffered);
        req.setMessage(message == null ? "" : message.trim());
        req.setModality(modality == null ? "" : modality);
        req.setSchedule(schedule == null ? "" : schedule);
        req.setMatchScore(matchScore);
        req.setStatus(ExchangeRequest.STATUS_PENDING);
        req.setCreatedAt(System.currentTimeMillis());
        req.setUpdatedAt(req.getCreatedAt());

        ref.set(req)
                .addOnSuccessListener(unused -> {
                    NotificationRepository.get().push(
                            target.getUid(),
                            AppNotification.TYPE_NEW_REQUEST,
                            "Nueva solicitud de intercambio",
                            me.getShortName() + " quiere aprender " + skillWanted
                                    + " y te ofrece " + skillOffered,
                            req.getId());
                    callback.onSuccess(req);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    /** Solicitudes recibidas, en tiempo real. */
    public ListenerRegistration listenReceived(String uid, RepoCallback<List<ExchangeRequest>> cb) {
        return listen("toUserId", uid, cb);
    }

    /** Solicitudes enviadas, en tiempo real. */
    public ListenerRegistration listenSent(String uid, RepoCallback<List<ExchangeRequest>> cb) {
        return listen("fromUserId", uid, cb);
    }

    /**
     * Se consulta por "participants" y NO por toUserId/fromUserId.
     *
     * La regla de seguridad autoriza con `uid() in resource.data.participants`.
     * Firestore solo acepta una consulta si puede demostrar, mirando los
     * filtros, que todos los resultados seran legibles: al filtrar por otro
     * campo rechazaba la consulta entera con PERMISSION_DENIED y la pantalla
     * salia siempre vacia. Filtrando por el mismo campo que usa la regla, la
     * consulta es valida; el reparto entre recibidas y enviadas se hace
     * despues en memoria, que son como mucho 100 documentos.
     */
    private ListenerRegistration listen(final String field, final String uid,
                                        final RepoCallback<List<ExchangeRequest>> callback) {
        return FirestoreCollections.requests()
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
                        List<ExchangeRequest> list = new ArrayList<>();
                        if (snapshots != null) {
                            for (QueryDocumentSnapshot doc : snapshots) {
                                ExchangeRequest r = doc.toObject(ExchangeRequest.class);
                                r.setId(doc.getId());
                                // Reparto en memoria: "toUserId" son las
                                // recibidas y "fromUserId" las enviadas.
                                String valor = "toUserId".equals(field)
                                        ? r.getToUserId() : r.getFromUserId();
                                if (uid.equals(valor)) list.add(r);
                            }
                        }
                        Collections.sort(list, new Comparator<ExchangeRequest>() {
                            @Override
                            public int compare(ExchangeRequest a, ExchangeRequest b) {
                                return Long.compare(b.getCreatedAt(), a.getCreatedAt());
                            }
                        });
                        callback.onSuccess(list);
                    }
                });
    }

    /** Acepta la solicitud: crea el intercambio y habilita el chat. */
    public void accept(final ExchangeRequest request, final RepoCallback<Exchange> callback) {
        if (request == null) {
            callback.onError("Solicitud no válida");
            return;
        }
        if (!ExchangeRequest.STATUS_PENDING.equals(request.getStatus())) {
            callback.onError("Esta solicitud ya fue respondida");
            return;
        }

        ExchangeRepository.get().createFromRequest(request, new RepoCallback<Exchange>() {
            @Override
            public void onSuccess(final Exchange exchange) {
                Map<String, Object> data = new HashMap<>();
                data.put("status", ExchangeRequest.STATUS_ACCEPTED);
                data.put("exchangeId", exchange.getId());
                data.put("updatedAt", System.currentTimeMillis());

                FirestoreCollections.requests().document(request.getId())
                        .update(data)
                        .addOnSuccessListener(unused -> {
                            NotificationRepository.get().push(
                                    request.getFromUserId(),
                                    AppNotification.TYPE_REQUEST_ACCEPTED,
                                    "¡Solicitud aceptada!",
                                    request.getToUserName() + " aceptó tu intercambio. Ya pueden conversar.",
                                    exchange.getId());
                            callback.onSuccess(exchange);
                        })
                        .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
            }

            @Override
            public void onError(String message) {
                callback.onError(message);
            }
        });
    }

    public void reject(final ExchangeRequest request, final RepoCallback<Boolean> callback) {
        updateStatus(request, ExchangeRequest.STATUS_REJECTED, callback);
        NotificationRepository.get().push(
                request.getFromUserId(),
                AppNotification.TYPE_REQUEST_REJECTED,
                "Solicitud rechazada",
                request.getToUserName() + " no puede realizar el intercambio por ahora",
                request.getId());
    }

    public void cancel(final ExchangeRequest request, final RepoCallback<Boolean> callback) {
        updateStatus(request, ExchangeRequest.STATUS_CANCELLED, callback);
    }

    private void updateStatus(final ExchangeRequest request, final String status,
                              final RepoCallback<Boolean> callback) {
        if (request == null) {
            callback.onError("Solicitud no válida");
            return;
        }
        Map<String, Object> data = new HashMap<>();
        data.put("status", status);
        data.put("updatedAt", System.currentTimeMillis());

        FirestoreCollections.requests().document(request.getId())
                .update(data)
                .addOnSuccessListener(unused -> callback.onSuccess(Boolean.TRUE))
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    public void fetchById(String id, final RepoCallback<ExchangeRequest> callback) {
        FirestoreCollections.requests().document(id).get()
                .addOnSuccessListener(doc -> {
                    if (!doc.exists()) {
                        callback.onError("La solicitud ya no existe");
                        return;
                    }
                    ExchangeRequest r = doc.toObject(ExchangeRequest.class);
                    if (r != null) r.setId(doc.getId());
                    callback.onSuccess(r);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }
}
