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
