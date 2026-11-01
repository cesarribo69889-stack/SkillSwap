package com.skillswap.utils;

import android.graphics.Bitmap;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.skillswap.R;

/**
 * Carga de imagenes con Glide.
 *
 * Las fotos de perfil pueden llegar de dos formas: como URL normal o como
 * data URI incrustado (ver {@link ImageUtils}). Este es el unico punto de la
 * app que necesita distinguirlas.
 */
public final class ImageLoader {

    private ImageLoader() {
    }

    public static void avatar(ImageView view, String url) {
        if (view == null) return;
        if (url == null || url.trim().isEmpty()) {
            view.setImageResource(R.drawable.ic_avatar_placeholder);
            return;
        }
        if (ImageUtils.isEmbedded(url)) {
            Bitmap bitmap = ImageUtils.decodeEmbedded(url);
            if (bitmap != null) view.setImageBitmap(bitmap);
            else view.setImageResource(R.drawable.ic_avatar_placeholder);
            return;
        }
        Glide.with(view.getContext())
                .load(url)
                .placeholder(R.drawable.ic_avatar_placeholder)
                .error(R.drawable.ic_avatar_placeholder)
                .diskCacheStrategy(DiskCacheStrategy.ALL)
                .centerCrop()
                .into(view);
    }

    public static void image(ImageView view, String url, int placeholder) {
        if (view == null) return;
        if (url == null || url.trim().isEmpty()) {
            view.setImageResource(placeholder);
            return;
        }
        if (ImageUtils.isEmbedded(url)) {
            Bitmap bitmap = ImageUtils.decodeEmbedded(url);
            if (bitmap != null) view.setImageBitmap(bitmap);
            else view.setImageResource(placeholder);
            return;
        }
        Glide.with(view.getContext())
                .load(url)
                .placeholder(placeholder)
                .error(placeholder)
                .diskCacheStrategy(DiskCacheStrategy.ALL)
                .centerCrop()
                .into(view);
    }
}
