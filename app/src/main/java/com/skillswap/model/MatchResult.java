package com.skillswap.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * Resultado del algoritmo SkillMatch entre el usuario actual y otro estudiante.
 * Se persiste (sin el objeto User) en la coleccion "matches".
 */
public class MatchResult implements Serializable {

    private String id = "";
    private String userAId = "";
    private String userBId = "";
    private List<String> participants = new ArrayList<>();
    private int score = 0;
    private boolean mutual = false;
    private long createdAt = 0L;
    private List<String> reasonTexts = new ArrayList<>();

    private transient User user;
    private transient List<MatchReason> reasons = new ArrayList<>();
    private transient List<String> theyTeachYouWant = new ArrayList<>();
    private transient List<String> youTeachTheyWant = new ArrayList<>();

    public MatchResult() {
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserAId() { return userAId; }
    public void setUserAId(String userAId) { this.userAId = userAId; }

    public String getUserBId() { return userBId; }
    public void setUserBId(String userBId) { this.userBId = userBId; }

    public List<String> getParticipants() { return participants; }
    public void setParticipants(List<String> participants) {
        this.participants = participants == null ? new ArrayList<String>() : participants;
    }

    public int getScore() { return score; }
    public void setScore(int score) { this.score = score; }

    public boolean isMutual() { return mutual; }
    public void setMutual(boolean mutual) { this.mutual = mutual; }

    public long getCreatedAt() { return createdAt; }
    public void setCreatedAt(long createdAt) { this.createdAt = createdAt; }

    public List<String> getReasonTexts() { return reasonTexts; }
    public void setReasonTexts(List<String> reasonTexts) {
        this.reasonTexts = reasonTexts == null ? new ArrayList<String>() : reasonTexts;
    }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public List<MatchReason> getReasons() {
        if (reasons == null) reasons = new ArrayList<>();
        return reasons;
    }
    public void setReasons(List<MatchReason> reasons) { this.reasons = reasons; }

    public List<String> getTheyTeachYouWant() {
        if (theyTeachYouWant == null) theyTeachYouWant = new ArrayList<>();
        return theyTeachYouWant;
    }
    public void setTheyTeachYouWant(List<String> v) { this.theyTeachYouWant = v; }

    public List<String> getYouTeachTheyWant() {
        if (youTeachTheyWant == null) youTeachTheyWant = new ArrayList<>();
        return youTeachTheyWant;
    }
    public void setYouTeachTheyWant(List<String> v) { this.youTeachTheyWant = v; }
}
