#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
R="$J/repository"
mkdir -p "$R"

# ============================================================ NotificationRepository
cat > "$R/NotificationRepository.java" <<'EOF'
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
EOF

# ============================================================ MatchRepository
cat > "$R/MatchRepository.java" <<'EOF'
package com.skillswap.repository;

import com.google.firebase.firestore.DocumentReference;
import com.skillswap.firebase.FirestoreCollections;
import com.skillswap.model.ExploreFilter;
import com.skillswap.model.MatchResult;
import com.skillswap.model.User;
import com.skillswap.model.UserSkill;
import com.skillswap.utils.SkillCatalog;
import com.skillswap.utils.SkillMatchEngine;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * INNOVACION 1 - SkillMatch.
 * Recupera candidatos y los ordena con el motor de compatibilidad.
 */
public class MatchRepository {

    private static MatchRepository instance;

    public static synchronized MatchRepository get() {
        if (instance == null) instance = new MatchRepository();
        return instance;
    }

    private MatchRepository() {
    }

    /** Calcula todos los matches del usuario actual. */
    public void findMatches(final User me, final RepoCallback<List<MatchResult>> callback) {
        if (me == null) {
            callback.onError("Perfil no disponible");
            return;
        }
        UserRepository.get().fetchCandidates(me.getUid(), new RepoCallback<List<User>>() {
            @Override
            public void onSuccess(List<User> data) {
                callback.onSuccess(SkillMatchEngine.rank(me, data));
            }

            @Override
            public void onError(String message) {
                callback.onError(message);
            }
        });
    }

    /** Explorar: matches + filtros + busqueda de texto. */
    public void explore(final User me, final ExploreFilter filter,
                        final RepoCallback<List<MatchResult>> callback) {
        findMatches(me, new RepoCallback<List<MatchResult>>() {
            @Override
            public void onSuccess(List<MatchResult> data) {
                callback.onSuccess(applyFilters(data, filter));
            }

            @Override
            public void onError(String message) {
                callback.onError(message);
            }
        });
    }

    /** Guarda el match en la coleccion "matches" para poder notificarlo. */
    public void saveMatch(MatchResult match) {
        if (match == null || match.getScore() < SkillMatchEngine.MATCH_THRESHOLD) return;
        String id = buildMatchId(match.getUserAId(), match.getUserBId());
        DocumentReference ref = FirestoreCollections.matches().document(id);
        match.setId(id);
        ref.set(match);
    }

    public static String buildMatchId(String a, String b) {
        if (a == null) a = "";
        if (b == null) b = "";
        return a.compareTo(b) <= 0 ? a + "_" + b : b + "_" + a;
    }

    // ------------------------------------------------------------- filtros

    public static List<MatchResult> applyFilters(List<MatchResult> input, ExploreFilter f) {
        List<MatchResult> out = new ArrayList<>();
        if (input == null) return out;
        if (f == null) return new ArrayList<>(input);

        for (MatchResult m : input) {
            User u = m.getUser();
            if (u == null) continue;

            if (!isBlank(f.getQuery()) && !matchesQuery(u, f.getQuery())) continue;
            if (!isBlank(f.getSkill()) && !teachesSkill(u, f.getSkill())) continue;
            if (!isBlank(f.getCategory()) && !hasCategory(u, f.getCategory())) continue;
            if (!isBlank(f.getLevel()) && !hasLevel(u, f.getLevel())) continue;
            if (!isBlank(f.getModality())
                    && !SkillMatchEngine.modalityCompatible(f.getModality(), u.getModality())) continue;
            if (!isBlank(f.getUniversity())
                    && (u.getUniversity() == null
                    || !u.getUniversity().toLowerCase(Locale.ROOT)
                    .contains(f.getUniversity().toLowerCase(Locale.ROOT)))) continue;
            if (m.getScore() < f.getMinCompatibility()) continue;

            out.add(m);
        }
        return out;
    }

    private static boolean matchesQuery(User u, String query) {
        String q = query.toLowerCase(Locale.ROOT).trim();
        if (contains(u.getFullName(), q)) return true;
        if (contains(u.getCareer(), q)) return true;
        if (contains(u.getUniversity(), q)) return true;
        for (UserSkill s : u.getTeachSkills()) {
            if (contains(s.getName(), q)) return true;
        }
        for (UserSkill s : u.getLearnSkills()) {
            if (contains(s.getName(), q)) return true;
        }
        return false;
    }

    private static boolean teachesSkill(User u, String skill) {
        String key = skill.toLowerCase(Locale.ROOT).trim();
        for (UserSkill s : u.getTeachSkills()) {
            if (s.getKey().equals(key)) return true;
        }
        return false;
    }

    private static boolean hasCategory(User u, String category) {
        for (UserSkill s : u.getTeachSkills()) {
            String cat = isBlank(s.getCategory()) ? SkillCatalog.categoryOf(s.getName()) : s.getCategory();
            if (category.equals(cat)) return true;
        }
        return false;
    }

    private static boolean hasLevel(User u, String level) {
        for (UserSkill s : u.getTeachSkills()) {
            if (level.equals(s.getLevel())) return true;
        }
        return false;
    }

    private static boolean contains(String value, String query) {
        return value != null && value.toLowerCase(Locale.ROOT).contains(query);
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
EOF

# ============================================================ ExchangeRequestRepository
cat > "$R/ExchangeRequestRepository.java" <<'EOF'
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

    private ListenerRegistration listen(String field, String uid,
                                        final RepoCallback<List<ExchangeRequest>> callback) {
        return FirestoreCollections.requests()
                .whereEqualTo(field, uid)
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
                                list.add(r);
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
EOF

echo "Repositorios (notificaciones/match/solicitudes) generados."
