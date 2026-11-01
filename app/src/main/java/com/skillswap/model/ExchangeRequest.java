package com.skillswap.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/** Documento de la coleccion "exchangeRequests". */
public class ExchangeRequest implements Serializable {

    public static final String STATUS_PENDING = "PENDIENTE";
    public static final String STATUS_ACCEPTED = "ACEPTADA";
    public static final String STATUS_REJECTED = "RECHAZADA";
    public static final String STATUS_CANCELLED = "CANCELADA";
    public static final String STATUS_IN_PROGRESS = "EN_PROCESO";
    public static final String STATUS_COMPLETED = "COMPLETADA";

    private String id = "";
    private String fromUserId = "";
    private String fromUserName = "";
    private String fromUserPhoto = "";
    private String toUserId = "";
    private String toUserName = "";
    private String toUserPhoto = "";
    private List<String> participants = new ArrayList<>();

    /** Habilidad que el emisor quiere APRENDER (la ensena el receptor). */
    private String skillWanted = "";
    /** Habilidad que el emisor puede ENSENAR. */
    private String skillOffered = "";

    private String message = "";
    private String modality = "";
    private String schedule = "";
    private String status = STATUS_PENDING;
    private int matchScore = 0;
    private String exchangeId = "";
    private long createdAt = 0L;
    private long updatedAt = 0L;

    public ExchangeRequest() {
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getFromUserId() { return fromUserId; }
    public void setFromUserId(String fromUserId) { this.fromUserId = fromUserId; }

    public String getFromUserName() { return fromUserName; }
    public void setFromUserName(String fromUserName) { this.fromUserName = fromUserName; }

    public String getFromUserPhoto() { return fromUserPhoto; }
    public void setFromUserPhoto(String fromUserPhoto) { this.fromUserPhoto = fromUserPhoto; }

    public String getToUserId() { return toUserId; }
    public void setToUserId(String toUserId) { this.toUserId = toUserId; }

    public String getToUserName() { return toUserName; }
    public void setToUserName(String toUserName) { this.toUserName = toUserName; }

    public String getToUserPhoto() { return toUserPhoto; }
    public void setToUserPhoto(String toUserPhoto) { this.toUserPhoto = toUserPhoto; }

    public List<String> getParticipants() { return participants; }
    public void setParticipants(List<String> participants) {
        this.participants = participants == null ? new ArrayList<String>() : participants;
    }

    public String getSkillWanted() { return skillWanted; }
    public void setSkillWanted(String skillWanted) { this.skillWanted = skillWanted; }

    public String getSkillOffered() { return skillOffered; }
    public void setSkillOffered(String skillOffered) { this.skillOffered = skillOffered; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getModality() { return modality; }
    public void setModality(String modality) { this.modality = modality; }

    public String getSchedule() { return schedule; }
    public void setSchedule(String schedule) { this.schedule = schedule; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getMatchScore() { return matchScore; }
    public void setMatchScore(int matchScore) { this.matchScore = matchScore; }

    public String getExchangeId() { return exchangeId; }
    public void setExchangeId(String exchangeId) { this.exchangeId = exchangeId; }

    public long getCreatedAt() { return createdAt; }
    public void setCreatedAt(long createdAt) { this.createdAt = createdAt; }

    public long getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(long updatedAt) { this.updatedAt = updatedAt; }
}
