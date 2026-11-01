package com.skillswap.utils;

import android.util.Patterns;

import com.google.android.material.textfield.TextInputLayout;

/** Validaciones de formularios. Devuelven null si el valor es valido. */
public final class Validators {

    private Validators() {
    }

    public static String validateName(String value) {
        if (isEmpty(value)) return "Este campo es obligatorio";
        String v = value.trim();
        if (v.length() < 2) return "Mínimo 2 caracteres";
        if (!v.matches("[A-Za-zÁÉÍÓÚáéíóúÑñ\\s'.-]+")) return "Sólo se permiten letras";
        return null;
    }

    public static String validateEmail(String value) {
        if (isEmpty(value)) return "El correo es obligatorio";
        if (!Patterns.EMAIL_ADDRESS.matcher(value.trim()).matches()) {
            return "Correo electrónico no válido";
        }
        return null;
    }

    public static String validatePassword(String value) {
        if (isEmpty(value)) return "La contraseña es obligatoria";
        if (value.length() < Constants.MIN_PASSWORD_LENGTH) {
            return "Mínimo " + Constants.MIN_PASSWORD_LENGTH + " caracteres";
        }
        boolean hasLetter = value.matches(".*[A-Za-z].*");
        boolean hasDigit = value.matches(".*\\d.*");
        if (!hasLetter || !hasDigit) return "Debe incluir letras y números";
        return null;
    }

    public static String validateConfirmPassword(String password, String confirm) {
        if (isEmpty(confirm)) return "Confirma tu contraseña";
        if (!confirm.equals(password)) return "Las contraseñas no coinciden";
        return null;
    }

    public static String validateRequired(String value, String label) {
        if (isEmpty(value)) return label + " es obligatorio";
        return null;
    }

    public static String validateMinLength(String value, int min, String label) {
        if (isEmpty(value)) return label + " es obligatorio";
        if (value.trim().length() < min) return label + " debe tener al menos " + min + " caracteres";
        return null;
    }

    public static String validateIntRange(String value, int min, int max, String label) {
        if (isEmpty(value)) return label + " es obligatorio";
        try {
            int n = Integer.parseInt(value.trim());
            if (n < min || n > max) return label + " debe estar entre " + min + " y " + max;
        } catch (NumberFormatException e) {
            return label + " debe ser un número";
        }
        return null;
    }

    public static boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }

    /** Aplica el error al TextInputLayout y devuelve true si es valido. */
    public static boolean apply(TextInputLayout layout, String error) {
        if (layout == null) return error == null;
        layout.setError(error);
        layout.setErrorEnabled(error != null);
        return error == null;
    }

    public static String text(TextInputLayout layout) {
        if (layout == null || layout.getEditText() == null) return "";
        return layout.getEditText().getText() == null ? "" : layout.getEditText().getText().toString();
    }
}
