package com.skillswap.model;

import com.google.firebase.firestore.Exclude;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/** Documento de la coleccion "challenges" (Innovacion 5). */
public class Challenge implements Serializable {

    public static final String STATUS_OPEN = "ABIERTO";
    public static final String STATUS_IN_PROGRESS = "EN_PROCESO";
    public static final String STATUS_FINISHED = "FINALIZADO";

    private String id = "";
    private String title = "";
    private String description = "";
    private String objective = "";
    private String category = "";
    private List<String> requiredSkills = new ArrayList<>();
    private List<String> participantIds = new ArrayList<>();

    private String creatorId = "";
    private String creatorName = "";
    private String creatorPhoto = "";

    private int maxParticipants = 4;
    private int participantsCount = 0;
    private int durationDays = 7;
    private int progress = 0;
    private String status = STATUS_OPEN;
    private long deadline = 0L;
    private long createdAt = 0L;

    public Challenge() {
    }

    @Exclude
    public boolean isFull() {
        return participantsCount >= maxParticipants;
    }

    @Exclude
    public int getFreeSlots() {
        return Math.max(0, maxParticipants - participantsCount);
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getObjective() { return objective; }
    public void setObjective(String objective) { this.objective = objective; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public List<String> getRequiredSkills() { return requiredSkills; }
    public void setRequiredSkills(List<String> requiredSkills) {
        this.requiredSkills = requiredSkills == null ? new ArrayList<String>() : requiredSkills;
    }

    public List<String> getParticipantIds() { return participantIds; }
    public void setParticipantIds(List<String> participantIds) {
        this.participantIds = participantIds == null ? new ArrayList<String>() : participantIds;
    }

    public String getCreatorId() { return creatorId; }
    public void setCreatorId(String creatorId) { this.creatorId = creatorId; }

    public String getCreatorName() { return creatorName; }
    public void setCreatorName(String creatorName) { this.creatorName = creatorName; }

    public String getCreatorPhoto() { return creatorPhoto; }
    public void setCreatorPhoto(String creatorPhoto) { this.creatorPhoto = creatorPhoto; }

    public int getMaxParticipants() { return maxParticipants; }
    public void setMaxParticipants(int maxParticipants) { this.maxParticipants = maxParticipants; }

    public int getParticipantsCount() { return participantsCount; }
    public void setParticipantsCount(int participantsCount) { this.participantsCount = participantsCount; }

    public int getDurationDays() { return durationDays; }
    public void setDurationDays(int durationDays) { this.durationDays = durationDays; }

    public int getProgress() { return progress; }
    public void setProgress(int progress) { this.progress = progress; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public long getDeadline() { return deadline; }
    public void setDeadline(long deadline) { this.deadline = deadline; }

    public long getCreatedAt() { return createdAt; }
    public void setCreatedAt(long createdAt) { this.createdAt = createdAt; }
}
