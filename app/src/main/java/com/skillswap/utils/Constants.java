package com.skillswap.utils;

/** Constantes globales de SkillSwap. */
public final class Constants {

    private Constants() {
    }

    // ---------- Colecciones Firestore ----------
    public static final String COL_USERS = "users";
    public static final String COL_SKILLS = "skills";
    public static final String COL_MATCHES = "matches";
    public static final String COL_EXCHANGE_REQUESTS = "exchangeRequests";
    public static final String COL_EXCHANGES = "exchanges";
    public static final String COL_CHATS = "chats";
    public static final String COL_MESSAGES = "messages";
    public static final String COL_RATINGS = "ratings";
    public static final String COL_NOTIFICATIONS = "notifications";
    public static final String COL_PASSPORT = "skillPassport";
    public static final String COL_CONTRACTS = "learningContracts";
    public static final String COL_SKILLPOINTS = "skillPoints";
    public static final String COL_POINTS_HISTORY = "history";
    public static final String COL_BADGES = "badges";
    public static final String COL_CHALLENGES = "challenges";
    public static final String COL_CHALLENGE_PARTICIPANTS = "challengeParticipants";
    public static final String COL_EVIDENCE = "learningEvidence";
    /** RC3 - constancias de aceptacion firmadas. */
    public static final String COL_SIGNATURES = "signatures";
    /** RC3 - ancho maximo de la imagen de firma al guardarla. */
    public static final int SIGNATURE_MAX_WIDTH = 600;

    // ---------- Storage ----------
    public static final String STORAGE_AVATARS = "avatars";
    public static final String STORAGE_EVIDENCE = "evidence";

    // ---------- Modalidades ----------
    public static final String MODALITY_PRESENCIAL = "Presencial";
    public static final String MODALITY_VIRTUAL = "Virtual";
    public static final String MODALITY_BOTH = "Ambas";

    // ---------- Niveles de habilidad ----------
    public static final String LEVEL_BASIC = "Básico";
    public static final String LEVEL_INTERMEDIATE = "Intermedio";
    public static final String LEVEL_ADVANCED = "Avanzado";

    // ---------- Categorias ----------
    public static final String CAT_PROGRAMMING = "Programación";
    public static final String CAT_DESIGN = "Diseño";
    public static final String CAT_LANGUAGES = "Idiomas";
    public static final String CAT_ACADEMIC = "Académico";
    public static final String CAT_MULTIMEDIA = "Multimedia";
    public static final String CAT_OTHERS = "Otros";

    // ---------- Extras de Intent ----------
    public static final String EXTRA_USER_ID = "extra_user_id";
    public static final String EXTRA_USER = "extra_user";
    public static final String EXTRA_MATCH = "extra_match";
    public static final String EXTRA_REQUEST_ID = "extra_request_id";
    public static final String EXTRA_EXCHANGE_ID = "extra_exchange_id";
    public static final String EXTRA_EXCHANGE = "extra_exchange";
    public static final String EXTRA_CHAT_ID = "extra_chat_id";
    public static final String EXTRA_CHALLENGE_ID = "extra_challenge_id";
    public static final String EXTRA_CONTRACT_ID = "extra_contract_id";
    public static final String EXTRA_SKILL_TYPE = "extra_skill_type";
    public static final String EXTRA_PARTNER_ID = "extra_partner_id";
    public static final String EXTRA_PARTNER_NAME = "extra_partner_name";
    public static final String EXTRA_PARTNER_PHOTO = "extra_partner_photo";
    public static final String EXTRA_SKILL_NAME = "extra_skill_name";
    public static final String EXTRA_TAB = "extra_tab";
    public static final String EXTRA_OPEN_SECTION = "extra_open_section";

    // ---------- Canales de notificacion ----------
    public static final String CHANNEL_GENERAL = "skillswap_general";
    public static final String CHANNEL_CHAT = "skillswap_chat";

    // ---------- Gamificacion ----------
    public static final int POINTS_EXCHANGE_COMPLETED = 20;
    public static final int POINTS_GOOD_RATING = 5;
    public static final int POINTS_PROFILE_COMPLETED = 10;
    public static final int POINTS_CONTRACT_ACCEPTED = 8;
    public static final int POINTS_CHALLENGE_JOINED = 10;
    public static final int POINTS_EVIDENCE_REGISTERED = 5;
    public static final int POINTS_FIRST_SKILL = 5;

    // ---------- Limites ----------
    public static final int MAX_SKILLS_PER_TYPE = 12;
    public static final int EXPLORE_PAGE_SIZE = 40;
    public static final int MIN_PASSWORD_LENGTH = 6;
}
