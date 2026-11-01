package com.skillswap;

import android.app.Application;

import com.skillswap.firebase.FirebaseManager;
import com.skillswap.notifications.NotificationHelper;
import com.skillswap.repository.RepoCallback;
import com.skillswap.repository.SkillRepository;
import com.skillswap.repository.UserRepository;

/** Clase Application de SkillSwap. */
public class SkillSwapApp extends Application {

    @Override
    public void onCreate() {
        super.onCreate();

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
