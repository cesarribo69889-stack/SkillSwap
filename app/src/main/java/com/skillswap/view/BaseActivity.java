package com.skillswap.view;

import android.view.View;

import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.appbar.MaterialToolbar;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.skillswap.utils.UiUtils;

/** Utilidades comunes a todas las Activities. */
public abstract class BaseActivity extends AppCompatActivity {

    /** Configura una toolbar con titulo y navegacion hacia atras. */
    protected void setupToolbar(MaterialToolbar toolbar, String title) {
        if (toolbar == null) return;
        toolbar.setTitle(title);
        toolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
    }

    protected void toast(View root, String message) {
        UiUtils.snack(root, message);
    }

    protected void confirm(String title, String message, String positive, final Runnable action) {
        new MaterialAlertDialogBuilder(this)
                .setTitle(title)
                .setMessage(message)
                .setNegativeButton("Cancelar", null)
                .setPositiveButton(positive, (dialog, which) -> {
                    if (action != null) action.run();
                })
                .show();
    }

    protected void info(String title, String message) {
        new MaterialAlertDialogBuilder(this)
                .setTitle(title)
                .setMessage(message)
                .setPositiveButton("Entendido", null)
                .show();
    }
}
