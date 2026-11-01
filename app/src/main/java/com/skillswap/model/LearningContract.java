package com.skillswap.model;

import com.google.firebase.firestore.Exclude;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/** Documento de la coleccion "learningContracts" (Innovacion 3). */
public class LearningContract implements Serializable {

    public static final String STATUS_DRAFT = "BORRADOR";
    public static final String STATUS_PENDING = "PENDIENTE";
    public static final String STATUS_ACTIVE = "ACTIVO";
    public static final String STATUS_CLOSED = "CERRADO";

    private String id = "";
    private String exchangeId = "";
    private List<String> participants = new ArrayList<>();
    private String userAId = "";
    private String userBId = "";
    private String createdBy = "";

    private String objective = "";
    private int sessions = 3;
    private int sessionDuration = 60;
    private String modality = "";
    private String goal = "";
    private String finalActivity = "";

    private boolean acceptedByA = false;
    private boolean acceptedByB = false;
    private String status = STATUS_DRAFT;
    private long createdAt = 0L;
    private long updatedAt = 0L;

    public LearningContract() {
    }

    @Exclude
    public boolean isFullyAccepted() {
        return acceptedByA && acceptedByB;
    }

    @Exclude
    public boolean hasAccepted(String uid) {
        return userAId.equals(uid) ? acceptedByA : acceptedByB;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getExchangeId() { return exchangeId; }
    public void setExchangeId(String exchangeId) { this.exchangeId = exchangeId; }

    public List<String> getParticipants() { return participants; }
    public void setParticipants(List<String> participants) {
        this.participants = participants == null ? new ArrayList<String>() : participants;
    }

    public String getUserAId() { return userAId; }
    public void setUserAId(String userAId) { this.userAId = userAId; }

    public String getUserBId() { return userBId; }
    public void setUserBId(String userBId) { this.userBId = userBId; }

    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }

    public String getObjective() { return objective; }
    public void setObjective(String objective) { this.objective = objective; }

    public int getSessions() { return sessions; }
    public void setSessions(int sessions) { this.sessions = sessions; }

    public int getSessionDuration() { return sessionDuration; }
    public void setSessionDuration(int sessionDuration) { this.sessionDuration = sessionDuration; }

    public String getModality() { return modality; }
    public void setModality(String modality) { this.modality = modality; }

    public String getGoal() { return goal; }
    public void setGoal(String goal) { this.goal = goal; }

    public String getFinalActivity() { return finalActivity; }
    public void setFinalActivity(String finalActivity) { this.finalActivity = finalActivity; }

    public boolean isAcceptedByA() { return acceptedByA; }
    public void setAcceptedByA(boolean acceptedByA) { this.acceptedByA = acceptedByA; }

    public boolean isAcceptedByB() { return acceptedByB; }
    public void setAcceptedByB(boolean acceptedByB) { this.acceptedByB = acceptedByB; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public long getCreatedAt() { return createdAt; }
    public void setCreatedAt(long createdAt) { this.createdAt = createdAt; }

    public long getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(long updatedAt) { this.updatedAt = updatedAt; }
}
