package com.skillswap.model;

import com.google.firebase.firestore.Exclude;

import java.io.Serializable;

/**
 * Documento de la coleccion "skillPassport".
 * Registro de actividad por habilidad. NO es una certificacion academica.
 */
public class PassportEntry implements Serializable {

    public static final String ROLE_TAUGHT = "ENSENADA";
    public static final String ROLE_LEARNED = "APRENDIDA";
    public static final String ROLE_PRACTICED = "PRACTICADA";

    private String id = "";
    private String userId = "";
    private String skillName = "";
    private String category = "";
    private String role = ROLE_TAUGHT;
    private String level = "";

    private int exchangesCount = 0;
    private int sessionsCount = 0;
    private double averageRating = 0d;
    private int ratingsCount = 0;
    private int progress = 0;
    private long lastActivity = 0L;
    private long createdAt = 0L;

    public PassportEntry() {
    }

    @Exclude
    public String getSummary() {
        return exchangesCount + (exchangesCount == 1 ? " intercambio" : " intercambios");
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getSkillName() { return skillName; }
    public void setSkillName(String skillName) { this.skillName = skillName; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getLevel() { return level; }
    public void setLevel(String level) { this.level = level; }

    public int getExchangesCount() { return exchangesCount; }
    public void setExchangesCount(int exchangesCount) { this.exchangesCount = exchangesCount; }

    public int getSessionsCount() { return sessionsCount; }
    public void setSessionsCount(int sessionsCount) { this.sessionsCount = sessionsCount; }

    public double getAverageRating() { return averageRating; }
    public void setAverageRating(double averageRating) { this.averageRating = averageRating; }

    public int getRatingsCount() { return ratingsCount; }
    public void setRatingsCount(int ratingsCount) { this.ratingsCount = ratingsCount; }

    public int getProgress() { return progress; }
    public void setProgress(int progress) { this.progress = progress; }

    public long getLastActivity() { return lastActivity; }
    public void setLastActivity(long lastActivity) { this.lastActivity = lastActivity; }

    public long getCreatedAt() { return createdAt; }
    public void setCreatedAt(long createdAt) { this.createdAt = createdAt; }
}
