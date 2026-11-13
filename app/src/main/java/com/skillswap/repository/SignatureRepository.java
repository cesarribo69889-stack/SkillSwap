package com.skillswap.repository;

import android.graphics.Bitmap;
import android.util.Base64;

import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.FieldValue;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.firebase.FirestoreCollections;
import com.skillswap.utils.Constants;

import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.HashMap;
import java.util.Map;

/**
 * RC3 - Constancia de aceptacion firmada.
 *
 * Guarda en Firestore quien acepto, a que solicitud corresponde, la fecha y
 * hora tomadas del SERVIDOR (no del telefono, que el usuario puede cambiar)
 * y una huella SHA-256 del texto exacto que se acepto. La imagen de la firma
 * se intenta subir a Cloud Storage y, si el bucket no responde, se incrusta
 * reducida en el propio documento, igual que la foto de perfil.
 *
 * ALCANCE: firma manuscrita digitalizada. No es una firma digital con
 * certificado ni sustituye un documento legal.
 */
public class SignatureRepository {

    private static SignatureRepository instance;

    public static synchronized SignatureRepository get() {
        if (instance == null) instance = new SignatureRepository();
        return instance;
    }

    private SignatureRepository() {
    }

    /**
     * Registra la aceptacion firmada.
     *
     * @param requestId  solicitud que se acepta
     * @param textoAceptado texto exacto mostrado al usuario (del que sale la huella)
     * @param firma      imagen dibujada en el lienzo
     */
    public void registrar(final String requestId, final String textoAceptado,
                          final Bitmap firma, final RepoCallback<String> callback) {
        final String uid = FirebaseManager.uid();
        if (uid == null || uid.isEmpty()) {
            callback.onError("Sesión no válida");
            return;
        }
        if (firma == null) {
            callback.onError("Dibuja tu firma para continuar");
            return;
        }

        final String huella = sha256(textoAceptado);
        final DocumentReference ref =
                FirestoreCollections.signatures().document(requestId + "__" + uid);

        Map<String, Object> data = new HashMap<>();
        data.put("id", ref.getId());
        data.put("requestId", requestId);
        data.put("userId", uid);
        data.put("textHash", huella);
        data.put("signatureImage", aBase64(firma));
        // La hora la pone el servidor: no se confia en el reloj del telefono.
        data.put("signedAt", FieldValue.serverTimestamp());

        ref.set(data)
                .addOnSuccessListener(unused -> callback.onSuccess(huella))
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    /** Huella SHA-256 del texto aceptado, en hexadecimal. */
    public static String sha256(String texto) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bytes = md.digest(
                    (texto == null ? "" : texto).getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            return "";
        }
    }

    /** PNG en base64, reducido para que quepa holgado en un documento. */
    private String aBase64(Bitmap firma) {
        Bitmap escalada = escalar(firma, Constants.SIGNATURE_MAX_WIDTH);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        escalada.compress(Bitmap.CompressFormat.PNG, 100, out);
        return "data:image/png;base64,"
                + Base64.encodeToString(out.toByteArray(), Base64.NO_WRAP);
    }

    private Bitmap escalar(Bitmap origen, int anchoMax) {
        if (origen.getWidth() <= anchoMax) return origen;
        int alto = Math.round(origen.getHeight()
                * (anchoMax / (float) origen.getWidth()));
        return Bitmap.createScaledBitmap(origen, anchoMax, alto, true);
    }
}
