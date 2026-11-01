package com.skillswap.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/** Documento de la subcoleccion "chats/{chatId}/messages". */
public class ChatMessage implements Serializable {

    public static final String TYPE_TEXT = "TEXT";
    public static final String TYPE_SYSTEM = "SYSTEM";
    public static final String TYPE_IMAGE = "IMAGE";

    private String id = "";
    private String chatId = "";
    private String senderId = "";
    private String senderName = "";
    private String senderPhoto = "";
    private String text = "";
    private String type = TYPE_TEXT;
    private String imageUrl = "";
    private long timestamp = 0L;
    private List<String> readBy = new ArrayList<>();

    public ChatMessage() {
    }

    public ChatMessage(String chatId, String senderId, String senderName, String senderPhoto, String text) {
        this.chatId = chatId;
        this.senderId = senderId;
        this.senderName = senderName;
        this.senderPhoto = senderPhoto;
        this.text = text;
        this.type = TYPE_TEXT;
        this.timestamp = System.currentTimeMillis();
        this.readBy = new ArrayList<>();
        this.readBy.add(senderId);
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getChatId() { return chatId; }
    public void setChatId(String chatId) { this.chatId = chatId; }

    public String getSenderId() { return senderId; }
    public void setSenderId(String senderId) { this.senderId = senderId; }

    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }

    public String getSenderPhoto() { return senderPhoto; }
    public void setSenderPhoto(String senderPhoto) { this.senderPhoto = senderPhoto; }

    public String getText() { return text; }
    public void setText(String text) { this.text = text; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public long getTimestamp() { return timestamp; }
    public void setTimestamp(long timestamp) { this.timestamp = timestamp; }

    public List<String> getReadBy() { return readBy; }
    public void setReadBy(List<String> readBy) {
        this.readBy = readBy == null ? new ArrayList<String>() : readBy;
    }
}
