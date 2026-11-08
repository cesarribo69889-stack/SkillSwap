package com.skillswap.utils;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.MediaPlayer;

import com.skillswap.R;

/**
 * Sonido de entrada de la aplicacion.
 *
 * Se respeta al usuario en tres niveles:
 *   1. Si el telefono esta en silencio o vibracion, no suena.
 *   2. Si el usuario desactivo el sonido en su perfil, no suena.
 *   3. Suena por el canal multimedia, nunca por el de llamadas.
 *
 * El MediaPlayer se libera siempre al terminar para no dejar el recurso
 * abierto si la pantalla se cierra antes.
 */
public final class SoundPlayer {

    private SoundPlayer() {
    }

    /** Reproduce el sonido de bienvenida, si procede. */
    public static void playIntro(Context context) {
        if (context == null) return;
        if (!PrefsManager.get(context).isIntroSoundEnabled()) return;
        if (isSilent(context)) return;

        try {
            final MediaPlayer player = MediaPlayer.create(
                    context.getApplicationContext(), R.raw.intro_skillswap);
            if (player == null) return;

            player.setAudioAttributes(new AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build());

            player.setOnCompletionListener(MediaPlayer::release);
            player.setOnErrorListener((mp, what, extra) -> {
                mp.release();
                return true;
            });
            player.start();
        } catch (Exception e) {
            // El sonido es un adorno: si falla, la app sigue igual.
        }
    }

    /** true si el telefono esta en silencio o en vibracion. */
    private static boolean isSilent(Context context) {
        AudioManager audio =
                (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
        if (audio == null) return false;
        int mode = audio.getRingerMode();
        return mode == AudioManager.RINGER_MODE_SILENT
                || mode == AudioManager.RINGER_MODE_VIBRATE;
    }
}
