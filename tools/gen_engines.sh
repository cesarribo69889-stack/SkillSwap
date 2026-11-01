#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
U="$J/utils"; F="$J/firebase"
mkdir -p "$U" "$F"

# ============================================================ SkillMatchEngine
cat > "$U/SkillMatchEngine.java" <<'EOF'
package com.skillswap.utils;

import com.skillswap.model.MatchReason;
import com.skillswap.model.MatchResult;
import com.skillswap.model.User;
import com.skillswap.model.UserSkill;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

/**
 * INNOVACION 1 - SkillMatch.
 *
 * Calcula un porcentaje de compatibilidad REAL (no aleatorio) entre dos
 * estudiantes aplicando un modelo ponderado sobre 100 puntos:
 *
 *   45 pts  Coincidencia de habilidades (bidireccional)
 *   20 pts  Nivel de quien ensena frente a lo que el otro necesita
 *   12 pts  Modalidad compatible
 *   13 pts  Disponibilidad horaria compartida
 *   10 pts  Reputacion del estudiante
 *  ----------------------------------------------------------
 *  100 pts  Total
 *
 * Si no existe ninguna coincidencia de habilidades en ninguna direccion,
 * el resultado es 0: no hay match posible.
 */
public final class SkillMatchEngine {

    public static final int W_SKILLS = 45;
    public static final int W_LEVEL = 20;
    public static final int W_MODALITY = 12;
    public static final int W_AVAILABILITY = 13;
    public static final int W_REPUTATION = 10;

    /** Umbral a partir del cual se considera "match". */
    public static final int MATCH_THRESHOLD = 40;

    private SkillMatchEngine() {
    }

    /**
     * Calcula el match entre el usuario actual (me) y otro estudiante (other).
     */
    public static MatchResult calculate(User me, User other) {
        MatchResult result = new MatchResult();
        result.setUser(other);
        result.setUserAId(me == null ? "" : me.getUid());
        result.setUserBId(other == null ? "" : other.getUid());
        List<MatchReason> reasons = new ArrayList<>();

        if (me == null || other == null) {
            result.setScore(0);
            return result;
        }

        // ---------------------------------------------------------- 1. Habilidades
        List<UserSkill> theyTeachIWant = intersect(other.getTeachSkills(), me.getLearnSkills());
        List<UserSkill> iTeachTheyWant = intersect(me.getTeachSkills(), other.getLearnSkills());

        for (UserSkill s : theyTeachIWant) result.getTheyTeachYouWant().add(s.getName());
        for (UserSkill s : iTeachTheyWant) result.getYouTeachTheyWant().add(s.getName());

        if (theyTeachIWant.isEmpty() && iTeachTheyWant.isEmpty()) {
            result.setScore(0);
            reasons.add(new MatchReason("No hay habilidades complementarias por ahora", false, 0));
            result.setReasons(reasons);
            return result;
        }

        double halfWeight = W_SKILLS / 2.0;
        double skillScore = halfWeight * coverage(theyTeachIWant.size())
                + halfWeight * coverage(iTeachTheyWant.size());

        boolean mutual = !theyTeachIWant.isEmpty() && !iTeachTheyWant.isEmpty();
        result.setMutual(mutual);

        String otherName = other.getShortName();
        for (UserSkill s : theyTeachIWant) {
            reasons.add(new MatchReason(otherName + " enseña " + s.getName(), true, 0));
            reasons.add(new MatchReason("Tú buscas " + s.getName(), true, 0));
        }
        for (UserSkill s : iTeachTheyWant) {
            reasons.add(new MatchReason("Tú enseñas " + s.getName(), true, 0));
            reasons.add(new MatchReason(otherName + " busca " + s.getName(), true, 0));
        }
        if (!mutual) {
            reasons.add(new MatchReason("El intercambio aún no es recíproco", false, 0));
        }

        // ---------------------------------------------------------- 2. Nivel
        double levelScore = 0;
        double halfLevel = W_LEVEL / 2.0;
        if (!theyTeachIWant.isEmpty()) {
            levelScore += halfLevel * averageLevelQuality(theyTeachIWant);
        }
        if (!iTeachTheyWant.isEmpty()) {
            levelScore += halfLevel * averageLevelQuality(iTeachTheyWant);
        }
        String bestLevel = bestLevelLabel(theyTeachIWant);
        if (bestLevel != null) {
            reasons.add(new MatchReason("Nivel de enseñanza: " + bestLevel, true, 0));
        }

        // ---------------------------------------------------------- 3. Modalidad
        double modalityScore;
        boolean modalityOk = modalityCompatible(me.getModality(), other.getModality());
        if (isBlank(me.getModality()) || isBlank(other.getModality())) {
            modalityScore = W_MODALITY * 0.6;
            reasons.add(new MatchReason("Modalidad por confirmar", false, 0));
        } else if (modalityOk) {
            modalityScore = W_MODALITY;
            reasons.add(new MatchReason("Modalidad compatible (" + commonModality(me.getModality(), other.getModality()) + ")", true, 0));
        } else {
            modalityScore = 0;
            reasons.add(new MatchReason("Modalidades distintas", false, 0));
        }

        // ---------------------------------------------------------- 4. Disponibilidad
        double availabilityScore;
        int shared = sharedSlots(me.getAvailability(), other.getAvailability());
        int minSize = Math.min(safeSize(me.getAvailability()), safeSize(other.getAvailability()));
        if (minSize == 0) {
            availabilityScore = W_AVAILABILITY * 0.5;
            reasons.add(new MatchReason("Horarios por definir", false, 0));
        } else if (shared == 0) {
            availabilityScore = 0;
            reasons.add(new MatchReason("Sin horarios en común", false, 0));
        } else {
            double ratio = (double) shared / (double) minSize;
            availabilityScore = W_AVAILABILITY * ratio;
            reasons.add(new MatchReason("Horarios compatibles (" + shared
                    + (shared == 1 ? " bloque" : " bloques") + ")", true, 0));
        }

        // ---------------------------------------------------------- 5. Reputacion
        double reputationScore;
        if (other.getTotalRatings() <= 0) {
            reputationScore = W_REPUTATION * 0.6;
            reasons.add(new MatchReason("Estudiante nuevo en SkillSwap", false, 0));
        } else {
            reputationScore = W_REPUTATION * clamp(other.getReputation() / 5.0);
            reasons.add(new MatchReason(String.format(Locale.getDefault(),
                    "Reputación %.1f de 5 (%d calificaciones)",
                    other.getReputation(), other.getTotalRatings()), true, 0));
        }

        double total = skillScore + levelScore + modalityScore + availabilityScore + reputationScore;
        int score = (int) Math.round(Math.max(0, Math.min(100, total)));

        result.setScore(score);
        result.setReasons(reasons);
        List<String> texts = new ArrayList<>();
        for (MatchReason r : reasons) texts.add(r.getText());
        result.setReasonTexts(texts);
        List<String> parts = new ArrayList<>();
        parts.add(me.getUid());
        parts.add(other.getUid());
        result.setParticipants(parts);
        result.setCreatedAt(System.currentTimeMillis());
        return result;
    }

    /** Calcula y ordena los matches de una lista de candidatos. */
    public static List<MatchResult> rank(User me, List<User> candidates) {
        List<MatchResult> results = new ArrayList<>();
        if (candidates == null) return results;
        for (User u : candidates) {
            if (u == null || u.getUid() == null) continue;
            if (me != null && u.getUid().equals(me.getUid())) continue;
            MatchResult r = calculate(me, u);
            if (r.getScore() > 0) results.add(r);
        }
        Collections.sort(results, new Comparator<MatchResult>() {
            @Override
            public int compare(MatchResult a, MatchResult b) {
                return Integer.compare(b.getScore(), a.getScore());
            }
        });
        return results;
    }

    // ------------------------------------------------------------- helpers

    /** Cobertura segun la cantidad de coincidencias: 0 -> 0, 1 -> 0.9, 2+ -> 1.0 */
    private static double coverage(int matches) {
        if (matches <= 0) return 0;
        if (matches == 1) return 0.9;
        return 1.0;
    }

    /**
     * Calidad media del nivel de quien ensena:
     * Avanzado 1.0, Intermedio 0.8, Basico 0.55.
     */
    private static double averageLevelQuality(List<UserSkill> teacherSkills) {
        if (teacherSkills.isEmpty()) return 0;
        double sum = 0;
        for (UserSkill s : teacherSkills) {
            switch (s.getLevelValue()) {
                case 3: sum += 1.0; break;
                case 2: sum += 0.8; break;
                default: sum += 0.55; break;
            }
        }
        return sum / teacherSkills.size();
    }

    private static String bestLevelLabel(List<UserSkill> skills) {
        String best = null;
        int bestValue = 0;
        for (UserSkill s : skills) {
            if (s.getLevelValue() > bestValue) {
                bestValue = s.getLevelValue();
                best = s.getLevel();
            }
        }
        return best;
    }

    /** Habilidades de "teacher" que aparecen en la lista de deseos de "learner". */
    private static List<UserSkill> intersect(List<UserSkill> teacherSkills, List<UserSkill> learnerWishes) {
        List<UserSkill> out = new ArrayList<>();
        if (teacherSkills == null || learnerWishes == null) return out;
        Set<String> wishes = new HashSet<>();
        for (UserSkill w : learnerWishes) wishes.add(w.getKey());
        for (UserSkill t : teacherSkills) {
            if (wishes.contains(t.getKey())) out.add(t);
        }
        return out;
    }

    public static boolean modalityCompatible(String a, String b) {
        if (isBlank(a) || isBlank(b)) return true;
        if (Constants.MODALITY_BOTH.equals(a) || Constants.MODALITY_BOTH.equals(b)) return true;
        return a.equals(b);
    }

    private static String commonModality(String a, String b) {
        if (Constants.MODALITY_BOTH.equals(a)) return b;
        return a;
    }

    private static int sharedSlots(List<String> a, List<String> b) {
        if (a == null || b == null) return 0;
        Set<String> sa = new HashSet<>();
        for (String s : a) if (s != null) sa.add(s.toLowerCase(Locale.ROOT).trim());
        int count = 0;
        for (String s : b) {
            if (s != null && sa.contains(s.toLowerCase(Locale.ROOT).trim())) count++;
        }
        return count;
    }

    private static int safeSize(List<String> l) {
        return l == null ? 0 : l.size();
    }

    private static double clamp(double v) {
        return Math.max(0, Math.min(1, v));
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
EOF

# ============================================================ GamificationEngine
cat > "$U/GamificationEngine.java" <<'EOF'
package com.skillswap.utils;

import com.skillswap.model.Badge;
import com.skillswap.model.SkillPointsAccount;

import java.util.ArrayList;
import java.util.List;

/**
 * INNOVACION 4 - SkillPoints.
 * Los SkillPoints son puntos de reconocimiento dentro de la app.
 * NO representan dinero ni tienen valor monetario.
 */
public final class GamificationEngine {

    public static final String LEVEL_BEGINNER = "Principiante";
    public static final String LEVEL_COLLABORATOR = "Colaborador";
    public static final String LEVEL_MENTOR = "Mentor";
    public static final String LEVEL_MASTER = "SkillMaster";

    private static final int[] THRESHOLDS = {0, 100, 300, 700};
    private static final String[] LEVELS = {
            LEVEL_BEGINNER, LEVEL_COLLABORATOR, LEVEL_MENTOR, LEVEL_MASTER
    };

    // Codigos de insignia
    public static final String BADGE_FIRST_STEP = "FIRST_STEP";
    public static final String BADGE_FIRST_SWAP = "FIRST_SWAP";
    public static final String BADGE_MENTOR_5 = "MENTOR_5";
    public static final String BADGE_FIVE_STARS = "FIVE_STARS";
    public static final String BADGE_TEAM_PLAYER = "TEAM_PLAYER";
    public static final String BADGE_COMMITTED = "COMMITTED";
    public static final String BADGE_POLYGLOT = "POLYGLOT";
    public static final String BADGE_MASTER = "SKILL_MASTER";

    private GamificationEngine() {
    }

    public static int levelIndexFor(int points) {
        int idx = 0;
        for (int i = 0; i < THRESHOLDS.length; i++) {
            if (points >= THRESHOLDS[i]) idx = i;
        }
        return idx;
    }

    public static String levelNameFor(int points) {
        return LEVELS[levelIndexFor(points)];
    }

    /** Puntos necesarios para alcanzar el siguiente nivel (0 si ya es el maximo). */
    public static int nextLevelThreshold(int points) {
        int idx = levelIndexFor(points);
        if (idx >= THRESHOLDS.length - 1) return 0;
        return THRESHOLDS[idx + 1];
    }

    /** Progreso 0..100 dentro del nivel actual. */
    public static int levelProgress(int points) {
        int idx = levelIndexFor(points);
        if (idx >= THRESHOLDS.length - 1) return 100;
        int start = THRESHOLDS[idx];
        int end = THRESHOLDS[idx + 1];
        if (end <= start) return 100;
        int p = (int) Math.round(((double) (points - start) / (double) (end - start)) * 100);
        return Math.max(0, Math.min(100, p));
    }

    public static SkillPointsAccount applyPoints(SkillPointsAccount account, int delta) {
        if (account == null) account = new SkillPointsAccount();
        int total = Math.max(0, account.getPoints() + delta);
        account.setPoints(total);
        account.setLevelIndex(levelIndexFor(total));
        account.setLevel(levelNameFor(total));
        account.setPointsForNextLevel(nextLevelThreshold(total));
        account.setUpdatedAt(System.currentTimeMillis());
        return account;
    }

    /** Catalogo de insignias disponibles. */
    public static List<Badge> catalog() {
        List<Badge> badges = new ArrayList<>();
        badges.add(new Badge(BADGE_FIRST_STEP, "Primer paso",
                "Completaste tu perfil de estudiante", "check", "secondary"));
        badges.add(new Badge(BADGE_FIRST_SWAP, "Primer intercambio",
                "Terminaste tu primer intercambio", "swap", "primary"));
        badges.add(new Badge(BADGE_MENTOR_5, "Mentor x5",
                "Completaste 5 intercambios enseñando", "school", "accent"));
        badges.add(new Badge(BADGE_FIVE_STARS, "Cinco estrellas",
                "Recibiste una calificación perfecta", "star", "yellow"));
        badges.add(new Badge(BADGE_TEAM_PLAYER, "Jugador de equipo",
                "Te uniste a un Skill Challenge", "group", "primary"));
        badges.add(new Badge(BADGE_COMMITTED, "Compromiso",
                "Aceptaste un contrato de aprendizaje", "contract", "secondary"));
        badges.add(new Badge(BADGE_POLYGLOT, "Políglota",
                "Intercambiaste una habilidad de idiomas", "language", "accent"));
        badges.add(new Badge(BADGE_MASTER, "SkillMaster",
                "Alcanzaste el nivel máximo de SkillPoints", "trophy", "yellow"));
        return badges;
    }

    public static Badge findInCatalog(String code) {
        for (Badge b : catalog()) {
            if (b.getCode().equals(code)) return b;
        }
        return null;
    }

    public static String reasonLabel(int points) {
        if (points == Constants.POINTS_EXCHANGE_COMPLETED) return "Intercambio completado";
        if (points == Constants.POINTS_GOOD_RATING) return "Buena calificación";
        if (points == Constants.POINTS_PROFILE_COMPLETED) return "Perfil completado";
        if (points == Constants.POINTS_CONTRACT_ACCEPTED) return "Contrato aceptado";
        if (points == Constants.POINTS_CHALLENGE_JOINED) return "Reto colaborativo";
        return "Actividad en SkillSwap";
    }
}
EOF

# ============================================================ FirebaseManager
cat > "$F/FirebaseManager.java" <<'EOF'
package com.skillswap.firebase;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.FirebaseFirestoreSettings;
import com.google.firebase.storage.FirebaseStorage;

/** Punto unico de acceso a las instancias de Firebase. */
public final class FirebaseManager {

    private static FirebaseFirestore firestore;
    private static FirebaseAuth auth;
    private static FirebaseStorage storage;

    private FirebaseManager() {
    }

    public static synchronized FirebaseFirestore db() {
        if (firestore == null) {
            firestore = FirebaseFirestore.getInstance();
            FirebaseFirestoreSettings settings = new FirebaseFirestoreSettings.Builder()
                    .setPersistenceEnabled(true)
                    .build();
            try {
                firestore.setFirestoreSettings(settings);
            } catch (Exception ignored) {
                // Los ajustes solo pueden aplicarse antes del primer uso.
            }
        }
        return firestore;
    }

    public static synchronized FirebaseAuth auth() {
        if (auth == null) auth = FirebaseAuth.getInstance();
        return auth;
    }

    public static synchronized FirebaseStorage storage() {
        if (storage == null) storage = FirebaseStorage.getInstance();
        return storage;
    }

    public static FirebaseUser currentUser() {
        return auth().getCurrentUser();
    }

    public static String uid() {
        FirebaseUser u = currentUser();
        return u == null ? "" : u.getUid();
    }

    public static boolean isLogged() {
        return currentUser() != null;
    }
}
EOF

# ============================================================ FirestoreCollections
cat > "$F/FirestoreCollections.java" <<'EOF'
package com.skillswap.firebase;

import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentReference;
import com.skillswap.utils.Constants;

/** Referencias tipadas a las colecciones de Cloud Firestore. */
public final class FirestoreCollections {

    private FirestoreCollections() {
    }

    public static CollectionReference users() {
        return FirebaseManager.db().collection(Constants.COL_USERS);
    }

    public static DocumentReference user(String uid) {
        return users().document(uid);
    }

    public static CollectionReference skills() {
        return FirebaseManager.db().collection(Constants.COL_SKILLS);
    }

    public static CollectionReference matches() {
        return FirebaseManager.db().collection(Constants.COL_MATCHES);
    }

    public static CollectionReference requests() {
        return FirebaseManager.db().collection(Constants.COL_EXCHANGE_REQUESTS);
    }

    public static CollectionReference exchanges() {
        return FirebaseManager.db().collection(Constants.COL_EXCHANGES);
    }

    public static CollectionReference chats() {
        return FirebaseManager.db().collection(Constants.COL_CHATS);
    }

    public static CollectionReference messages(String chatId) {
        return chats().document(chatId).collection(Constants.COL_MESSAGES);
    }

    public static CollectionReference ratings() {
        return FirebaseManager.db().collection(Constants.COL_RATINGS);
    }

    public static CollectionReference notifications() {
        return FirebaseManager.db().collection(Constants.COL_NOTIFICATIONS);
    }

    public static CollectionReference passport() {
        return FirebaseManager.db().collection(Constants.COL_PASSPORT);
    }

    public static CollectionReference contracts() {
        return FirebaseManager.db().collection(Constants.COL_CONTRACTS);
    }

    public static CollectionReference skillPoints() {
        return FirebaseManager.db().collection(Constants.COL_SKILLPOINTS);
    }

    public static CollectionReference pointsHistory(String uid) {
        return skillPoints().document(uid).collection(Constants.COL_POINTS_HISTORY);
    }

    public static CollectionReference badges() {
        return FirebaseManager.db().collection(Constants.COL_BADGES);
    }

    public static CollectionReference challenges() {
        return FirebaseManager.db().collection(Constants.COL_CHALLENGES);
    }

    public static CollectionReference challengeParticipants() {
        return FirebaseManager.db().collection(Constants.COL_CHALLENGE_PARTICIPANTS);
    }

    public static CollectionReference evidence() {
        return FirebaseManager.db().collection(Constants.COL_EVIDENCE);
    }
}
EOF

echo "Motores y capa Firebase generados."
