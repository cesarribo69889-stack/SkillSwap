package com.skillswap.model;

import java.io.Serializable;

/**
 * Documento de la coleccion "learningEvidence" (Innovacion 6).
 * Registro practico del aprendizaje. NO es una certificacion academica.
 */
public class LearningEvidence implements Serializable {

    private String id = "";
    private String exchangeId = "";
    private String userId = "";
    private String partnerId = "";
    private String skillName = "";
    private String activity = "";
    private String notes = "";
    private String evidenceUrl = "";
    private boolean objectiveAchieved = false;
    private int selfAssessment = 3;
    private long createdAt = 0L;

    public LearningEvidence() {
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getExchangeId() { return exchangeId; }
    public void setExchangeId(String exchangeId) { this.exchangeId = exchangeId; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getPartnerId() { return partnerId; }
    public void setPartnerId(String partnerId) { this.partnerId = partnerId; }

    public String getSkillName() { return skillName; }
    public void setSkillName(String skillName) { this.skillName = skillName; }

    public String getActivity() { return activity; }
    public void setActivity(String activity) { this.activity = activity; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public String getEvidenceUrl() { return evidenceUrl; }
    public void setEvidenceUrl(String evidenceUrl) { this.evidenceUrl = evidenceUrl; }

    public boolean isObjectiveAchieved() { return objectiveAchieved; }
    public void setObjectiveAchieved(boolean objectiveAchieved) { this.objectiveAchieved = objectiveAchieved; }

    public int getSelfAssessment() { return selfAssessment; }
    public void setSelfAssessment(int selfAssessment) { this.selfAssessment = selfAssessment; }

    public long getCreatedAt() { return createdAt; }
    public void setCreatedAt(long createdAt) { this.createdAt = createdAt; }
}
