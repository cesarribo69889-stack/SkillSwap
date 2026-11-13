package com.skillswap;

import android.app.Application;
import android.content.Context;

import com.skillswap.firebase.FirebaseManager;
import com.skillswap.notifications.NotificationHelper;
import com.skillswap.repository.RepoCallback;
import com.skillswap.repository.SkillRepository;
import com.skillswap.repository.UserRepository;

/** Clase Application de SkillSwap. */
public class SkillSwapApp extends Application {

    /**
     * Contexto de aplicacion para los repositorios, que son singletons y no
     * reciben Context. Es el de la Application (no el de una Activity), asi
     * que no retiene ninguna pantalla ni provoca fugas de memoria.
     */
    private static Context contexto;

    public static Context contexto() {
        return contexto;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        contexto = getApplicationContext();

        NotificationHelper.createChannels(this);

        if (FirebaseManager.isLogged()) {
            UserRepository.get().listenCurrentUser();
        }

        // Publica el catalogo de habilidades la primera vez que se ejecuta.
        SkillRepository.get().seedCatalog(new RepoCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
            }

            @Override
            public void onError(String message) {
            }
        });
    }
}
