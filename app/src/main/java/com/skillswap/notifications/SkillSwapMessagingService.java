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
