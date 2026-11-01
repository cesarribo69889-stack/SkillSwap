package com.skillswap.model;

import java.io.Serializable;

/** Subcoleccion "skillPoints/{uid}/history": movimiento de SkillPoints. */
public class PointEntry implements Serializable {

    private String id = "";
    private String userId = "";
    private int points = 0;
    private String reason = "";
    private String referenceId = "";
    private long createdAt = 0L;

    public PointEntry() {
    }

    public PointEntry(String userId, int points, String reason, String referenceId) {
        this.userId = userId;
        this.points = points;
        this.reason = reason;
        this.referenceId = referenceId;
        this.createdAt = System.currentTimeMillis();
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public int getPoints() { return points; }
    public void setPoints(int points) { this.points = points; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getReferenceId() { return referenceId; }
    public void setReferenceId(String referenceId) { this.referenceId = referenceId; }

    public long getCreatedAt() { return createdAt; }
    public void setCreatedAt(long createdAt) { this.createdAt = createdAt; }
}
