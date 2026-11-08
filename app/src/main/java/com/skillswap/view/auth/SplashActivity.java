package com.skillswap.view.auth;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.skillswap.databinding.ActivitySplashBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.repository.UserRepository;
import com.skillswap.utils.SoundPlayer;
import com.skillswap.view.MainActivity;

/** Pantalla de bienvenida: decide a donde ir segun la sesion. */
public class SplashActivity extends AppCompatActivity {

    private static final long DELAY = 1400L;

    private ActivitySplashBinding binding;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivitySplashBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        // Sonido de bienvenida. No suena si el telefono esta en silencio
        // ni si el usuario lo desactivo desde su perfil.
        SoundPlayer.playIntro(this);

        new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
            @Override
            public void run() {
                route();
            }
        }, DELAY);
    }

    /**
     * Con sesion abierta se entra directo a la app. Sin sesion siempre se pasa
     * por la introduccion, no solo la primera vez: asi quien cierra sesion y
     * vuelve a abrir la app vuelve a ver de que trata SkillSwap antes del login.
     */
    private void route() {
        Intent intent;
        if (FirebaseManager.isLogged()) {
            UserRepository.get().listenCurrentUser();
            intent = new Intent(this, MainActivity.class);
        } else {
            intent = new Intent(this, OnboardingActivity.class);
        }
        startActivity(intent);
        finish();
    }
}
