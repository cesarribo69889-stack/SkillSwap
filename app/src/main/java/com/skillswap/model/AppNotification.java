package com.skillswap.model;

import java.io.Serializable;

/** Documento de la coleccion "notifications" (centro interno de notificaciones). */
public class AppNotification implements Serializable {

    public static final String TYPE_NEW_REQUEST = "NEW_REQUEST";
    public static final String TYPE_REQUEST_ACCEPTED = "REQUEST_ACCEPTED";
    public static final String TYPE_REQUEST_REJECTED = "REQUEST_REJECTED";
    public static final String TYPE_NEW_MESSAGE = "NEW_MESSAGE";
    public static final String TYPE_NEW_MATCH = "NEW_MATCH";
    public static final String TYPE_EXCHANGE_COMPLETED = "EXCHANGE_COMPLETED";
    public static final String TYPE_NEW_RATING = "NEW_RATING";
    public static final String TYPE_BADGE = "BADGE";
    public static final String TYPE_CHALLENGE = "CHALLENGE";

    private String id = "";
    private String userId = "";
    private String type = "";
    private String title = "";
    private String body = "";
    private String referenceId = "";
    private boolean read = false;
    private long createdAt = 0L;

    public AppNotification() {
    }

    public AppNotification(String userId, String type, String title, String body, String referenceId) {
        this.userId = userId;
        this.type = type;
        this.title = title;
        this.body = body;
        this.referenceId = referenceId;
        this.createdAt = System.currentTimeMillis();
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }

    public String getReferenceId() { return referenceId; }
    public void setReferenceId(String referenceId) { this.referenceId = referenceId; }

    public boolean isRead() { return read; }
    public void setRead(boolean read) { this.read = read; }

    public long getCreatedAt() { return createdAt; }
    public void setCreatedAt(long createdAt) { this.createdAt = createdAt; }
}
