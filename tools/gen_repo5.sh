#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
R="$J/repository"
mkdir -p "$R"

# ============================================================ ContractRepository
cat > "$R/ContractRepository.java" <<'EOF'
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
EOF

# ============================================================ ChallengeRepository
cat > "$R/ChallengeRepository.java" <<'EOF'
package com.skillswap.repository;

import androidx.annotation.Nullable;

import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.ListenerRegistration;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.skillswap.firebase.FirestoreCollections;
import com.skillswap.model.AppNotification;
import com.skillswap.model.Challenge;
import com.skillswap.model.ChallengeParticipant;
import com.skillswap.model.User;
import com.skillswap.utils.Constants;
import com.skillswap.utils.DateUtils;
import com.skillswap.utils.GamificationEngine;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** INNOVACION 5 - Skill Challenges (retos colaborativos). */
public class ChallengeRepository {

    private static ChallengeRepository instance;

    public static synchronized ChallengeRepository get() {
        if (instance == null) instance = new ChallengeRepository();
        return instance;
    }

    private ChallengeRepository() {
    }

    public void create(final User creator, final Challenge challenge,
                       final RepoCallback<Challenge> callback) {
        if (creator == null) {
            callback.onError("Perfil no disponible");
            return;
        }
        if (challenge.getTitle() == null || challenge.getTitle().trim().length() < 5) {
            callback.onError("El título debe tener al menos 5 caracteres");
            return;
        }
        if (challenge.getRequiredSkills().isEmpty()) {
            callback.onError("Agrega al menos una habilidad requerida");
            return;
        }

        DocumentReference ref = FirestoreCollections.challenges().document();
        challenge.setId(ref.getId());
        challenge.setCreatorId(creator.getUid());
        challenge.setCreatorName(creator.getFullName());
        challenge.setCreatorPhoto(creator.getPhotoUrl());
        challenge.setParticipantIds(new ArrayList<>(
                Collections.singletonList(creator.getUid())));
        challenge.setParticipantsCount(1);
        challenge.setStatus(Challenge.STATUS_OPEN);
        challenge.setProgress(0);
        challenge.setCreatedAt(System.currentTimeMillis());
        if (challenge.getDeadline() == 0) {
            challenge.setDeadline(DateUtils.plusDays(challenge.getDurationDays()));
        }

        ref.set(challenge)
                .addOnSuccessListener(unused -> callback.onSuccess(challenge))
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    public ListenerRegistration listenAll(final RepoCallback<List<Challenge>> callback) {
        return FirestoreCollections.challenges()
                .limit(60)
                .addSnapshotListener(new EventListener<QuerySnapshot>() {
                    @Override
                    public void onEvent(@Nullable QuerySnapshot snapshots,
                                        @Nullable FirebaseFirestoreException e) {
                        if (e != null) {
                            callback.onError(FirebaseErrors.translate(e));
                            return;
                        }
                        List<Challenge> list = new ArrayList<>();
                        if (snapshots != null) {
                            for (QueryDocumentSnapshot doc : snapshots) {
                                Challenge c = doc.toObject(Challenge.class);
                                c.setId(doc.getId());
                                list.add(c);
                            }
                        }
                        Collections.sort(list, new Comparator<Challenge>() {
                            @Override
                            public int compare(Challenge a, Challenge b) {
                                return Long.compare(b.getCreatedAt(), a.getCreatedAt());
                            }
                        });
                        callback.onSuccess(list);
                    }
                });
    }

    public ListenerRegistration listenById(String id, final RepoCallback<Challenge> callback) {
        return FirestoreCollections.challenges().document(id)
                .addSnapshotListener((snapshot, e) -> {
                    if (e != null) {
                        callback.onError(FirebaseErrors.translate(e));
                        return;
                    }
                    if (snapshot == null || !snapshot.exists()) {
                        callback.onError("El reto ya no existe");
                        return;
                    }
                    Challenge c = snapshot.toObject(Challenge.class);
                    if (c != null) c.setId(snapshot.getId());
                    callback.onSuccess(c);
                });
    }

    /** Solicita unirse a un reto aportando una habilidad. */
    public void requestJoin(final Challenge challenge, final User user, final String skill,
                            final String message, final RepoCallback<Boolean> callback) {
        if (challenge == null || user == null) {
            callback.onError("Reto no disponible");
            return;
        }
        if (challenge.getParticipantIds().contains(user.getUid())) {
            callback.onError("Ya formas parte de este reto");
            return;
        }
        if (challenge.isFull()) {
            callback.onError("El reto ya tiene todos sus participantes");
            return;
        }
        if (skill == null || skill.trim().isEmpty()) {
            callback.onError("Indica con qué habilidad aportarás");
            return;
        }

        final String id = challenge.getId() + "__" + user.getUid();
        ChallengeParticipant p = new ChallengeParticipant();
        p.setId(id);
        p.setChallengeId(challenge.getId());
        p.setUserId(user.getUid());
        p.setUserName(user.getFullName());
        p.setUserPhoto(user.getPhotoUrl());
        p.setSkill(skill);
        p.setRole(skill);
        p.setMessage(message == null ? "" : message);
        p.setStatus(ChallengeParticipant.STATUS_PENDING);
        p.setJoinedAt(System.currentTimeMillis());

        FirestoreCollections.challengeParticipants().document(id).set(p)
                .addOnSuccessListener(unused -> {
                    NotificationRepository.get().push(challenge.getCreatorId(),
                            AppNotification.TYPE_CHALLENGE,
                            "Nueva postulación a tu reto",
                            user.getShortName() + " quiere participar aportando " + skill,
                            challenge.getId());
                    callback.onSuccess(Boolean.TRUE);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    public ListenerRegistration listenParticipants(String challengeId,
                                                   final RepoCallback<List<ChallengeParticipant>> callback) {
        return FirestoreCollections.challengeParticipants()
                .whereEqualTo("challengeId", challengeId)
                .addSnapshotListener(new EventListener<QuerySnapshot>() {
                    @Override
                    public void onEvent(@Nullable QuerySnapshot snapshots,
                                        @Nullable FirebaseFirestoreException e) {
                        if (e != null) {
                            callback.onError(FirebaseErrors.translate(e));
                            return;
                        }
                        List<ChallengeParticipant> list = new ArrayList<>();
                        if (snapshots != null) {
                            for (QueryDocumentSnapshot doc : snapshots) {
                                ChallengeParticipant p = doc.toObject(ChallengeParticipant.class);
                                p.setId(doc.getId());
                                list.add(p);
                            }
                        }
                        Collections.sort(list, new Comparator<ChallengeParticipant>() {
                            @Override
                            public int compare(ChallengeParticipant a, ChallengeParticipant b) {
                                return Long.compare(a.getJoinedAt(), b.getJoinedAt());
                            }
                        });
                        callback.onSuccess(list);
                    }
                });
    }

    /** El creador acepta o rechaza a un postulante. */
    public void respond(final Challenge challenge, final ChallengeParticipant participant,
                        final boolean accept, final RepoCallback<Boolean> callback) {
        Map<String, Object> data = new HashMap<>();
        data.put("status", accept
                ? ChallengeParticipant.STATUS_ACCEPTED
                : ChallengeParticipant.STATUS_REJECTED);

        FirestoreCollections.challengeParticipants().document(participant.getId())
                .update(data)
                .addOnSuccessListener(unused -> {
                    if (accept) {
                        Map<String, Object> cd = new HashMap<>();
                        cd.put("participantIds", FieldValue.arrayUnion(participant.getUserId()));
                        cd.put("participantsCount", FieldValue.increment(1));
                        FirestoreCollections.challenges().document(challenge.getId()).update(cd);

                        GamificationRepository.get().award(participant.getUserId(),
                                Constants.POINTS_CHALLENGE_JOINED, "Reto colaborativo", challenge.getId());
                        GamificationRepository.get().unlockBadge(participant.getUserId(),
                                GamificationEngine.BADGE_TEAM_PLAYER);
                    }
                    NotificationRepository.get().push(participant.getUserId(),
                            AppNotification.TYPE_CHALLENGE,
                            accept ? "¡Te uniste a un reto!" : "Postulación no aceptada",
                            challenge.getTitle(),
                            challenge.getId());
                    callback.onSuccess(Boolean.TRUE);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    public void updateProgress(String challengeId, int progress, final RepoCallback<Boolean> callback) {
        int p = Math.max(0, Math.min(100, progress));
        Map<String, Object> data = new HashMap<>();
        data.put("progress", p);
        data.put("status", p >= 100 ? Challenge.STATUS_FINISHED : Challenge.STATUS_IN_PROGRESS);
        FirestoreCollections.challenges().document(challengeId).update(data)
                .addOnSuccessListener(unused -> callback.onSuccess(Boolean.TRUE))
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }
}
EOF

# ============================================================ EvidenceRepository
cat > "$R/EvidenceRepository.java" <<'EOF'
package com.skillswap.repository;

import android.net.Uri;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.Continuation;
import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.firebase.FirestoreCollections;
import com.skillswap.model.Exchange;
import com.skillswap.model.LearningEvidence;
import com.skillswap.utils.Constants;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * INNOVACION 6 - Validacion practica del aprendizaje.
 * Es una autoevaluacion entre pares, NO una certificacion academica.
 */
public class EvidenceRepository {

    private static EvidenceRepository instance;

    public static synchronized EvidenceRepository get() {
        if (instance == null) instance = new EvidenceRepository();
        return instance;
    }

    private EvidenceRepository() {
    }

    public void submit(final Exchange exchange, final String uid, final LearningEvidence evidence,
                       final Uri fileUri, final RepoCallback<LearningEvidence> callback) {
        if (exchange == null) {
            callback.onError("Intercambio no disponible");
            return;
        }
        if (evidence.getActivity() == null || evidence.getActivity().trim().isEmpty()) {
            callback.onError("Describe la actividad realizada");
            return;
        }

        final DocumentReference ref = FirestoreCollections.evidence().document();
        evidence.setId(ref.getId());
        evidence.setExchangeId(exchange.getId());
        evidence.setUserId(uid);
        evidence.setPartnerId(exchange.getPartnerId(uid));
        evidence.setSkillName(exchange.getSkillILearn(uid));
        evidence.setCreatedAt(System.currentTimeMillis());

        if (fileUri == null) {
            persist(ref, evidence, uid, callback);
            return;
        }

        final StorageReference storage = FirebaseManager.storage().getReference()
                .child(Constants.STORAGE_EVIDENCE)
                .child(uid)
                .child(evidence.getId() + ".jpg");

        storage.putFile(fileUri).continueWithTask(new Continuation<UploadTask.TaskSnapshot, Task<Uri>>() {
            @Override
            public Task<Uri> then(@NonNull Task<UploadTask.TaskSnapshot> task) throws Exception {
                if (!task.isSuccessful() && task.getException() != null) throw task.getException();
                return storage.getDownloadUrl();
            }
        }).addOnCompleteListener(task -> {
            if (task.isSuccessful() && task.getResult() != null) {
                evidence.setEvidenceUrl(task.getResult().toString());
            }
            persist(ref, evidence, uid, callback);
        });
    }

    private void persist(DocumentReference ref, final LearningEvidence evidence, final String uid,
                         final RepoCallback<LearningEvidence> callback) {
        ref.set(evidence)
                .addOnSuccessListener(unused -> {
                    GamificationRepository.get().award(uid, Constants.POINTS_EVIDENCE_REGISTERED,
                            "Validación de aprendizaje", evidence.getId());
                    callback.onSuccess(evidence);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    public void fetchByUser(String uid, final RepoCallback<List<LearningEvidence>> callback) {
        FirestoreCollections.evidence()
                .whereEqualTo("userId", uid)
                .limit(100)
                .get()
                .addOnSuccessListener(snapshots -> {
                    List<LearningEvidence> list = new ArrayList<>();
                    for (QueryDocumentSnapshot doc : snapshots) {
                        LearningEvidence ev = doc.toObject(LearningEvidence.class);
                        ev.setId(doc.getId());
                        list.add(ev);
                    }
                    Collections.sort(list, new Comparator<LearningEvidence>() {
                        @Override
                        public int compare(LearningEvidence a, LearningEvidence b) {
                            return Long.compare(b.getCreatedAt(), a.getCreatedAt());
                        }
                    });
                    callback.onSuccess(list);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }
}
EOF

echo "Repositorios (contratos/retos/evidencia) generados."
