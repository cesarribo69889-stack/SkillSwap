#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
M="$J/model"
mkdir -p "$M"

# ============================================================ User
cat > "$M/User.java" <<'EOF'
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
EOF

# ============================================================ Skill (catalogo)
cat > "$M/Skill.java" <<'EOF'
package com.skillswap.model;

import java.io.Serializable;

/** Documento de la coleccion "skills": catalogo global de habilidades. */
public class Skill implements Serializable {

    private String id = "";
    private String name = "";
    private String category = "";
    private String iconKey = "";
    private int popularity = 0;

    public Skill() {
    }

    public Skill(String id, String name, String category, String iconKey) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.iconKey = iconKey;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getIconKey() { return iconKey; }
    public void setIconKey(String iconKey) { this.iconKey = iconKey; }

    public int getPopularity() { return popularity; }
    public void setPopularity(int popularity) { this.popularity = popularity; }
}
EOF

# ============================================================ UserSkill
cat > "$M/UserSkill.java" <<'EOF'
package com.skillswap.model;

import com.google.firebase.firestore.Exclude;

import java.io.Serializable;
import java.util.Locale;

/**
 * Habilidad asociada a un usuario. Se guarda embebida dentro del documento
 * del usuario (arreglos teachSkills / learnSkills).
 */
public class UserSkill implements Serializable {

    public static final String TYPE_TEACH = "TEACH";
    public static final String TYPE_LEARN = "LEARN";

    private String skillId = "";
    private String name = "";
    private String category = "";
    private String level = "";
    private String type = TYPE_TEACH;
    private String note = "";
    private long addedAt = 0L;

    public UserSkill() {
    }

    public UserSkill(String skillId, String name, String category, String level, String type) {
        this.skillId = skillId;
        this.name = name;
        this.category = category;
        this.level = level;
        this.type = type;
        this.addedAt = System.currentTimeMillis();
    }

    /** Valor numerico del nivel: Basico=1, Intermedio=2, Avanzado=3. */
    @Exclude
    public int getLevelValue() {
        if (level == null) return 1;
        String l = level.toLowerCase(Locale.ROOT);
        if (l.startsWith("av")) return 3;
        if (l.startsWith("int")) return 2;
        return 1;
    }

    @Exclude
    public String getKey() {
        return name == null ? "" : name.toLowerCase(Locale.ROOT).trim();
    }

    @Exclude
    public boolean isTeach() {
        return TYPE_TEACH.equals(type);
    }

    public String getSkillId() { return skillId; }
    public void setSkillId(String skillId) { this.skillId = skillId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getLevel() { return level; }
    public void setLevel(String level) { this.level = level; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public long getAddedAt() { return addedAt; }
    public void setAddedAt(long addedAt) { this.addedAt = addedAt; }
}
EOF

# ============================================================ MatchReason
cat > "$M/MatchReason.java" <<'EOF'
package com.skillswap.model;

import java.io.Serializable;

/** Una linea de explicacion del SkillMatch. */
public class MatchReason implements Serializable {

    private String text = "";
    private boolean positive = true;
    private int weight = 0;

    public MatchReason() {
    }

    public MatchReason(String text, boolean positive, int weight) {
        this.text = text;
        this.positive = positive;
        this.weight = weight;
    }

    public String getText() { return text; }
    public void setText(String text) { this.text = text; }

    public boolean isPositive() { return positive; }
    public void setPositive(boolean positive) { this.positive = positive; }

    public int getWeight() { return weight; }
    public void setWeight(int weight) { this.weight = weight; }
}
EOF

# ============================================================ MatchResult
cat > "$M/MatchResult.java" <<'EOF'
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
EOF

# ============================================================ ExchangeRequest
cat > "$M/ExchangeRequest.java" <<'EOF'
package com.skillswap.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/** Documento de la coleccion "exchangeRequests". */
public class ExchangeRequest implements Serializable {

    public static final String STATUS_PENDING = "PENDIENTE";
    public static final String STATUS_ACCEPTED = "ACEPTADA";
    public static final String STATUS_REJECTED = "RECHAZADA";
    public static final String STATUS_CANCELLED = "CANCELADA";
    public static final String STATUS_IN_PROGRESS = "EN_PROCESO";
    public static final String STATUS_COMPLETED = "COMPLETADA";

    private String id = "";
    private String fromUserId = "";
    private String fromUserName = "";
    private String fromUserPhoto = "";
    private String toUserId = "";
    private String toUserName = "";
    private String toUserPhoto = "";
    private List<String> participants = new ArrayList<>();

    /** Habilidad que el emisor quiere APRENDER (la ensena el receptor). */
    private String skillWanted = "";
    /** Habilidad que el emisor puede ENSENAR. */
    private String skillOffered = "";

    private String message = "";
    private String modality = "";
    private String schedule = "";
    private String status = STATUS_PENDING;
    private int matchScore = 0;
    private String exchangeId = "";
    private long createdAt = 0L;
    private long updatedAt = 0L;

    public ExchangeRequest() {
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getFromUserId() { return fromUserId; }
    public void setFromUserId(String fromUserId) { this.fromUserId = fromUserId; }

    public String getFromUserName() { return fromUserName; }
    public void setFromUserName(String fromUserName) { this.fromUserName = fromUserName; }

    public String getFromUserPhoto() { return fromUserPhoto; }
    public void setFromUserPhoto(String fromUserPhoto) { this.fromUserPhoto = fromUserPhoto; }

    public String getToUserId() { return toUserId; }
    public void setToUserId(String toUserId) { this.toUserId = toUserId; }

    public String getToUserName() { return toUserName; }
    public void setToUserName(String toUserName) { this.toUserName = toUserName; }

    public String getToUserPhoto() { return toUserPhoto; }
    public void setToUserPhoto(String toUserPhoto) { this.toUserPhoto = toUserPhoto; }

    public List<String> getParticipants() { return participants; }
    public void setParticipants(List<String> participants) {
        this.participants = participants == null ? new ArrayList<String>() : participants;
    }

    public String getSkillWanted() { return skillWanted; }
    public void setSkillWanted(String skillWanted) { this.skillWanted = skillWanted; }

    public String getSkillOffered() { return skillOffered; }
    public void setSkillOffered(String skillOffered) { this.skillOffered = skillOffered; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getModality() { return modality; }
    public void setModality(String modality) { this.modality = modality; }

    public String getSchedule() { return schedule; }
    public void setSchedule(String schedule) { this.schedule = schedule; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getMatchScore() { return matchScore; }
    public void setMatchScore(int matchScore) { this.matchScore = matchScore; }

    public String getExchangeId() { return exchangeId; }
    public void setExchangeId(String exchangeId) { this.exchangeId = exchangeId; }

    public long getCreatedAt() { return createdAt; }
    public void setCreatedAt(long createdAt) { this.createdAt = createdAt; }

    public long getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(long updatedAt) { this.updatedAt = updatedAt; }
}
EOF

# ============================================================ Exchange
cat > "$M/Exchange.java" <<'EOF'
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
EOF

# ============================================================ Chat
cat > "$M/Chat.java" <<'EOF'
package com.skillswap.model;

import com.google.firebase.firestore.Exclude;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Documento de la coleccion "chats". */
public class Chat implements Serializable {

    private String id = "";
    private String exchangeId = "";
    private List<String> participants = new ArrayList<>();
    private Map<String, String> names = new HashMap<>();
    private Map<String, String> photos = new HashMap<>();
    private Map<String, Long> unread = new HashMap<>();

    private String lastMessage = "";
    private String lastSenderId = "";
    private long lastMessageAt = 0L;
    private boolean enabled = true;
    private long createdAt = 0L;

    public Chat() {
    }

    @Exclude
    public String getPartnerId(String myUid) {
        for (String p : participants) {
            if (!p.equals(myUid)) return p;
        }
        return "";
    }

    @Exclude
    public String getPartnerName(String myUid) {
        String pid = getPartnerId(myUid);
        String n = names.get(pid);
        return n == null ? "Estudiante" : n;
    }

    @Exclude
    public String getPartnerPhoto(String myUid) {
        String pid = getPartnerId(myUid);
        String p = photos.get(pid);
        return p == null ? "" : p;
    }

    @Exclude
    public long getUnreadFor(String myUid) {
        Long v = unread.get(myUid);
        return v == null ? 0L : v;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getExchangeId() { return exchangeId; }
    public void setExchangeId(String exchangeId) { this.exchangeId = exchangeId; }

    public List<String> getParticipants() { return participants; }
    public void setParticipants(List<String> participants) {
        this.participants = participants == null ? new ArrayList<String>() : participants;
    }

    public Map<String, String> getNames() { return names; }
    public void setNames(Map<String, String> names) {
        this.names = names == null ? new HashMap<String, String>() : names;
    }

    public Map<String, String> getPhotos() { return photos; }
    public void setPhotos(Map<String, String> photos) {
        this.photos = photos == null ? new HashMap<String, String>() : photos;
    }

    public Map<String, Long> getUnread() { return unread; }
    public void setUnread(Map<String, Long> unread) {
        this.unread = unread == null ? new HashMap<String, Long>() : unread;
    }

    public String getLastMessage() { return lastMessage; }
    public void setLastMessage(String lastMessage) { this.lastMessage = lastMessage; }

    public String getLastSenderId() { return lastSenderId; }
    public void setLastSenderId(String lastSenderId) { this.lastSenderId = lastSenderId; }

    public long getLastMessageAt() { return lastMessageAt; }
    public void setLastMessageAt(long lastMessageAt) { this.lastMessageAt = lastMessageAt; }

    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }

    public long getCreatedAt() { return createdAt; }
    public void setCreatedAt(long createdAt) { this.createdAt = createdAt; }
}
EOF

# ============================================================ ChatMessage
cat > "$M/ChatMessage.java" <<'EOF'
package com.skillswap.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/** Documento de la subcoleccion "chats/{chatId}/messages". */
public class ChatMessage implements Serializable {

    public static final String TYPE_TEXT = "TEXT";
    public static final String TYPE_SYSTEM = "SYSTEM";
    public static final String TYPE_IMAGE = "IMAGE";

    private String id = "";
    private String chatId = "";
    private String senderId = "";
    private String senderName = "";
    private String senderPhoto = "";
    private String text = "";
    private String type = TYPE_TEXT;
    private String imageUrl = "";
    private long timestamp = 0L;
    private List<String> readBy = new ArrayList<>();

    public ChatMessage() {
    }

    public ChatMessage(String chatId, String senderId, String senderName, String senderPhoto, String text) {
        this.chatId = chatId;
        this.senderId = senderId;
        this.senderName = senderName;
        this.senderPhoto = senderPhoto;
        this.text = text;
        this.type = TYPE_TEXT;
        this.timestamp = System.currentTimeMillis();
        this.readBy = new ArrayList<>();
        this.readBy.add(senderId);
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getChatId() { return chatId; }
    public void setChatId(String chatId) { this.chatId = chatId; }

    public String getSenderId() { return senderId; }
    public void setSenderId(String senderId) { this.senderId = senderId; }

    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }

    public String getSenderPhoto() { return senderPhoto; }
    public void setSenderPhoto(String senderPhoto) { this.senderPhoto = senderPhoto; }

    public String getText() { return text; }
    public void setText(String text) { this.text = text; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public long getTimestamp() { return timestamp; }
    public void setTimestamp(long timestamp) { this.timestamp = timestamp; }

    public List<String> getReadBy() { return readBy; }
    public void setReadBy(List<String> readBy) {
        this.readBy = readBy == null ? new ArrayList<String>() : readBy;
    }
}
EOF

# ============================================================ Rating
cat > "$M/Rating.java" <<'EOF'
package com.skillswap.model;

import com.google.firebase.firestore.Exclude;

import java.io.Serializable;

/** Documento de la coleccion "ratings". */
public class Rating implements Serializable {

    private String id = "";
    private String exchangeId = "";
    private String fromUserId = "";
    private String fromUserName = "";
    private String fromUserPhoto = "";
    private String toUserId = "";
    private String skillTaught = "";

    private float stars = 0f;
    private float punctuality = 0f;
    private float communication = 0f;
    private float teaching = 0f;
    private String comment = "";
    private long createdAt = 0L;

    public Rating() {
    }

    /** Promedio de los tres criterios + estrellas generales. */
    @Exclude
    public float getOverall() {
        float sum = stars + punctuality + communication + teaching;
        return sum / 4f;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getExchangeId() { return exchangeId; }
    public void setExchangeId(String exchangeId) { this.exchangeId = exchangeId; }

    public String getFromUserId() { return fromUserId; }
    public void setFromUserId(String fromUserId) { this.fromUserId = fromUserId; }

    public String getFromUserName() { return fromUserName; }
    public void setFromUserName(String fromUserName) { this.fromUserName = fromUserName; }

    public String getFromUserPhoto() { return fromUserPhoto; }
    public void setFromUserPhoto(String fromUserPhoto) { this.fromUserPhoto = fromUserPhoto; }

    public String getToUserId() { return toUserId; }
    public void setToUserId(String toUserId) { this.toUserId = toUserId; }

    public String getSkillTaught() { return skillTaught; }
    public void setSkillTaught(String skillTaught) { this.skillTaught = skillTaught; }

    public float getStars() { return stars; }
    public void setStars(float stars) { this.stars = stars; }

    public float getPunctuality() { return punctuality; }
    public void setPunctuality(float punctuality) { this.punctuality = punctuality; }

    public float getCommunication() { return communication; }
    public void setCommunication(float communication) { this.communication = communication; }

    public float getTeaching() { return teaching; }
    public void setTeaching(float teaching) { this.teaching = teaching; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public long getCreatedAt() { return createdAt; }
    public void setCreatedAt(long createdAt) { this.createdAt = createdAt; }
}
EOF

# ============================================================ AppNotification
cat > "$M/AppNotification.java" <<'EOF'
package com.skillswap.model;

import java.io.Serializable;

/** Documento de la coleccion "notifications" (centro interno de notificaciones). */
public class AppNotification implements Serializable {

    public static final String TYPE_NEW_REQUEST = "NEW_REQUEST";
    public static final String TYPE_REQUEST_ACCEPTED = "REQUEST_ACCEPTED";
    public static final String TYPE_REQUEST_REJECTED = "REQUEST_REJECTED";
    public static final String TYPE_NEW_MESSAGE = "NEW_MESSAGE";
    public static final String TYPE_NEW_MATCH = "NEW_MATCH";
    public static final String TYPE_EXCHANGE_COMPLETED = "EXCHANGE_COMPLETED";
    public static final String TYPE_NEW_RATING = "NEW_RATING";
    public static final String TYPE_BADGE = "BADGE";
    public static final String TYPE_CHALLENGE = "CHALLENGE";

    private String id = "";
    private String userId = "";
    private String type = "";
    private String title = "";
    private String body = "";
    private String referenceId = "";
    private boolean read = false;
    private long createdAt = 0L;

    public AppNotification() {
    }

    public AppNotification(String userId, String type, String title, String body, String referenceId) {
        this.userId = userId;
        this.type = type;
        this.title = title;
        this.body = body;
        this.referenceId = referenceId;
        this.createdAt = System.currentTimeMillis();
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }

    public String getReferenceId() { return referenceId; }
    public void setReferenceId(String referenceId) { this.referenceId = referenceId; }

    public boolean isRead() { return read; }
    public void setRead(boolean read) { this.read = read; }

    public long getCreatedAt() { return createdAt; }
    public void setCreatedAt(long createdAt) { this.createdAt = createdAt; }
}
EOF

# ============================================================ PassportEntry
cat > "$M/PassportEntry.java" <<'EOF'
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
EOF

# ============================================================ LearningContract
cat > "$M/LearningContract.java" <<'EOF'
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
EOF

# ============================================================ SkillPointsAccount
cat > "$M/SkillPointsAccount.java" <<'EOF'
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
EOF

# ============================================================ PointEntry
cat > "$M/PointEntry.java" <<'EOF'
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
EOF

# ============================================================ Badge
cat > "$M/Badge.java" <<'EOF'
package com.skillswap.model;

import java.io.Serializable;

/** Documento de la coleccion "badges". */
public class Badge implements Serializable {

    private String id = "";
    private String userId = "";
    private String code = "";
    private String name = "";
    private String description = "";
    private String iconKey = "";
    private String colorKey = "";
    private boolean unlocked = false;
    private long unlockedAt = 0L;

    public Badge() {
    }

    public Badge(String code, String name, String description, String iconKey, String colorKey) {
        this.code = code;
        this.name = name;
        this.description = description;
        this.iconKey = iconKey;
        this.colorKey = colorKey;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getIconKey() { return iconKey; }
    public void setIconKey(String iconKey) { this.iconKey = iconKey; }

    public String getColorKey() { return colorKey; }
    public void setColorKey(String colorKey) { this.colorKey = colorKey; }

    public boolean isUnlocked() { return unlocked; }
    public void setUnlocked(boolean unlocked) { this.unlocked = unlocked; }

    public long getUnlockedAt() { return unlockedAt; }
    public void setUnlockedAt(long unlockedAt) { this.unlockedAt = unlockedAt; }
}
EOF

# ============================================================ Challenge
cat > "$M/Challenge.java" <<'EOF'
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
EOF

# ============================================================ ChallengeParticipant
cat > "$M/ChallengeParticipant.java" <<'EOF'
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
EOF

# ============================================================ LearningEvidence
cat > "$M/LearningEvidence.java" <<'EOF'
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
EOF

# ============================================================ ExploreFilter
cat > "$M/ExploreFilter.java" <<'EOF'
package com.skillswap.model;

import java.io.Serializable;

/** Filtros aplicados en la pantalla Explorar. No se persiste. */
public class ExploreFilter implements Serializable {

    private String query = "";
    private String skill = "";
    private String category = "";
    private String level = "";
    private String modality = "";
    private String university = "";
    private int minCompatibility = 0;

    public ExploreFilter() {
    }

    public boolean isEmpty() {
        return isBlank(query) && isBlank(skill) && isBlank(category)
                && isBlank(level) && isBlank(modality) && isBlank(university)
                && minCompatibility == 0;
    }

    public int activeCount() {
        int c = 0;
        if (!isBlank(skill)) c++;
        if (!isBlank(category)) c++;
        if (!isBlank(level)) c++;
        if (!isBlank(modality)) c++;
        if (!isBlank(university)) c++;
        if (minCompatibility > 0) c++;
        return c;
    }

    public void clearFilters() {
        skill = "";
        category = "";
        level = "";
        modality = "";
        university = "";
        minCompatibility = 0;
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    public String getQuery() { return query; }
    public void setQuery(String query) { this.query = query; }

    public String getSkill() { return skill; }
    public void setSkill(String skill) { this.skill = skill; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getLevel() { return level; }
    public void setLevel(String level) { this.level = level; }

    public String getModality() { return modality; }
    public void setModality(String modality) { this.modality = modality; }

    public String getUniversity() { return university; }
    public void setUniversity(String university) { this.university = university; }

    public int getMinCompatibility() { return minCompatibility; }
    public void setMinCompatibility(int minCompatibility) { this.minCompatibility = minCompatibility; }
}
EOF

# ============================================================ Resource
cat > "$M/Resource.java" <<'EOF'
package com.skillswap.model;

/**
 * Envoltorio generico de estado para LiveData: CARGANDO / EXITO / ERROR.
 */
public class Resource<T> {

    public enum Status { LOADING, SUCCESS, ERROR }

    private final Status status;
    private final T data;
    private final String message;

    private Resource(Status status, T data, String message) {
        this.status = status;
        this.data = data;
        this.message = message;
    }

    public static <T> Resource<T> loading() {
        return new Resource<>(Status.LOADING, null, null);
    }

    public static <T> Resource<T> success(T data) {
        return new Resource<>(Status.SUCCESS, data, null);
    }

    public static <T> Resource<T> error(String message) {
        return new Resource<>(Status.ERROR, null, message);
    }

    public Status getStatus() { return status; }
    public T getData() { return data; }
    public String getMessage() { return message; }

    public boolean isLoading() { return status == Status.LOADING; }
    public boolean isSuccess() { return status == Status.SUCCESS; }
    public boolean isError() { return status == Status.ERROR; }
}
EOF

echo "Modelos generados: $(ls "$M"/*.java | wc -l)"
