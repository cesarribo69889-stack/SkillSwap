package com.skillswap.model;

import java.io.Serializable;

/** Documento de la coleccion "skillPoints" (Innovacion 4). Un doc por usuario. */
public class SkillPointsAccount implements Serializable {

    private String userId = "";
    private int points = 0;
    private String level = "Principiante";
    private int levelIndex = 0;
    private int pointsForNextLevel = 100;
    private int completedExchanges = 0;
    private int badgesUnlocked = 0;
    private long updatedAt = 0L;

    public SkillPointsAccount() {
    }

    public SkillPointsAccount(String userId) {
        this.userId = userId;
        this.updatedAt = System.currentTimeMillis();
    }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public int getPoints() { return points; }
    public void setPoints(int points) { this.points = points; }

    public String getLevel() { return level; }
    public void setLevel(String level) { this.level = level; }

    public int getLevelIndex() { return levelIndex; }
    public void setLevelIndex(int levelIndex) { this.levelIndex = levelIndex; }

    public int getPointsForNextLevel() { return pointsForNextLevel; }
    public void setPointsForNextLevel(int pointsForNextLevel) { this.pointsForNextLevel = pointsForNextLevel; }

    public int getCompletedExchanges() { return completedExchanges; }
    public void setCompletedExchanges(int completedExchanges) { this.completedExchanges = completedExchanges; }

    public int getBadgesUnlocked() { return badgesUnlocked; }
    public void setBadgesUnlocked(int badgesUnlocked) { this.badgesUnlocked = badgesUnlocked; }

    public long getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(long updatedAt) { this.updatedAt = updatedAt; }
}
