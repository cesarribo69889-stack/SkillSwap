package com.skillswap.model;

import com.google.firebase.firestore.Exclude;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/** Documento de la coleccion "exchanges". */
public class Exchange implements Serializable {

    public static final String STATUS_UPCOMING = "PROXIMO";
    public static final String STATUS_IN_PROGRESS = "EN_PROCESO";
    public static final String STATUS_COMPLETED = "COMPLETADO";
    public static final String STATUS_CANCELLED = "CANCELADO";

    private String id = "";
    private String requestId = "";
    private String chatId = "";
    private String contractId = "";

    private String userAId = "";
    private String userAName = "";
    private String userAPhoto = "";
    private String userBId = "";
    private String userBName = "";
    private String userBPhoto = "";
    private List<String> participants = new ArrayList<>();

    /** Habilidad que A ensena a B. */
    private String skillFromA = "";
    /** Habilidad que B ensena a A. */
    private String skillFromB = "";

    private String modality = "";
    private String schedule = "";
    private String status = STATUS_UPCOMING;
    private int progress = 0;
    private int sessionsTotal = 0;
    private int sessionsDone = 0;

    private boolean completedByA = false;
    private boolean completedByB = false;
    private boolean ratedByA = false;
    private boolean ratedByB = false;

    private long startDate = 0L;
    private long endDate = 0L;
    private long createdAt = 0L;
    private long updatedAt = 0L;

    public Exchange() {
    }

    @Exclude
    public String getPartnerId(String myUid) {
        return userAId.equals(myUid) ? userBId : userAId;
    }

    @Exclude
    public String getPartnerName(String myUid) {
        return userAId.equals(myUid) ? userBName : userAName;
    }

    @Exclude
    public String getPartnerPhoto(String myUid) {
        return userAId.equals(myUid) ? userBPhoto : userAPhoto;
    }

    /** Habilidad que YO ensenio en este intercambio. */
    @Exclude
    public String getSkillITeach(String myUid) {
        return userAId.equals(myUid) ? skillFromA : skillFromB;
    }

    /** Habilidad que YO aprendo en este intercambio. */
    @Exclude
    public String getSkillILearn(String myUid) {
        return userAId.equals(myUid) ? skillFromB : skillFromA;
    }

    @Exclude
    public boolean hasCompleted(String myUid) {
        return userAId.equals(myUid) ? completedByA : completedByB;
    }

    @Exclude
    public boolean hasRated(String myUid) {
        return userAId.equals(myUid) ? ratedByA : ratedByB;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getRequestId() { return requestId; }
    public void setRequestId(String requestId) { this.requestId = requestId; }

    public String getChatId() { return chatId; }
    public void setChatId(String chatId) { this.chatId = chatId; }

    public String getContractId() { return contractId; }
    public void setContractId(String contractId) { this.contractId = contractId; }

    public String getUserAId() { return userAId; }
    public void setUserAId(String userAId) { this.userAId = userAId; }

    public String getUserAName() { return userAName; }
    public void setUserAName(String userAName) { this.userAName = userAName; }

    public String getUserAPhoto() { return userAPhoto; }
    public void setUserAPhoto(String userAPhoto) { this.userAPhoto = userAPhoto; }

    public String getUserBId() { return userBId; }
    public void setUserBId(String userBId) { this.userBId = userBId; }

    public String getUserBName() { return userBName; }
    public void setUserBName(String userBName) { this.userBName = userBName; }

    public String getUserBPhoto() { return userBPhoto; }
    public void setUserBPhoto(String userBPhoto) { this.userBPhoto = userBPhoto; }

    public List<String> getParticipants() { return participants; }
    public void setParticipants(List<String> participants) {
        this.participants = participants == null ? new ArrayList<String>() : participants;
    }

    public String getSkillFromA() { return skillFromA; }
    public void setSkillFromA(String skillFromA) { this.skillFromA = skillFromA; }

    public String getSkillFromB() { return skillFromB; }
    public void setSkillFromB(String skillFromB) { this.skillFromB = skillFromB; }

    public String getModality() { return modality; }
    public void setModality(String modality) { this.modality = modality; }

    public String getSchedule() { return schedule; }
    public void setSchedule(String schedule) { this.schedule = schedule; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getProgress() { return progress; }
    public void setProgress(int progress) { this.progress = progress; }

    public int getSessionsTotal() { return sessionsTotal; }
    public void setSessionsTotal(int sessionsTotal) { this.sessionsTotal = sessionsTotal; }

    public int getSessionsDone() { return sessionsDone; }
    public void setSessionsDone(int sessionsDone) { this.sessionsDone = sessionsDone; }

    public boolean isCompletedByA() { return completedByA; }
    public void setCompletedByA(boolean completedByA) { this.completedByA = completedByA; }

    public boolean isCompletedByB() { return completedByB; }
    public void setCompletedByB(boolean completedByB) { this.completedByB = completedByB; }

    public boolean isRatedByA() { return ratedByA; }
    public void setRatedByA(boolean ratedByA) { this.ratedByA = ratedByA; }

    public boolean isRatedByB() { return ratedByB; }
    public void setRatedByB(boolean ratedByB) { this.ratedByB = ratedByB; }

    public long getStartDate() { return startDate; }
    public void setStartDate(long startDate) { this.startDate = startDate; }

    public long getEndDate() { return endDate; }
    public void setEndDate(long endDate) { this.endDate = endDate; }

    public long getCreatedAt() { return createdAt; }
    public void setCreatedAt(long createdAt) { this.createdAt = createdAt; }

    public long getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(long updatedAt) { this.updatedAt = updatedAt; }
}
