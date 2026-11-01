package com.skillswap.model;

import com.google.firebase.firestore.Exclude;

import java.io.Serializable;

/** Documento de la coleccion "ratings". */
public class Rating implements Serializable {

    private String id = "";
    private String exchangeId = "";
    private String fromUserId = "";
    private String fromUserName = "";
    private String fromUserPhoto = "";
    private String toUserId = "";
    private String skillTaught = "";

    private float stars = 0f;
    private float punctuality = 0f;
    private float communication = 0f;
    private float teaching = 0f;
    private String comment = "";
    private long createdAt = 0L;

    public Rating() {
    }

    /** Promedio de los tres criterios + estrellas generales. */
    @Exclude
    public float getOverall() {
        float sum = stars + punctuality + communication + teaching;
        return sum / 4f;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getExchangeId() { return exchangeId; }
    public void setExchangeId(String exchangeId) { this.exchangeId = exchangeId; }

    public String getFromUserId() { return fromUserId; }
    public void setFromUserId(String fromUserId) { this.fromUserId = fromUserId; }

    public String getFromUserName() { return fromUserName; }
    public void setFromUserName(String fromUserName) { this.fromUserName = fromUserName; }

    public String getFromUserPhoto() { return fromUserPhoto; }
    public void setFromUserPhoto(String fromUserPhoto) { this.fromUserPhoto = fromUserPhoto; }

    public String getToUserId() { return toUserId; }
    public void setToUserId(String toUserId) { this.toUserId = toUserId; }

    public String getSkillTaught() { return skillTaught; }
    public void setSkillTaught(String skillTaught) { this.skillTaught = skillTaught; }

    public float getStars() { return stars; }
    public void setStars(float stars) { this.stars = stars; }

    public float getPunctuality() { return punctuality; }
    public void setPunctuality(float punctuality) { this.punctuality = punctuality; }

    public float getCommunication() { return communication; }
    public void setCommunication(float communication) { this.communication = communication; }

    public float getTeaching() { return teaching; }
    public void setTeaching(float teaching) { this.teaching = teaching; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public long getCreatedAt() { return createdAt; }
    public void setCreatedAt(long createdAt) { this.createdAt = createdAt; }
}
