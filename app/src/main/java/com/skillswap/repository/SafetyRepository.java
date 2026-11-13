package com.skillswap.repository;

import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.WriteBatch;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.firebase.FirestoreCollections;
import com.skillswap.model.MatchResult;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Seguridad entre estudiantes: reportar una conducta y bloquear a alguien.
 *
 * Es lo que Google Play exige a las aplicaciones con contenido generado por
 * usuarios (aqui, el chat) y lo que los terminos y condiciones prometen
 * (Anexo 1, punto 5).
 *
 *  - Un REPORTE queda guardado para que lo revise el equipo desde la consola;
 *    la app no muestra al reportado quien lo reporto.
 *  - Un BLOQUEO cierra el chat para los dos (lo impone la regla de seguridad),
 *    solo lo puede levantar quien bloqueo, y el bloqueado deja de aparecer en
 *    los resultados de Explorar de quien bloqueo.
 */
public class SafetyRepository {

    /** Motivos que ofrece la pantalla de reporte. */
    public static final String[] MOTIVOS = {
            "Acoso o trato irrespetuoso",
            "Contenido ofensivo o discriminatorio",
            "Suplantación de identidad",
            "Intenta cobrar o vender servicios",
            "Otro motivo"
    };

    private static SafetyRepository instance;

    public static synchronized SafetyRepository get() {
        if (instance == null) instance = new SafetyRepository();
        return instance;
    }

    private SafetyRepository() {
    }

    // ------------------------------------------------------------------ reportar

    public void report(final String chatId, final String reportedId, final String reason,
                       final String details, final RepoCallback<Boolean> callback) {
        final String me = FirebaseManager.uid();
        if (me == null || me.isEmpty()) {
            callback.onError("Sesión no válida");
            return;
        }
        if (reportedId == null || reportedId.isEmpty() || reportedId.equals(me)) {
            callback.onError("No se puede reportar a este usuario");
            return;
        }
        if (reason == null || reason.trim().isEmpty()) {
            callback.onError("Elige un motivo");
            return;
        }

        DocumentReference ref = FirestoreCollections.reports().document();
        Map<String, Object> data = new HashMap<>();
        data.put("id", ref.getId());
        data.put("reporterId", me);
        data.put("reportedId", reportedId);
        data.put("chatId", chatId == null ? "" : chatId);
        data.put("reason", reason);
        data.put("details", details == null ? "" : details.trim());
        data.put("status", "PENDIENTE");
        data.put("createdAt", System.currentTimeMillis());

        ref.set(data)
                .addOnSuccessListener(unused -> callback.onSuccess(Boolean.TRUE))
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    // ------------------------------------------------------------------ bloquear

    /** Id del documento de bloqueo: quien bloquea + a quien. */
    public static String idDeBloqueo(String blockerId, String blockedId) {
        return blockerId + "__" + blockedId;
    }

    /**
     * Bloquea al otro estudiante. Se hace en un solo lote para que no pueda
     * quedar la marca de bloqueo sin el chat cerrado, ni al reves.
     */
    public void block(final String chatId, final String blockedId,
                      final RepoCallback<Boolean> callback) {
        cambiarBloqueo(chatId, blockedId, true, callback);
    }

    public void unblock(final String chatId, final String blockedId,
                        final RepoCallback<Boolean> callback) {
        cambiarBloqueo(chatId, blockedId, false, callback);
    }

    private void cambiarBloqueo(String chatId, String blockedId, boolean bloquear,
                                final RepoCallback<Boolean> callback) {
        String me = FirebaseManager.uid();
        if (me == null || me.isEmpty() || blockedId == null || blockedId.isEmpty()
                || blockedId.equals(me)) {
            callback.onError("No se puede completar la acción");
            return;
        }

        WriteBatch batch = FirebaseManager.db().batch();
        DocumentReference bloqueo = FirestoreCollections.blocks()
                .document(idDeBloqueo(me, blockedId));

        if (bloquear) {
            Map<String, Object> data = new HashMap<>();
            data.put("blockerId", me);
            data.put("blockedId", blockedId);
            data.put("createdAt", System.currentTimeMillis());
            batch.set(bloqueo, data);
        } else {
            batch.delete(bloqueo);
        }

        if (chatId != null && !chatId.isEmpty()) {
            Map<String, Object> chat = new HashMap<>();
            chat.put("blocked", bloquear);
            chat.put("blockedBy", bloquear ? me : "");
            batch.update(FirestoreCollections.chats().document(chatId), chat);
        }

        batch.commit()
                .addOnSuccessListener(unused -> callback.onSuccess(Boolean.TRUE))
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    /** Ids de los estudiantes que YO he bloqueado. */
    public void fetchBlockedIds(final RepoCallback<Set<String>> callback) {
        String me = FirebaseManager.uid();
        if (me == null || me.isEmpty()) {
            callback.onSuccess(new HashSet<String>());
            return;
        }
        FirestoreCollections.blocks()
                .whereEqualTo("blockerId", me)
                .get()
                .addOnSuccessListener(snapshots -> {
                    Set<String> ids = new HashSet<>();
                    for (QueryDocumentSnapshot doc : snapshots) {
                        String id = doc.getString("blockedId");
                        if (id != null) ids.add(id);
                    }
                    callback.onSuccess(ids);
                })
                // Si no se puede leer la lista no se rompe Explorar: se muestra
                // todo, igual que antes de existir los bloqueos.
                .addOnFailureListener(e -> callback.onSuccess(new HashSet<String>()));
    }

    // ------------------------------------------------------------------ filtrado

    /** Quita de los resultados a los estudiantes bloqueados. Logica pura, probada con JUnit. */
    public static List<MatchResult> sinBloqueados(List<MatchResult> resultados,
                                                  Set<String> bloqueados) {
        if (resultados == null) return new ArrayList<>();
        if (bloqueados == null || bloqueados.isEmpty()) return new ArrayList<>(resultados);

        List<MatchResult> visibles = new ArrayList<>();
        for (MatchResult m : resultados) {
            String uid = (m == null || m.getUser() == null) ? null : m.getUser().getUid();
            if (uid != null && bloqueados.contains(uid)) continue;
            visibles.add(m);
        }
        return visibles;
    }
}
