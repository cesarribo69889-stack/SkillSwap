package com.skillswap.repository;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseUser;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.User;
import com.skillswap.utils.GamificationEngine;
import com.skillswap.utils.Validators;

/** Autenticacion con Firebase Authentication. */
public class AuthRepository {

    private static AuthRepository instance;

    public static synchronized AuthRepository get() {
        if (instance == null) instance = new AuthRepository();
        return instance;
    }

    private AuthRepository() {
    }

    public boolean isLogged() {
        return FirebaseManager.isLogged();
    }

    public String currentUid() {
        return FirebaseManager.uid();
    }

    /** Registro con correo y contrasena + creacion del documento de usuario. */
    public void register(final String firstName, final String lastName,
                         final String email, final String password,
                         final RepoCallback<User> callback) {

        String err = Validators.validateEmail(email);
        if (err == null) err = Validators.validatePassword(password);
        if (err != null) {
            callback.onError(err);
            return;
        }

        FirebaseManager.auth()
                .createUserWithEmailAndPassword(email.trim(), password)
                .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        if (!task.isSuccessful()) {
                            callback.onError(FirebaseErrors.translate(task.getException()));
                            return;
                        }
                        FirebaseUser fu = FirebaseManager.currentUser();
                        if (fu == null) {
                            callback.onError("No se pudo crear la cuenta");
                            return;
                        }
                        User user = new User(fu.getUid(), firstName.trim(), lastName.trim(), email.trim());
                        user.setGamificationLevel(GamificationEngine.LEVEL_BEGINNER);
                        UserRepository.get().createUser(user, callback);
                    }
                });
    }

    public void login(final String email, final String password, final RepoCallback<User> callback) {
        String err = Validators.validateEmail(email);
        if (err != null) {
            callback.onError(err);
            return;
        }
        if (Validators.isEmpty(password)) {
            callback.onError("La contraseña es obligatoria");
            return;
        }

        FirebaseManager.auth()
                .signInWithEmailAndPassword(email.trim(), password)
                .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        if (!task.isSuccessful()) {
                            callback.onError(FirebaseErrors.translate(task.getException()));
                            return;
                        }
                        UserRepository.get().fetchUser(FirebaseManager.uid(), callback);
                    }
                });
    }

    public void resetPassword(final String email, final RepoCallback<Boolean> callback) {
        String err = Validators.validateEmail(email);
        if (err != null) {
            callback.onError(err);
            return;
        }
        FirebaseManager.auth()
                .sendPasswordResetEmail(email.trim())
                .addOnCompleteListener(new OnCompleteListener<Void>() {
                    @Override
                    public void onComplete(@NonNull Task<Void> task) {
                        if (task.isSuccessful()) {
                            callback.onSuccess(Boolean.TRUE);
                        } else {
                            callback.onError(FirebaseErrors.translate(task.getException()));
                        }
                    }
                });
    }

    public void logout() {
        UserRepository.get().clearCache();
        FirebaseManager.auth().signOut();
    }
}
