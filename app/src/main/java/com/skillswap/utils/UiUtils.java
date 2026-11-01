package com.skillswap.utils;

import android.content.Context;
import android.content.res.ColorStateList;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.TextView;

import androidx.core.content.ContextCompat;

import com.google.android.material.snackbar.Snackbar;
import com.skillswap.R;
import com.skillswap.model.Exchange;
import com.skillswap.model.ExchangeRequest;

/** Utilidades de interfaz: colores de estado, snackbars, teclado. */
public final class UiUtils {

    private UiUtils() {
    }

    // ---------- Estados de solicitud / intercambio ----------
    public static int stateColor(String status) {
        if (status == null) return R.color.state_cancelled;
        switch (status) {
            case ExchangeRequest.STATUS_PENDING:
                return R.color.state_pending;
            case ExchangeRequest.STATUS_ACCEPTED:
                return R.color.state_accepted;
            case ExchangeRequest.STATUS_REJECTED:
                return R.color.state_rejected;
            case ExchangeRequest.STATUS_CANCELLED:
            case Exchange.STATUS_CANCELLED:
                return R.color.state_cancelled;
            case ExchangeRequest.STATUS_IN_PROGRESS:
                return R.color.state_progress;
            case ExchangeRequest.STATUS_COMPLETED:
            case Exchange.STATUS_COMPLETED:
                return R.color.state_completed;
            case Exchange.STATUS_UPCOMING:
                return R.color.state_pending;
            default:
                return R.color.state_cancelled;
        }
    }

    public static int stateBackground(String status) {
        if (status == null) return R.color.state_cancelled_bg;
        switch (status) {
            case ExchangeRequest.STATUS_PENDING:
            case Exchange.STATUS_UPCOMING:
                return R.color.state_pending_bg;
            case ExchangeRequest.STATUS_ACCEPTED:
                return R.color.state_accepted_bg;
            case ExchangeRequest.STATUS_REJECTED:
                return R.color.state_rejected_bg;
            case ExchangeRequest.STATUS_IN_PROGRESS:
                return R.color.state_progress_bg;
            case ExchangeRequest.STATUS_COMPLETED:
            case Exchange.STATUS_COMPLETED:
                return R.color.state_completed_bg;
            default:
                return R.color.state_cancelled_bg;
        }
    }

    public static String stateLabel(String status) {
        if (status == null) return "";
        switch (status) {
            case ExchangeRequest.STATUS_IN_PROGRESS:
                return "En proceso";
            case Exchange.STATUS_UPCOMING:
                return "Próximo";
            case Exchange.STATUS_COMPLETED:
                return "Completado";
            case Exchange.STATUS_CANCELLED:
                return "Cancelado";
            case ExchangeRequest.STATUS_PENDING:
                return "Pendiente";
            case ExchangeRequest.STATUS_ACCEPTED:
                return "Aceptada";
            case ExchangeRequest.STATUS_REJECTED:
                return "Rechazada";
            case ExchangeRequest.STATUS_CANCELLED:
                return "Cancelada";
            case ExchangeRequest.STATUS_COMPLETED:
                return "Completada";
            default:
                return status;
        }
    }

    /** Pinta un TextView como pildora de estado. */
    public static void bindStatePill(TextView view, String status) {
        if (view == null) return;
        Context c = view.getContext();
        view.setText(stateLabel(status));
        view.setTextColor(ContextCompat.getColor(c, stateColor(status)));
        view.setBackgroundResource(R.drawable.bg_pill);
        view.setBackgroundTintList(ColorStateList.valueOf(
                ContextCompat.getColor(c, stateBackground(status))));
    }

    // ---------- Niveles ----------
    public static int levelColor(String level) {
        if (level == null) return R.color.level_basic;
        if (level.startsWith("Av")) return R.color.level_advanced;
        if (level.startsWith("Int")) return R.color.level_intermediate;
        return R.color.level_basic;
    }

    // ---------- Compatibilidad ----------
    public static int compatibilityColor(int score) {
        if (score >= 85) return R.color.state_accepted;
        if (score >= 65) return R.color.brand_primary;
        if (score >= 45) return R.color.state_pending;
        return R.color.state_cancelled;
    }

    public static String compatibilityLabel(int score) {
        if (score >= 90) return "Match excelente";
        if (score >= 75) return "Muy compatible";
        if (score >= 60) return "Buena opción";
        if (score >= 40) return "Compatibilidad media";
        return "Compatibilidad baja";
    }

    // ---------- Helpers ----------
    public static void snack(View root, String message) {
        if (root == null || message == null) return;
        Snackbar bar = Snackbar.make(root, message, Snackbar.LENGTH_LONG);
        // Por defecto el Snackbar corta a 2 lineas; varios mensajes de error
        // son mas largos y quedarian truncados.
        TextView text = bar.getView().findViewById(
                com.google.android.material.R.id.snackbar_text);
        if (text != null) text.setMaxLines(5);
        bar.show();
    }

    public static void hideKeyboard(View view) {
        if (view == null) return;
        InputMethodManager imm = (InputMethodManager)
                view.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm != null) imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
    }

    public static void visible(View v, boolean show) {
        if (v != null) v.setVisibility(show ? View.VISIBLE : View.GONE);
    }

    public static int dp(Context context, int value) {
        return Math.round(value * context.getResources().getDisplayMetrics().density);
    }
}
