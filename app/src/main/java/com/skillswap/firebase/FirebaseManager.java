package com.skillswap.firebase;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.FirebaseFirestoreSettings;
import com.google.firebase.storage.FirebaseStorage;

/** Punto unico de acceso a las instancias de Firebase. */
public final class FirebaseManager {

    /**
     * Los objetos de Firebase ya son singletons internos del SDK, por eso no
     * se cachean aqui: guardarlos en campos estaticos retendria un Context
     * innecesariamente. Solo se recuerda si los ajustes ya se aplicaron,
     * porque setFirestoreSettings falla si se llama despues del primer uso.
     */
    private static boolean settingsApplied = false;

    private FirebaseManager() {
    }

    public static synchronized FirebaseFirestore db() {
        FirebaseFirestore firestore = FirebaseFirestore.getInstance();
        if (!settingsApplied) {
            settingsApplied = true;
            FirebaseFirestoreSettings settings = new FirebaseFirestoreSettings.Builder()
                    .setPersistenceEnabled(true)
                    .build();
            try {
                firestore.setFirestoreSettings(settings);
            } catch (Exception ignored) {
                // Los ajustes solo pueden aplicarse antes del primer uso.
            }
        }
        return firestore;
    }

    public static FirebaseAuth auth() {
        return FirebaseAuth.getInstance();
    }

    public static FirebaseStorage storage() {
        return FirebaseStorage.getInstance();
    }

    public static FirebaseUser currentUser() {
        return auth().getCurrentUser();
    }

    public static String uid() {
        FirebaseUser u = currentUser();
        return u == null ? "" : u.getUid();
    }

    public static boolean isLogged() {
        return currentUser() != null;
    }
}
