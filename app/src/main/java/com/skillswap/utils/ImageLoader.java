package com.skillswap.utils;

import android.graphics.Bitmap;
import android.os.Handler;
import android.os.Looper;
import android.util.LruCache;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.skillswap.R;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Carga de imagenes con Glide.
 *
 * Las fotos de perfil pueden llegar de dos formas: como URL normal o como
 * data URI incrustado (ver {@link ImageUtils}). Este es el unico punto de la
 * app que necesita distinguirlas.
 *
 * Las fotos incrustadas se decodifican FUERA del hilo principal, ya
 * reducidas, y el resultado se guarda en una cache en memoria. Antes se
 * decodificaban completas en el hilo principal cada vez que se dibujaba una
 * fila, lo que trababa las listas (Explorar, Chats) y podia agotar la memoria.
 */
public final class ImageLoader {

    /** Lado maximo con el que se decodifica una foto incrustada. */
    private static final int LADO_MAXIMO = 512;

    private static final ExecutorService DECODIFICADOR = Executors.newFixedThreadPool(2);
    private static final Handler PRINCIPAL = new Handler(Looper.getMainLooper());

    // Cache limitada a 1/16 de la memoria disponible de la app, medida en bytes.
    private static final LruCache<String, Bitmap> CACHE = new LruCache<String, Bitmap>(
            (int) Math.max(2 * 1024 * 1024, Runtime.getRuntime().maxMemory() / 16)) {
        @Override
        protected int sizeOf(String key, Bitmap value) {
            return value.getByteCount();
        }
    };

    private ImageLoader() {
    }

    public static void avatar(ImageView view, String url) {
        cargar(view, url, R.drawable.ic_avatar_placeholder);
    }

    public static void image(ImageView view, String url, int placeholder) {
        cargar(view, url, placeholder);
    }

    private static void cargar(final ImageView view, final String url, final int placeholder) {
        if (view == null) return;
        if (url == null || url.trim().isEmpty()) {
            view.setTag(R.id.tag_imagen_clave, null);
            view.setImageResource(placeholder);
            return;
        }
        if (ImageUtils.isEmbedded(url)) {
            cargarIncrustada(view, url, placeholder);
            return;
        }
        view.setTag(R.id.tag_imagen_clave, null);
        Glide.with(view.getContext())
                .load(url)
                .placeholder(placeholder)
                .error(placeholder)
                .diskCacheStrategy(DiskCacheStrategy.ALL)
                .centerCrop()
                .into(view);
    }

    private static void cargarIncrustada(final ImageView view, final String url,
                                         final int placeholder) {
        final String clave = claveDe(url);
        view.setTag(R.id.tag_imagen_clave, clave);

        Bitmap guardado = CACHE.get(clave);
        if (guardado != null) {
            view.setImageBitmap(guardado);
            return;
        }

        view.setImageResource(placeholder);
        DECODIFICADOR.execute(new Runnable() {
            @Override
            public void run() {
                final Bitmap bitmap = ImageUtils.decodeEmbedded(url, LADO_MAXIMO);
                if (bitmap != null) CACHE.put(clave, bitmap);
                PRINCIPAL.post(new Runnable() {
                    @Override
                    public void run() {
                        // Si la fila ya muestra otra foto, esta llego tarde.
                        if (!clave.equals(view.getTag(R.id.tag_imagen_clave))) return;
                        if (bitmap != null) view.setImageBitmap(bitmap);
                        else view.setImageResource(placeholder);
                    }
                });
            }
        });
    }

    /** Clave corta: evita guardar como llave una cadena de cientos de KB. */
    private static String claveDe(String dataUri) {
        return dataUri.length() + ":" + dataUri.hashCode();
    }
}
