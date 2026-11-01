package com.skillswap.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.util.Base64;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * Prepara la foto de perfil para guardarla dentro del documento del usuario.
 *
 * El plan Spark de Firebase no incluye Cloud Storage, asi que en lugar de
 * subir el archivo se reduce a un cuadrado pequeno, se comprime en JPEG y se
 * guarda como data URI en el campo photoUrl. Con 192 px y calidad 70 el
 * resultado ronda los 10-15 KB, muy por debajo del limite de 1 MiB por
 * documento de Firestore.
 *
 * Si algun dia se activa Cloud Storage basta con volver a subir el archivo y
 * guardar la URL: el resto de la app no cambia porque todo pasa por
 * {@link ImageLoader}.
 */
public final class ImageUtils {

    /** Prefijo que distingue una imagen incrustada de una URL normal. */
    public static final String DATA_PREFIX = "data:image/jpeg;base64,";

    /** Avatar: cuadrado pequeno, se copia en chats e intercambios. */
    private static final int AVATAR_SIZE = 192;
    private static final int AVATAR_QUALITY = 70;
    private static final int AVATAR_MAX_BYTES = 300 * 1024;

    /** Evidencia: se mira a pantalla completa, necesita mas resolucion. */
    private static final int EVIDENCE_SIZE = 800;
    private static final int EVIDENCE_QUALITY = 75;
    private static final int EVIDENCE_MAX_BYTES = 500 * 1024;

    private static final int MIN_QUALITY = 30;

    private ImageUtils() {
    }

    public static boolean isEmbedded(String value) {
        return value != null && value.startsWith("data:image");
    }

    /**
     * Foto de perfil: se recorta al centro para que el avatar circular no
     * deforme la imagen. Es una operacion de disco: llamarla fuera del hilo
     * principal.
     */
    public static String encodeAvatar(Context context, Uri uri) throws IOException {
        Bitmap scaled = decodeScaled(context, uri, AVATAR_SIZE);
        if (scaled == null) throw new IOException("No se pudo leer la imagen");

        Bitmap square = cropCenterSquare(scaled);
        if (square != scaled) scaled.recycle();

        return compress(square, AVATAR_QUALITY, AVATAR_MAX_BYTES);
    }

    /**
     * Evidencia de aprendizaje: se conserva la proporcion original porque
     * suele ser una captura o una foto de lo construido.
     */
    public static String encodeEvidence(Context context, Uri uri) throws IOException {
        Bitmap scaled = decodeScaled(context, uri, EVIDENCE_SIZE);
        if (scaled == null) throw new IOException("No se pudo leer la imagen");
        return compress(scaled, EVIDENCE_QUALITY, EVIDENCE_MAX_BYTES);
    }

    /** Baja la calidad hasta entrar en el presupuesto de bytes. */
    private static String compress(Bitmap bitmap, int startQuality, int maxBytes)
            throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        int quality = startQuality;
        do {
            out.reset();
            bitmap.compress(Bitmap.CompressFormat.JPEG, quality, out);
            quality -= 15;
        } while (out.size() > maxBytes && quality >= MIN_QUALITY);
        bitmap.recycle();

        if (out.size() > maxBytes) {
            throw new IOException("La imagen es demasiado pesada");
        }
        return DATA_PREFIX + Base64.encodeToString(out.toByteArray(), Base64.NO_WRAP);
    }

    /** Convierte el data URI guardado en un Bitmap para mostrarlo. */
    public static Bitmap decodeEmbedded(String dataUri) {
        if (!isEmbedded(dataUri)) return null;
        int comma = dataUri.indexOf(',');
        if (comma < 0) return null;
        try {
            byte[] bytes = Base64.decode(dataUri.substring(comma + 1), Base64.NO_WRAP);
            return BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
        } catch (Exception e) {
            return null;
        }
    }

    // ------------------------------------------------------------- privados

    /** Decodifica la imagen reducida de golpe, sin cargarla entera en memoria. */
    private static Bitmap decodeScaled(Context context, Uri uri, int maxSize) throws IOException {
        BitmapFactory.Options bounds = new BitmapFactory.Options();
        bounds.inJustDecodeBounds = true;
        InputStream in = context.getContentResolver().openInputStream(uri);
        if (in == null) throw new IOException("No se pudo abrir la imagen");
        try {
            BitmapFactory.decodeStream(in, null, bounds);
        } finally {
            closeQuietly(in);
        }

        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inSampleSize = sampleSize(bounds.outWidth, bounds.outHeight, maxSize);

        in = context.getContentResolver().openInputStream(uri);
        if (in == null) throw new IOException("No se pudo abrir la imagen");
        Bitmap decoded;
        try {
            decoded = BitmapFactory.decodeStream(in, null, options);
        } finally {
            closeQuietly(in);
        }
        if (decoded == null) return null;

        int longest = Math.max(decoded.getWidth(), decoded.getHeight());
        if (longest <= maxSize) return decoded;

        float ratio = (float) maxSize / (float) longest;
        int w = Math.max(1, Math.round(decoded.getWidth() * ratio));
        int h = Math.max(1, Math.round(decoded.getHeight() * ratio));
        Bitmap resized = Bitmap.createScaledBitmap(decoded, w, h, true);
        if (resized != decoded) decoded.recycle();
        return resized;
    }

    private static int sampleSize(int width, int height, int maxSize) {
        int sample = 1;
        while (width / (sample * 2) >= maxSize && height / (sample * 2) >= maxSize) {
            sample *= 2;
        }
        return sample;
    }

    /** Recorta el centro para que el avatar circular no deforme la foto. */
    private static Bitmap cropCenterSquare(Bitmap source) {
        int w = source.getWidth();
        int h = source.getHeight();
        if (w == h) return source;
        int side = Math.min(w, h);
        int x = (w - side) / 2;
        int y = (h - side) / 2;
        return Bitmap.createBitmap(source, x, y, side, side);
    }

    private static void closeQuietly(InputStream in) {
        try {
            in.close();
        } catch (IOException ignored) {
        }
    }
}
