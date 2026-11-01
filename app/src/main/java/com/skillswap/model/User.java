package com.skillswap.model;

import com.google.firebase.firestore.Exclude;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * Documento de la coleccion "users".
 * Las habilidades se guardan embebidas para poder calcular el SkillMatch
 * sin necesidad de lecturas adicionales.
 */
public class User implements Serializable {

    private String uid = "";
    private String firstName = "";
    private String lastName = "";
    private String email = "";
    private String photoUrl = "";
    private String university = "";
    private String career = "";
    private String cycle = "";
    private String description = "";
    private String modality = "";

    private List<String> availability = new ArrayList<>();
    private List<UserSkill> teachSkills = new ArrayList<>();
    private List<UserSkill> learnSkills = new ArrayList<>();

    /** Nombres en minuscula de lo que ensena. Permite consultas whereArrayContains. */
    private List<String> teachSkillKeys = new ArrayList<>();
    /** Nombres en minuscula de lo que quiere aprender. */
    private List<String> learnSkillKeys = new ArrayList<>();
    /** Tokens del nombre/carrera/universidad para el buscador. */
    private List<String> searchKeywords = new ArrayList<>();

    private double reputation = 0d;
    private int totalRatings = 0;
    private int exchangesCount = 0;
    private int skillPoints = 0;
    private String gamificationLevel = "";

    private String fcmToken = "";
    private boolean profileCompleted = false;
    private boolean active = true;
    private long createdAt = 0L;
    private long updatedAt = 0L;

    public User() {
    }

    public User(String uid, String firstName, String lastName, String email) {
        this.uid = uid;
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.createdAt = System.currentTimeMillis();
        this.updatedAt = this.createdAt;
    }

    @Exclude
    public String getFullName() {
        return (firstName + " " + lastName).trim();
    }

    @Exclude
    public String getShortName() {
        if (firstName == null || firstName.isEmpty()) return "Estudiante";
        String[] parts = firstName.trim().split("\\s+");
        return parts[0];
    }

    @Exclude
    public String getInitials() {
        StringBuilder sb = new StringBuilder();
        if (firstName != null && !firstName.isEmpty()) sb.append(firstName.charAt(0));
        if (lastName != null && !lastName.isEmpty()) sb.append(lastName.charAt(0));
        return sb.toString().toUpperCase(Locale.getDefault());
    }

    @Exclude
    public String getAcademicLine() {
        StringBuilder sb = new StringBuilder();
        if (career != null && !career.isEmpty()) sb.append(career);
        if (cycle != null && !cycle.isEmpty()) {
            if (sb.length() > 0) sb.append(" · ");
            sb.append(cycle);
        }
        return sb.toString();
    }

    @Exclude
    public UserSkill findTeachSkill(String name) {
        if (name == null) return null;
        for (UserSkill s : teachSkills) {
            if (name.equalsIgnoreCase(s.getName())) return s;
        }
        return null;
    }

    @Exclude
    public UserSkill findLearnSkill(String name) {
        if (name == null) return null;
        for (UserSkill s : learnSkills) {
            if (name.equalsIgnoreCase(s.getName())) return s;
        }
        return null;
    }

    // ---------------- getters / setters ----------------
    public String getUid() { return uid; }
    public void setUid(String uid) { this.uid = uid; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }

    public String getUniversity() { return university; }
    public void setUniversity(String university) { this.university = university; }

    public String getCareer() { return career; }
    public void setCareer(String career) { this.career = career; }

    public String getCycle() { return cycle; }
    public void setCycle(String cycle) { this.cycle = cycle; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getModality() { return modality; }
    public void setModality(String modality) { this.modality = modality; }

    public List<String> getAvailability() { return availability; }
    public void setAvailability(List<String> availability) {
        this.availability = availability == null ? new ArrayList<String>() : availability;
    }

    public List<UserSkill> getTeachSkills() { return teachSkills; }
    public void setTeachSkills(List<UserSkill> teachSkills) {
        this.teachSkills = teachSkills == null ? new ArrayList<UserSkill>() : teachSkills;
    }

    public List<UserSkill> getLearnSkills() { return learnSkills; }
    public void setLearnSkills(List<UserSkill> learnSkills) {
        this.learnSkills = learnSkills == null ? new ArrayList<UserSkill>() : learnSkills;
    }

    public List<String> getTeachSkillKeys() { return teachSkillKeys; }
    public void setTeachSkillKeys(List<String> teachSkillKeys) {
        this.teachSkillKeys = teachSkillKeys == null ? new ArrayList<String>() : teachSkillKeys;
    }

    public List<String> getLearnSkillKeys() { return learnSkillKeys; }
    public void setLearnSkillKeys(List<String> learnSkillKeys) {
        this.learnSkillKeys = learnSkillKeys == null ? new ArrayList<String>() : learnSkillKeys;
    }

    public List<String> getSearchKeywords() { return searchKeywords; }
    public void setSearchKeywords(List<String> searchKeywords) {
        this.searchKeywords = searchKeywords == null ? new ArrayList<String>() : searchKeywords;
    }

    public double getReputation() { return reputation; }
    public void setReputation(double reputation) { this.reputation = reputation; }

    public int getTotalRatings() { return totalRatings; }
    public void setTotalRatings(int totalRatings) { this.totalRatings = totalRatings; }

    public int getExchangesCount() { return exchangesCount; }
    public void setExchangesCount(int exchangesCount) { this.exchangesCount = exchangesCount; }

    public int getSkillPoints() { return skillPoints; }
    public void setSkillPoints(int skillPoints) { this.skillPoints = skillPoints; }

    public String getGamificationLevel() { return gamificationLevel; }
    public void setGamificationLevel(String gamificationLevel) { this.gamificationLevel = gamificationLevel; }

    public String getFcmToken() { return fcmToken; }
    public void setFcmToken(String fcmToken) { this.fcmToken = fcmToken; }

    public boolean isProfileCompleted() { return profileCompleted; }
    public void setProfileCompleted(boolean profileCompleted) { this.profileCompleted = profileCompleted; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public long getCreatedAt() { return createdAt; }
    public void setCreatedAt(long createdAt) { this.createdAt = createdAt; }

    public long getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(long updatedAt) { this.updatedAt = updatedAt; }
}
