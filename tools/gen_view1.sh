#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
mkdir -p "$J/view/auth" "$J/notifications"

# ============================================================ SkillSwapApp
cat > "$J/SkillSwapApp.java" <<'EOF'
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
EOF

# ============================================================ NotificationHelper
cat > "$J/notifications/NotificationHelper.java" <<'EOF'
package com.skillswap.notifications;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.core.content.ContextCompat;

import com.skillswap.R;
import com.skillswap.model.AppNotification;
import com.skillswap.utils.Constants;
import com.skillswap.view.MainActivity;
import com.skillswap.view.chat.ChatActivity;
import com.skillswap.view.exchange.ExchangeDetailActivity;
import com.skillswap.view.exchange.RequestsActivity;
import com.skillswap.view.notifications.NotificationsActivity;

/** Construye y muestra las notificaciones del sistema. */
public final class NotificationHelper {

    private NotificationHelper() {
    }

    public static void createChannels(Context context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return;

        NotificationManager manager = context.getSystemService(NotificationManager.class);
        if (manager == null) return;

        NotificationChannel general = new NotificationChannel(
                Constants.CHANNEL_GENERAL,
                context.getString(R.string.channel_general_name),
                NotificationManager.IMPORTANCE_DEFAULT);
        general.setDescription(context.getString(R.string.channel_general_desc));

        NotificationChannel chat = new NotificationChannel(
                Constants.CHANNEL_CHAT,
                context.getString(R.string.channel_chat_name),
                NotificationManager.IMPORTANCE_HIGH);
        chat.setDescription(context.getString(R.string.channel_chat_desc));

        manager.createNotificationChannel(general);
        manager.createNotificationChannel(chat);
    }

    public static void show(Context context, String type, String title, String body,
                            String referenceId) {
        String channel = AppNotification.TYPE_NEW_MESSAGE.equals(type)
                ? Constants.CHANNEL_CHAT : Constants.CHANNEL_GENERAL;

        Intent intent = intentFor(context, type, referenceId);
        int flags = PendingIntent.FLAG_UPDATE_CURRENT;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            flags |= PendingIntent.FLAG_IMMUTABLE;
        }
        PendingIntent pending = PendingIntent.getActivity(
                context, (int) (System.currentTimeMillis() % 100000), intent, flags);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, channel)
                .setSmallIcon(R.drawable.ic_logo)
                .setColor(ContextCompat.getColor(context, R.color.brand_primary))
                .setContentTitle(title)
                .setContentText(body)
                .setStyle(new NotificationCompat.BigTextStyle().bigText(body))
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setContentIntent(pending);

        try {
            NotificationManagerCompat.from(context)
                    .notify((int) (System.currentTimeMillis() % 100000), builder.build());
        } catch (SecurityException ignored) {
            // El usuario no concedio POST_NOTIFICATIONS.
        }
    }

    /** Pantalla que se abre al tocar la notificacion. */
    private static Intent intentFor(Context context, String type, String referenceId) {
        Intent intent;
        if (type == null) type = "";

        switch (type) {
            case AppNotification.TYPE_NEW_MESSAGE:
                intent = new Intent(context, ChatActivity.class);
                intent.putExtra(Constants.EXTRA_CHAT_ID, referenceId);
                break;
            case AppNotification.TYPE_NEW_REQUEST:
                intent = new Intent(context, RequestsActivity.class);
                break;
            case AppNotification.TYPE_REQUEST_ACCEPTED:
            case AppNotification.TYPE_EXCHANGE_COMPLETED:
                intent = new Intent(context, ExchangeDetailActivity.class);
                intent.putExtra(Constants.EXTRA_EXCHANGE_ID, referenceId);
                break;
            case AppNotification.TYPE_NEW_MATCH:
                intent = new Intent(context, MainActivity.class);
                intent.putExtra(Constants.EXTRA_OPEN_SECTION, "explore");
                break;
            default:
                intent = new Intent(context, NotificationsActivity.class);
                break;
        }
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
        return intent;
    }
}
EOF

# ============================================================ SkillSwapMessagingService
cat > "$J/notifications/SkillSwapMessagingService.java" <<'EOF'
package com.skillswap.notifications;

import androidx.annotation.NonNull;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.repository.UserRepository;

import java.util.Map;

/**
 * Recibe los mensajes de Firebase Cloud Messaging.
 *
 * El payload esperado incluye los campos de datos:
 *   type        -> NEW_REQUEST | REQUEST_ACCEPTED | NEW_MESSAGE | ...
 *   title       -> titulo visible
 *   body        -> cuerpo visible
 *   referenceId -> id del intercambio / chat / solicitud
 */
public class SkillSwapMessagingService extends FirebaseMessagingService {

    @Override
    public void onNewToken(@NonNull String token) {
        super.onNewToken(token);
        String uid = FirebaseManager.uid();
        if (!uid.isEmpty()) {
            UserRepository.get().updateFcmToken(uid, token);
        }
    }

    @Override
    public void onMessageReceived(@NonNull RemoteMessage message) {
        super.onMessageReceived(message);

        String type = "";
        String title = "SkillSwap";
        String body = "";
        String referenceId = "";

        Map<String, String> data = message.getData();
        if (data.containsKey("type")) type = data.get("type");
        if (data.containsKey("title")) title = data.get("title");
        if (data.containsKey("body")) body = data.get("body");
        if (data.containsKey("referenceId")) referenceId = data.get("referenceId");

        RemoteMessage.Notification n = message.getNotification();
        if (n != null) {
            if (n.getTitle() != null) title = n.getTitle();
            if (n.getBody() != null) body = n.getBody();
        }

        if (body == null || body.isEmpty()) return;
        NotificationHelper.show(this, type, title, body, referenceId);
    }
}
EOF

# ============================================================ BaseActivity
cat > "$J/view/BaseActivity.java" <<'EOF'
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
EOF

# ============================================================ SplashActivity
cat > "$J/view/auth/SplashActivity.java" <<'EOF'
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
import com.skillswap.utils.PrefsManager;
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

        new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
            @Override
            public void run() {
                route();
            }
        }, DELAY);
    }

    private void route() {
        Intent intent;
        if (!PrefsManager.get(this).isOnboardingDone()) {
            intent = new Intent(this, OnboardingActivity.class);
        } else if (FirebaseManager.isLogged()) {
            UserRepository.get().listenCurrentUser();
            intent = new Intent(this, MainActivity.class);
        } else {
            intent = new Intent(this, LoginActivity.class);
        }
        startActivity(intent);
        finish();
    }
}
EOF

# ============================================================ OnboardingActivity
cat > "$J/view/auth/OnboardingActivity.java" <<'EOF'
package com.skillswap.view.auth;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.LinearLayout;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.viewpager2.widget.ViewPager2;

import com.skillswap.R;
import com.skillswap.adapter.OnboardingAdapter;
import com.skillswap.databinding.ActivityOnboardingBinding;
import com.skillswap.utils.PrefsManager;
import com.skillswap.utils.UiUtils;

/** Onboarding de 3 pantallas. */
public class OnboardingActivity extends AppCompatActivity {

    private ActivityOnboardingBinding binding;
    private OnboardingAdapter adapter;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityOnboardingBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        adapter = new OnboardingAdapter();
        binding.pager.setAdapter(adapter);

        buildDots();
        selectDot(0);

        binding.pager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                selectDot(position);
                binding.btnNext.setText(position == adapter.getItemCount() - 1
                        ? R.string.start : R.string.continue_label);
            }
        });

        binding.btnNext.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int current = binding.pager.getCurrentItem();
                if (current < adapter.getItemCount() - 1) {
                    binding.pager.setCurrentItem(current + 1, true);
                } else {
                    finishOnboarding();
                }
            }
        });

        binding.btnSkip.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finishOnboarding();
            }
        });
    }

    private void buildDots() {
        binding.dots.removeAllViews();
        for (int i = 0; i < adapter.getItemCount(); i++) {
            View dot = new View(this);
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(
                    UiUtils.dp(this, 8), UiUtils.dp(this, 8));
            params.setMarginEnd(UiUtils.dp(this, 6));
            dot.setLayoutParams(params);
            dot.setBackgroundResource(R.drawable.bg_dot_default);
            binding.dots.addView(dot);
        }
    }

    private void selectDot(int index) {
        for (int i = 0; i < binding.dots.getChildCount(); i++) {
            View dot = binding.dots.getChildAt(i);
            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) dot.getLayoutParams();
            params.width = UiUtils.dp(this, i == index ? 24 : 8);
            dot.setLayoutParams(params);
            dot.setBackgroundResource(i == index
                    ? R.drawable.bg_dot_selected : R.drawable.bg_dot_default);
        }
    }

    private void finishOnboarding() {
        PrefsManager.get(this).setOnboardingDone(true);
        startActivity(new Intent(this, LoginActivity.class));
        finish();
    }
}
EOF

# ============================================================ LoginActivity
cat > "$J/view/auth/LoginActivity.java" <<'EOF'
package com.skillswap.view.auth;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.skillswap.databinding.ActivityLoginBinding;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.utils.UiUtils;
import com.skillswap.utils.Validators;
import com.skillswap.view.MainActivity;
import com.skillswap.viewmodel.AuthViewModel;

/** Inicio de sesion con Firebase Authentication. */
public class LoginActivity extends AppCompatActivity {

    private ActivityLoginBinding binding;
    private AuthViewModel viewModel;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityLoginBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        viewModel = new ViewModelProvider(this).get(AuthViewModel.class);

        binding.btnLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                attemptLogin();
            }
        });

        binding.btnGoRegister.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startActivity(new Intent(LoginActivity.this, RegisterActivity.class));
            }
        });

        binding.btnForgot.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startActivity(new Intent(LoginActivity.this, ForgotPasswordActivity.class));
            }
        });

        viewModel.authState().observe(this, new Observer<Resource<User>>() {
            @Override
            public void onChanged(Resource<User> state) {
                if (state == null) return;
                UiUtils.visible(binding.progress, state.isLoading());
                binding.btnLogin.setEnabled(!state.isLoading());

                if (state.isSuccess()) {
                    startActivity(new Intent(LoginActivity.this, MainActivity.class));
                    finishAffinity();
                } else if (state.isError()) {
                    UiUtils.snack(binding.getRoot(), state.getMessage());
                }
            }
        });
    }

    private void attemptLogin() {
        UiUtils.hideKeyboard(binding.getRoot());

        String email = Validators.text(binding.tilEmail).trim();
        String password = Validators.text(binding.tilPassword);

        boolean ok = Validators.apply(binding.tilEmail, Validators.validateEmail(email));
        ok &= Validators.apply(binding.tilPassword,
                Validators.isEmpty(password) ? "La contraseña es obligatoria" : null);

        if (!ok) return;
        viewModel.login(email, password);
    }
}
EOF

# ============================================================ RegisterActivity
cat > "$J/view/auth/RegisterActivity.java" <<'EOF'
package com.skillswap.view.auth;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.skillswap.databinding.ActivityRegisterBinding;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.utils.UiUtils;
import com.skillswap.utils.Validators;
import com.skillswap.view.profile.EditProfileActivity;
import com.skillswap.viewmodel.AuthViewModel;

/** Registro de estudiantes con validacion completa de campos. */
public class RegisterActivity extends AppCompatActivity {

    private ActivityRegisterBinding binding;
    private AuthViewModel viewModel;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityRegisterBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        viewModel = new ViewModelProvider(this).get(AuthViewModel.class);

        binding.btnBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        binding.btnGoLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        binding.btnRegister.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                attemptRegister();
            }
        });

        viewModel.authState().observe(this, new Observer<Resource<User>>() {
            @Override
            public void onChanged(Resource<User> state) {
                if (state == null) return;
                UiUtils.visible(binding.progress, state.isLoading());
                binding.btnRegister.setEnabled(!state.isLoading());

                if (state.isSuccess()) {
                    // Tras el registro se completa el perfil.
                    Intent intent = new Intent(RegisterActivity.this, EditProfileActivity.class);
                    intent.putExtra(EditProfileActivity.EXTRA_FIRST_TIME, true);
                    startActivity(intent);
                    finishAffinity();
                } else if (state.isError()) {
                    UiUtils.snack(binding.getRoot(), state.getMessage());
                }
            }
        });
    }

    private void attemptRegister() {
        UiUtils.hideKeyboard(binding.getRoot());

        String firstName = Validators.text(binding.tilFirstName).trim();
        String lastName = Validators.text(binding.tilLastName).trim();
        String email = Validators.text(binding.tilEmail).trim();
        String password = Validators.text(binding.tilPassword);
        String confirm = Validators.text(binding.tilConfirm);

        boolean ok = Validators.apply(binding.tilFirstName, Validators.validateName(firstName));
        ok &= Validators.apply(binding.tilLastName, Validators.validateName(lastName));
        ok &= Validators.apply(binding.tilEmail, Validators.validateEmail(email));
        ok &= Validators.apply(binding.tilPassword, Validators.validatePassword(password));
        ok &= Validators.apply(binding.tilConfirm,
                Validators.validateConfirmPassword(password, confirm));

        if (!ok) return;
        viewModel.register(firstName, lastName, email, password);
    }
}
EOF

# ============================================================ ForgotPasswordActivity
cat > "$J/view/auth/ForgotPasswordActivity.java" <<'EOF'
package com.skillswap.view.auth;

import android.os.Bundle;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.skillswap.databinding.ActivityForgotPasswordBinding;
import com.skillswap.model.Resource;
import com.skillswap.utils.UiUtils;
import com.skillswap.utils.Validators;
import com.skillswap.view.BaseActivity;
import com.skillswap.viewmodel.AuthViewModel;

/** Recuperacion de contrasena por correo. */
public class ForgotPasswordActivity extends BaseActivity {

    private ActivityForgotPasswordBinding binding;
    private AuthViewModel viewModel;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityForgotPasswordBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        viewModel = new ViewModelProvider(this).get(AuthViewModel.class);

        binding.btnBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        binding.btnSend.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                UiUtils.hideKeyboard(binding.getRoot());
                String email = Validators.text(binding.tilEmail).trim();
                if (!Validators.apply(binding.tilEmail, Validators.validateEmail(email))) return;
                viewModel.resetPassword(email);
            }
        });

        viewModel.resetState().observe(this, new Observer<Resource<Boolean>>() {
            @Override
            public void onChanged(Resource<Boolean> state) {
                if (state == null) return;
                UiUtils.visible(binding.progress, state.isLoading());
                binding.btnSend.setEnabled(!state.isLoading());

                if (state.isSuccess()) {
                    info("Revisa tu correo",
                            "Te enviamos un enlace para restablecer tu contraseña. "
                                    + "Si no lo ves, revisa la carpeta de spam.");
                } else if (state.isError()) {
                    UiUtils.snack(binding.getRoot(), state.getMessage());
                }
            }
        });
    }
}
EOF

echo "Vistas 1 (app/notificaciones/auth) generadas."
