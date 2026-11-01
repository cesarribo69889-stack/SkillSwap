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
