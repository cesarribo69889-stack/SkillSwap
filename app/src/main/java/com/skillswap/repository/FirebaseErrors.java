package com.skillswap.repository;

import com.google.firebase.auth.FirebaseAuthInvalidCredentialsException;
import com.google.firebase.auth.FirebaseAuthInvalidUserException;
import com.google.firebase.auth.FirebaseAuthUserCollisionException;
import com.google.firebase.auth.FirebaseAuthWeakPasswordException;

/** Traduce los errores de Firebase a mensajes en espanol. */
public final class FirebaseErrors {

    private FirebaseErrors() {
    }

    public static String translate(Exception e) {
        if (e == null) return "Ocurrió un error inesperado";
        if (e instanceof FirebaseAuthWeakPasswordException) {
            return "La contraseña es demasiado débil";
        }
        if (e instanceof FirebaseAuthUserCollisionException) {
            return "Ya existe una cuenta con ese correo";
        }
        if (e instanceof FirebaseAuthInvalidCredentialsException) {
            return "Correo o contraseña incorrectos";
        }
        if (e instanceof FirebaseAuthInvalidUserException) {
            return "No encontramos una cuenta con ese correo";
        }
        String msg = e.getMessage();
        if (msg == null || msg.isEmpty()) return "Ocurrió un error inesperado";

        // --- Configuración de Firebase incompleta -------------------------
        if (msg.contains("API key not valid") || msg.contains("API_KEY_INVALID")) {
            return "La configuración de Firebase no es válida. Reemplaza "
                    + "app/google-services.json por el de tu proyecto y vuelve a compilar";
        }
        if (msg.contains("has not been used in project") || msg.contains("it is disabled")) {
            return "Falta habilitar este servicio en la consola de Firebase";
        }
        if (msg.contains("CONFIGURATION_NOT_FOUND")) {
            return "Activa el proveedor Correo/contraseña en Firebase Authentication";
        }

        // --- Errores habituales de uso ------------------------------------
        if (msg.contains("network") || msg.contains("Network")
                || msg.contains("UNAVAILABLE")) {
            return "Sin conexión a internet. Inténtalo de nuevo";
        }
        if (msg.contains("PERMISSION_DENIED")) {
            return "No tienes permisos para realizar esta acción";
        }
        if (msg.contains("FAILED_PRECONDITION") && msg.contains("index")) {
            return "Falta crear un índice en Firestore. Revisa el enlace en Logcat";
        }
        if (msg.contains("blocked all requests") || msg.contains("unusual activity")) {
            return "Demasiados intentos. Espera unos minutos e inténtalo de nuevo";
        }
        if (msg.contains("An internal error has occurred")) {
            return "Error interno de Firebase. Revisa tu configuración y tu conexión";
        }
        return msg;
    }
}
