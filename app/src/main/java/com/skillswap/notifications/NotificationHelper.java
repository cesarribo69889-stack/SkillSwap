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
        int flags = PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE;
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
