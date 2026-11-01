package com.skillswap.model;

import java.io.Serializable;

/** Documento de la coleccion "challengeParticipants". */
public class ChallengeParticipant implements Serializable {

    public static final String STATUS_PENDING = "PENDIENTE";
    public static final String STATUS_ACCEPTED = "ACEPTADO";
    public static final String STATUS_REJECTED = "RECHAZADO";

    private String id = "";
    private String challengeId = "";
    private String userId = "";
    private String userName = "";
    private String userPhoto = "";
    private String skill = "";
    private String role = "";
    private String message = "";
    private String status = STATUS_PENDING;
    private long joinedAt = 0L;

    public ChallengeParticipant() {
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getChallengeId() { return challengeId; }
    public void setChallengeId(String challengeId) { this.challengeId = challengeId; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserPhoto() { return userPhoto; }
    public void setUserPhoto(String userPhoto) { this.userPhoto = userPhoto; }

    public String getSkill() { return skill; }
    public void setSkill(String skill) { this.skill = skill; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public long getJoinedAt() { return joinedAt; }
    public void setJoinedAt(long joinedAt) { this.joinedAt = joinedAt; }
}
