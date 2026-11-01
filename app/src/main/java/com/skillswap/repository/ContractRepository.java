package com.skillswap.repository;

import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.ListenerRegistration;
import com.skillswap.firebase.FirestoreCollections;
import com.skillswap.model.AppNotification;
import com.skillswap.model.Exchange;
import com.skillswap.model.LearningContract;
import com.skillswap.utils.Constants;
import com.skillswap.utils.GamificationEngine;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

/**
 * INNOVACION 3 - Contrato de aprendizaje (coleccion "learningContracts").
 * Ambos estudiantes deben aceptar el acuerdo antes de iniciar.
 */
public class ContractRepository {

    private static ContractRepository instance;

    public static synchronized ContractRepository get() {
        if (instance == null) instance = new ContractRepository();
        return instance;
    }

    private ContractRepository() {
    }

    /** Crea o reemplaza el contrato de un intercambio. */
    public void save(final Exchange exchange, final String creatorId,
                     final LearningContract contract, final RepoCallback<LearningContract> callback) {
        if (exchange == null) {
            callback.onError("Intercambio no disponible");
            return;
        }
        if (contract.getObjective() == null || contract.getObjective().trim().isEmpty()) {
            callback.onError("Describe el objetivo del intercambio");
            return;
        }
        if (contract.getSessions() < 1 || contract.getSessions() > 20) {
            callback.onError("Las sesiones deben estar entre 1 y 20");
            return;
        }
        if (contract.getSessionDuration() < 15 || contract.getSessionDuration() > 240) {
            callback.onError("La duración debe estar entre 15 y 240 minutos");
            return;
        }

        final DocumentReference ref = FirestoreCollections.contracts().document(exchange.getId());
        contract.setId(ref.getId());
        contract.setExchangeId(exchange.getId());
        contract.setUserAId(exchange.getUserAId());
        contract.setUserBId(exchange.getUserBId());
        contract.setParticipants(new ArrayList<>(
                Arrays.asList(exchange.getUserAId(), exchange.getUserBId())));
        contract.setCreatedBy(creatorId);
        contract.setStatus(LearningContract.STATUS_PENDING);
        contract.setAcceptedByA(exchange.getUserAId().equals(creatorId));
        contract.setAcceptedByB(exchange.getUserBId().equals(creatorId));
        if (contract.getCreatedAt() == 0) contract.setCreatedAt(System.currentTimeMillis());
        contract.setUpdatedAt(System.currentTimeMillis());

        ref.set(contract)
                .addOnSuccessListener(unused -> {
                    ExchangeRepository.get().attachContract(exchange.getId(),
                            contract.getId(), contract.getSessions());

                    String partner = exchange.getPartnerId(creatorId);
                    NotificationRepository.get().push(partner,
                            AppNotification.TYPE_NEW_REQUEST,
                            "Contrato de aprendizaje pendiente",
                            "Revisa y acepta el acuerdo para iniciar el intercambio",
                            exchange.getId());

                    callback.onSuccess(contract);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    public ListenerRegistration listen(String exchangeId, final RepoCallback<LearningContract> callback) {
        return FirestoreCollections.contracts().document(exchangeId)
                .addSnapshotListener((snapshot, e) -> {
                    if (e != null) {
                        callback.onError(FirebaseErrors.translate(e));
                        return;
                    }
                    if (snapshot == null || !snapshot.exists()) {
                        callback.onSuccess(null);
                        return;
                    }
                    LearningContract c = snapshot.toObject(LearningContract.class);
                    if (c != null) c.setId(snapshot.getId());
                    callback.onSuccess(c);
                });
    }

    /** Acepta el acuerdo. Cuando ambos aceptan el contrato queda ACTIVO. */
    public void accept(final LearningContract contract, final String uid,
                       final RepoCallback<LearningContract> callback) {
        if (contract == null) {
            callback.onError("Contrato no disponible");
            return;
        }
        final boolean isA = contract.getUserAId().equals(uid);
        final boolean otherAccepted = isA ? contract.isAcceptedByB() : contract.isAcceptedByA();

        Map<String, Object> data = new HashMap<>();
        data.put(isA ? "acceptedByA" : "acceptedByB", true);
        data.put("updatedAt", System.currentTimeMillis());
        if (otherAccepted) data.put("status", LearningContract.STATUS_ACTIVE);

        FirestoreCollections.contracts().document(contract.getId())
                .update(data)
                .addOnSuccessListener(unused -> {
                    if (isA) contract.setAcceptedByA(true);
                    else contract.setAcceptedByB(true);

                    GamificationRepository.get().award(uid,
                            Constants.POINTS_CONTRACT_ACCEPTED, "Contrato aceptado", contract.getId());
                    GamificationRepository.get().unlockBadge(uid, GamificationEngine.BADGE_COMMITTED);

                    if (otherAccepted) {
                        contract.setStatus(LearningContract.STATUS_ACTIVE);
                        ExchangeRepository.get().fetchById(contract.getExchangeId(),
                                new RepoCallback<Exchange>() {
                                    @Override
                                    public void onSuccess(Exchange data) {
                                        if (data != null) {
                                            ExchangeRepository.get().start(data, new RepoCallback<Boolean>() {
                                                @Override
                                                public void onSuccess(Boolean ok) {
                                                }

                                                @Override
                                                public void onError(String message) {
                                                }
                                            });
                                        }
                                    }

                                    @Override
                                    public void onError(String message) {
                                    }
                                });
                    }
                    callback.onSuccess(contract);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }
}
