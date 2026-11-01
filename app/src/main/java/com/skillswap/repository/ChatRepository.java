package com.skillswap.repository;

import androidx.annotation.Nullable;

import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.ListenerRegistration;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.skillswap.firebase.FirestoreCollections;
import com.skillswap.model.AppNotification;
import com.skillswap.model.Chat;
import com.skillswap.model.ChatMessage;
import com.skillswap.model.Exchange;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Chat en tiempo real con Cloud Firestore.
 * El chat SOLO se crea cuando existe un intercambio aceptado.
 */
public class ChatRepository {

    private static ChatRepository instance;

    public static synchronized ChatRepository get() {
        if (instance == null) instance = new ChatRepository();
        return instance;
    }

    private ChatRepository() {
    }

    /** Crea el chat asociado a un intercambio aceptado. */
    public void createChat(final Exchange ex, final RepoCallback<Chat> callback) {
        final DocumentReference ref = FirestoreCollections.chats().document(ex.getId());
        final Chat chat = new Chat();
        chat.setId(ref.getId());
        chat.setExchangeId(ex.getId());
        chat.setParticipants(new ArrayList<>(Arrays.asList(ex.getUserAId(), ex.getUserBId())));

        Map<String, String> names = new HashMap<>();
        names.put(ex.getUserAId(), ex.getUserAName());
        names.put(ex.getUserBId(), ex.getUserBName());
        chat.setNames(names);

        Map<String, String> photos = new HashMap<>();
        photos.put(ex.getUserAId(), ex.getUserAPhoto());
        photos.put(ex.getUserBId(), ex.getUserBPhoto());
        chat.setPhotos(photos);

        Map<String, Long> unread = new HashMap<>();
        unread.put(ex.getUserAId(), 0L);
        unread.put(ex.getUserBId(), 0L);
        chat.setUnread(unread);

        chat.setEnabled(true);
        chat.setLastMessage("Intercambio aceptado. ¡Coordinen su primera sesión!");
        chat.setLastMessageAt(System.currentTimeMillis());
        chat.setCreatedAt(chat.getLastMessageAt());

        ref.set(chat)
                .addOnSuccessListener(unused -> {
                    ChatMessage welcome = new ChatMessage();
                    welcome.setChatId(chat.getId());
                    welcome.setSenderId("system");
                    welcome.setSenderName("SkillSwap");
                    welcome.setType(ChatMessage.TYPE_SYSTEM);
                    welcome.setText("Intercambio creado: " + ex.getSkillFromA()
                            + " ⇄ " + ex.getSkillFromB());
                    welcome.setTimestamp(System.currentTimeMillis());
                    DocumentReference mref = FirestoreCollections.messages(chat.getId()).document();
                    welcome.setId(mref.getId());
                    mref.set(welcome);
                    callback.onSuccess(chat);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    /** Lista de conversaciones del usuario, en tiempo real. */
    public ListenerRegistration listenChats(String uid, final RepoCallback<List<Chat>> callback) {
        return FirestoreCollections.chats()
                .whereArrayContains("participants", uid)
                .limit(100)
                .addSnapshotListener(new EventListener<QuerySnapshot>() {
                    @Override
                    public void onEvent(@Nullable QuerySnapshot snapshots,
                                        @Nullable FirebaseFirestoreException e) {
                        if (e != null) {
                            callback.onError(FirebaseErrors.translate(e));
                            return;
                        }
                        List<Chat> list = new ArrayList<>();
                        if (snapshots != null) {
                            for (QueryDocumentSnapshot doc : snapshots) {
                                Chat c = doc.toObject(Chat.class);
                                c.setId(doc.getId());
                                list.add(c);
                            }
                        }
                        Collections.sort(list, new Comparator<Chat>() {
                            @Override
                            public int compare(Chat a, Chat b) {
                                return Long.compare(b.getLastMessageAt(), a.getLastMessageAt());
                            }
                        });
                        callback.onSuccess(list);
                    }
                });
    }

    /** Mensajes de una conversacion, en tiempo real. */
    public ListenerRegistration listenMessages(String chatId, final RepoCallback<List<ChatMessage>> callback) {
        return FirestoreCollections.messages(chatId)
                .orderBy("timestamp", Query.Direction.ASCENDING)
                .limitToLast(300)
                .addSnapshotListener(new EventListener<QuerySnapshot>() {
                    @Override
                    public void onEvent(@Nullable QuerySnapshot snapshots,
                                        @Nullable FirebaseFirestoreException e) {
                        if (e != null) {
                            callback.onError(FirebaseErrors.translate(e));
                            return;
                        }
                        List<ChatMessage> list = new ArrayList<>();
                        if (snapshots != null) {
                            for (QueryDocumentSnapshot doc : snapshots) {
                                ChatMessage m = doc.toObject(ChatMessage.class);
                                m.setId(doc.getId());
                                list.add(m);
                            }
                        }
                        callback.onSuccess(list);
                    }
                });
    }

    public ListenerRegistration listenChat(String chatId, final RepoCallback<Chat> callback) {
        return FirestoreCollections.chats().document(chatId)
                .addSnapshotListener((snapshot, e) -> {
                    if (e != null || snapshot == null || !snapshot.exists()) return;
                    Chat c = snapshot.toObject(Chat.class);
                    if (c != null) {
                        c.setId(snapshot.getId());
                        callback.onSuccess(c);
                    }
                });
    }

    /** Envia un mensaje y actualiza el resumen de la conversacion. */
    public void sendMessage(final Chat chat, final String senderId, final String senderName,
                            final String senderPhoto, final String text,
                            final RepoCallback<Boolean> callback) {
        if (chat == null) {
            callback.onError("Conversación no disponible");
            return;
        }
        if (text == null || text.trim().isEmpty()) {
            callback.onError("Escribe un mensaje");
            return;
        }
        if (!chat.isEnabled()) {
            callback.onError("El chat está deshabilitado para este intercambio");
            return;
        }

        final ChatMessage msg = new ChatMessage(chat.getId(), senderId, senderName, senderPhoto, text.trim());
        DocumentReference ref = FirestoreCollections.messages(chat.getId()).document();
        msg.setId(ref.getId());

        final String partnerId = chat.getPartnerId(senderId);

        ref.set(msg)
                .addOnSuccessListener(unused -> {
                    Map<String, Object> data = new HashMap<>();
                    data.put("lastMessage", msg.getText());
                    data.put("lastSenderId", senderId);
                    data.put("lastMessageAt", msg.getTimestamp());
                    data.put("unread." + partnerId, FieldValue.increment(1));
                    FirestoreCollections.chats().document(chat.getId()).update(data);

                    NotificationRepository.get().push(partnerId,
                            AppNotification.TYPE_NEW_MESSAGE,
                            "Nuevo mensaje de " + senderName,
                            msg.getText(),
                            chat.getId());

                    callback.onSuccess(Boolean.TRUE);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    public void markRead(String chatId, String uid) {
        if (chatId == null || chatId.isEmpty() || uid == null || uid.isEmpty()) return;
        Map<String, Object> data = new HashMap<>();
        data.put("unread." + uid, 0L);
        FirestoreCollections.chats().document(chatId).update(data);
    }

    public void fetchChat(String chatId, final RepoCallback<Chat> callback) {
        FirestoreCollections.chats().document(chatId).get()
                .addOnSuccessListener(doc -> {
                    if (!doc.exists()) {
                        callback.onError("Esta conversación aún no está disponible");
                        return;
                    }
                    Chat c = doc.toObject(Chat.class);
                    if (c != null) c.setId(doc.getId());
                    callback.onSuccess(c);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }
}
