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
            // HU06: un perfil incompleto no se ofrece como coincidencia.
            if (!u.isProfileCompleted()) continue;
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
