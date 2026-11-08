package com.skillswap.utils;

import android.content.Context;
import android.content.SharedPreferences;

/** Preferencias locales ligeras (onboarding, cache de nombre). */
public class PrefsManager {

    private static final String FILE = "skillswap_prefs";
    private static final String KEY_ONBOARDING = "onboarding_done";
    private static final String KEY_NAME = "cached_name";
    private static final String KEY_PHOTO = "cached_photo";
    private static final String KEY_INTRO_SOUND = "intro_sound";

    private static PrefsManager instance;
    private final SharedPreferences prefs;

    private PrefsManager(Context context) {
        prefs = context.getApplicationContext().getSharedPreferences(FILE, Context.MODE_PRIVATE);
    }

    public static synchronized PrefsManager get(Context context) {
        if (instance == null) instance = new PrefsManager(context);
        return instance;
    }

    public boolean isOnboardingDone() {
        return prefs.getBoolean(KEY_ONBOARDING, false);
    }

    public void setOnboardingDone(boolean done) {
        prefs.edit().putBoolean(KEY_ONBOARDING, done).apply();
    }

    /** Sonido de bienvenida al abrir la app. Activado por defecto. */
    public boolean isIntroSoundEnabled() {
        return prefs.getBoolean(KEY_INTRO_SOUND, true);
    }

    public void setIntroSoundEnabled(boolean enabled) {
        prefs.edit().putBoolean(KEY_INTRO_SOUND, enabled).apply();
    }

    public String getCachedName() {
        return prefs.getString(KEY_NAME, "");
    }

    public void setCachedName(String name) {
        prefs.edit().putString(KEY_NAME, name == null ? "" : name).apply();
    }

    public String getCachedPhoto() {
        return prefs.getString(KEY_PHOTO, "");
    }

    public void setCachedPhoto(String url) {
        prefs.edit().putString(KEY_PHOTO, url == null ? "" : url).apply();
    }

    public void clear() {
        // Las preferencias del dispositivo sobreviven al cierre de sesion:
        // no son datos de la cuenta.
        boolean onboarding = isOnboardingDone();
        boolean sonido = isIntroSoundEnabled();
        prefs.edit().clear()
                .putBoolean(KEY_ONBOARDING, onboarding)
                .putBoolean(KEY_INTRO_SOUND, sonido)
                .apply();
    }
}
