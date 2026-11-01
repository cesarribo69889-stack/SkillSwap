#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
U="$J/utils"; F="$J/firebase"
mkdir -p "$U" "$F"

# ============================================================ Constants
cat > "$U/Constants.java" <<'EOF'
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
EOF

# ============================================================ SkillCatalog
cat > "$U/SkillCatalog.java" <<'EOF'
package com.skillswap.utils;

import com.skillswap.R;
import com.skillswap.model.Skill;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Catalogo local de habilidades. Se usa como semilla de la coleccion
 * "skills" de Firestore y como fuente para los selectores de la app.
 */
public final class SkillCatalog {

    private static final Map<String, List<String>> CATALOG = new LinkedHashMap<>();

    static {
        CATALOG.put(Constants.CAT_PROGRAMMING, listOf("Java", "Python", "JavaScript", "SQL", "HTML/CSS"));
        CATALOG.put(Constants.CAT_DESIGN, listOf("Photoshop", "Illustrator", "Figma", "Canva"));
        CATALOG.put(Constants.CAT_LANGUAGES, listOf("Inglés", "Portugués", "Francés"));
        CATALOG.put(Constants.CAT_ACADEMIC, listOf("Matemática", "Física", "Estadística"));
        CATALOG.put(Constants.CAT_MULTIMEDIA, listOf("Edición de video", "Fotografía", "Animación"));
        CATALOG.put(Constants.CAT_OTHERS, listOf("Excel", "Oratoria", "Marketing", "Música"));
    }

    private SkillCatalog() {
    }

    private static List<String> listOf(String... items) {
        List<String> l = new ArrayList<>();
        for (String i : items) l.add(i);
        return l;
    }

    public static List<String> getCategories() {
        return new ArrayList<>(CATALOG.keySet());
    }

    public static List<String> getSkillNames(String category) {
        List<String> l = CATALOG.get(category);
        return l == null ? new ArrayList<String>() : new ArrayList<>(l);
    }

    public static List<String> getAllSkillNames() {
        List<String> all = new ArrayList<>();
        for (List<String> l : CATALOG.values()) all.addAll(l);
        return all;
    }

    /** Todas las habilidades del catalogo como objetos Skill. */
    public static List<Skill> getAllSkills() {
        List<Skill> all = new ArrayList<>();
        for (Map.Entry<String, List<String>> e : CATALOG.entrySet()) {
            for (String name : e.getValue()) {
                all.add(new Skill(slug(name), name, e.getKey(), iconKeyFor(e.getKey())));
            }
        }
        return all;
    }

    public static String categoryOf(String skillName) {
        if (skillName == null) return Constants.CAT_OTHERS;
        for (Map.Entry<String, List<String>> e : CATALOG.entrySet()) {
            for (String n : e.getValue()) {
                if (n.equalsIgnoreCase(skillName)) return e.getKey();
            }
        }
        return Constants.CAT_OTHERS;
    }

    public static String slug(String name) {
        if (name == null) return "";
        return name.toLowerCase(Locale.ROOT)
                .replace("á", "a").replace("é", "e").replace("í", "i")
                .replace("ó", "o").replace("ú", "u").replace("ñ", "n")
                .replaceAll("[^a-z0-9]+", "_")
                .replaceAll("^_|_$", "");
    }

    /** Habilidades mas populares mostradas en Home. */
    public static List<String> getPopular() {
        return listOf("Java", "Inglés", "Figma", "Excel", "Python", "Matemática", "Photoshop", "Oratoria");
    }

    private static String iconKeyFor(String category) {
        if (Constants.CAT_PROGRAMMING.equals(category)) return "code";
        if (Constants.CAT_DESIGN.equals(category)) return "palette";
        if (Constants.CAT_LANGUAGES.equals(category)) return "language";
        if (Constants.CAT_ACADEMIC.equals(category)) return "math";
        if (Constants.CAT_MULTIMEDIA.equals(category)) return "movie";
        return "apps";
    }

    /** Icono (drawable) asociado a una categoria. */
    public static int iconForCategory(String category) {
        if (Constants.CAT_PROGRAMMING.equals(category)) return R.drawable.ic_code;
        if (Constants.CAT_DESIGN.equals(category)) return R.drawable.ic_palette;
        if (Constants.CAT_LANGUAGES.equals(category)) return R.drawable.ic_language;
        if (Constants.CAT_ACADEMIC.equals(category)) return R.drawable.ic_math;
        if (Constants.CAT_MULTIMEDIA.equals(category)) return R.drawable.ic_movie;
        return R.drawable.ic_apps;
    }

    /** Color asociado a una categoria. */
    public static int colorForCategory(String category) {
        if (Constants.CAT_PROGRAMMING.equals(category)) return R.color.cat_programming;
        if (Constants.CAT_DESIGN.equals(category)) return R.color.cat_design;
        if (Constants.CAT_LANGUAGES.equals(category)) return R.color.cat_languages;
        if (Constants.CAT_ACADEMIC.equals(category)) return R.color.cat_academic;
        if (Constants.CAT_MULTIMEDIA.equals(category)) return R.color.cat_multimedia;
        return R.color.cat_others;
    }

    public static int iconForSkill(String skillName) {
        return iconForCategory(categoryOf(skillName));
    }

    public static int colorForSkill(String skillName) {
        return colorForCategory(categoryOf(skillName));
    }
}
EOF

# ============================================================ Validators
cat > "$U/Validators.java" <<'EOF'
package com.skillswap.utils;

import android.util.Patterns;

import com.google.android.material.textfield.TextInputLayout;

/** Validaciones de formularios. Devuelven null si el valor es valido. */
public final class Validators {

    private Validators() {
    }

    public static String validateName(String value) {
        if (isEmpty(value)) return "Este campo es obligatorio";
        String v = value.trim();
        if (v.length() < 2) return "Mínimo 2 caracteres";
        if (!v.matches("[A-Za-zÁÉÍÓÚáéíóúÑñ\\s'.-]+")) return "Sólo se permiten letras";
        return null;
    }

    public static String validateEmail(String value) {
        if (isEmpty(value)) return "El correo es obligatorio";
        if (!Patterns.EMAIL_ADDRESS.matcher(value.trim()).matches()) {
            return "Correo electrónico no válido";
        }
        return null;
    }

    public static String validatePassword(String value) {
        if (isEmpty(value)) return "La contraseña es obligatoria";
        if (value.length() < Constants.MIN_PASSWORD_LENGTH) {
            return "Mínimo " + Constants.MIN_PASSWORD_LENGTH + " caracteres";
        }
        boolean hasLetter = value.matches(".*[A-Za-z].*");
        boolean hasDigit = value.matches(".*\\d.*");
        if (!hasLetter || !hasDigit) return "Debe incluir letras y números";
        return null;
    }

    public static String validateConfirmPassword(String password, String confirm) {
        if (isEmpty(confirm)) return "Confirma tu contraseña";
        if (!confirm.equals(password)) return "Las contraseñas no coinciden";
        return null;
    }

    public static String validateRequired(String value, String label) {
        if (isEmpty(value)) return label + " es obligatorio";
        return null;
    }

    public static String validateMinLength(String value, int min, String label) {
        if (isEmpty(value)) return label + " es obligatorio";
        if (value.trim().length() < min) return label + " debe tener al menos " + min + " caracteres";
        return null;
    }

    public static String validateIntRange(String value, int min, int max, String label) {
        if (isEmpty(value)) return label + " es obligatorio";
        try {
            int n = Integer.parseInt(value.trim());
            if (n < min || n > max) return label + " debe estar entre " + min + " y " + max;
        } catch (NumberFormatException e) {
            return label + " debe ser un número";
        }
        return null;
    }

    public static boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }

    /** Aplica el error al TextInputLayout y devuelve true si es valido. */
    public static boolean apply(TextInputLayout layout, String error) {
        if (layout == null) return error == null;
        layout.setError(error);
        layout.setErrorEnabled(error != null);
        return error == null;
    }

    public static String text(TextInputLayout layout) {
        if (layout == null || layout.getEditText() == null) return "";
        return layout.getEditText().getText() == null ? "" : layout.getEditText().getText().toString();
    }
}
EOF

# ============================================================ DateUtils
cat > "$U/DateUtils.java" <<'EOF'
package com.skillswap.utils;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

/** Formateo de fechas en espanol. */
public final class DateUtils {

    private static final Locale ES = new Locale("es", "PE");

    private DateUtils() {
    }

    public static String formatDate(long millis) {
        if (millis <= 0) return "--";
        return new SimpleDateFormat("dd MMM yyyy", ES).format(new Date(millis));
    }

    public static String formatDateTime(long millis) {
        if (millis <= 0) return "--";
        return new SimpleDateFormat("dd MMM yyyy · HH:mm", ES).format(new Date(millis));
    }

    public static String formatTime(long millis) {
        if (millis <= 0) return "--";
        return new SimpleDateFormat("HH:mm", ES).format(new Date(millis));
    }

    public static String formatDayHeader(long millis) {
        if (isToday(millis)) return "Hoy";
        if (isYesterday(millis)) return "Ayer";
        return new SimpleDateFormat("EEEE dd 'de' MMMM", ES).format(new Date(millis));
    }

    /** "hace 5 min", "hace 2 h", "hace 3 d", o la fecha. */
    public static String timeAgo(long millis) {
        if (millis <= 0) return "";
        long diff = System.currentTimeMillis() - millis;
        if (diff < TimeUnit.MINUTES.toMillis(1)) return "ahora";
        if (diff < TimeUnit.HOURS.toMillis(1)) {
            long m = TimeUnit.MILLISECONDS.toMinutes(diff);
            return "hace " + m + " min";
        }
        if (diff < TimeUnit.DAYS.toMillis(1)) {
            long h = TimeUnit.MILLISECONDS.toHours(diff);
            return "hace " + h + (h == 1 ? " hora" : " horas");
        }
        long d = TimeUnit.MILLISECONDS.toDays(diff);
        if (d < 7) return "hace " + d + (d == 1 ? " día" : " días");
        if (d < 30) {
            long w = d / 7;
            return "hace " + w + (w == 1 ? " semana" : " semanas");
        }
        return formatDate(millis);
    }

    /** Etiqueta corta para listas de chat. */
    public static String chatStamp(long millis) {
        if (millis <= 0) return "";
        if (isToday(millis)) return formatTime(millis);
        if (isYesterday(millis)) return "Ayer";
        return new SimpleDateFormat("dd/MM", ES).format(new Date(millis));
    }

    public static String daysLeft(long deadline) {
        long diff = deadline - System.currentTimeMillis();
        if (diff <= 0) return "Finalizado";
        long d = TimeUnit.MILLISECONDS.toDays(diff);
        if (d == 0) return "Último día";
        return d + (d == 1 ? " día restante" : " días restantes");
    }

    public static long plusDays(int days) {
        Calendar c = Calendar.getInstance();
        c.add(Calendar.DAY_OF_YEAR, days);
        return c.getTimeInMillis();
    }

    public static boolean isToday(long millis) {
        return sameDay(millis, System.currentTimeMillis());
    }

    public static boolean isYesterday(long millis) {
        Calendar c = Calendar.getInstance();
        c.add(Calendar.DAY_OF_YEAR, -1);
        return sameDay(millis, c.getTimeInMillis());
    }

    public static boolean sameDay(long a, long b) {
        Calendar c1 = Calendar.getInstance();
        Calendar c2 = Calendar.getInstance();
        c1.setTimeInMillis(a);
        c2.setTimeInMillis(b);
        return c1.get(Calendar.YEAR) == c2.get(Calendar.YEAR)
                && c1.get(Calendar.DAY_OF_YEAR) == c2.get(Calendar.DAY_OF_YEAR);
    }
}
EOF

# ============================================================ PrefsManager
cat > "$U/PrefsManager.java" <<'EOF'
package com.skillswap.utils;

import android.content.Context;
import android.content.SharedPreferences;

/** Preferencias locales ligeras (onboarding, cache de nombre). */
public class PrefsManager {

    private static final String FILE = "skillswap_prefs";
    private static final String KEY_ONBOARDING = "onboarding_done";
    private static final String KEY_NAME = "cached_name";
    private static final String KEY_PHOTO = "cached_photo";

    private static PrefsManager instance;
    private final SharedPreferences prefs;

    private PrefsManager(Context context) {
        prefs = context.getApplicationContext().getSharedPreferences(FILE, Context.MODE_PRIVATE);
    }

    public static synchronized PrefsManager get(Context context) {
        if (instance == null) instance = new PrefsManager(context);
        return instance;
    }

    public boolean isOnboardingDone() {
        return prefs.getBoolean(KEY_ONBOARDING, false);
    }

    public void setOnboardingDone(boolean done) {
        prefs.edit().putBoolean(KEY_ONBOARDING, done).apply();
    }

    public String getCachedName() {
        return prefs.getString(KEY_NAME, "");
    }

    public void setCachedName(String name) {
        prefs.edit().putString(KEY_NAME, name == null ? "" : name).apply();
    }

    public String getCachedPhoto() {
        return prefs.getString(KEY_PHOTO, "");
    }

    public void setCachedPhoto(String url) {
        prefs.edit().putString(KEY_PHOTO, url == null ? "" : url).apply();
    }

    public void clear() {
        boolean onboarding = isOnboardingDone();
        prefs.edit().clear().putBoolean(KEY_ONBOARDING, onboarding).apply();
    }
}
EOF

# ============================================================ ImageLoader
cat > "$U/ImageLoader.java" <<'EOF'
package com.skillswap.utils;

import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.DiskCacheStrategy;
import com.skillswap.R;

/** Carga de imagenes con Glide. */
public final class ImageLoader {

    private ImageLoader() {
    }

    public static void avatar(ImageView view, String url) {
        if (view == null) return;
        if (url == null || url.trim().isEmpty()) {
            view.setImageResource(R.drawable.ic_avatar_placeholder);
            return;
        }
        Glide.with(view.getContext())
                .load(url)
                .placeholder(R.drawable.ic_avatar_placeholder)
                .error(R.drawable.ic_avatar_placeholder)
                .diskCacheStrategy(DiskCacheStrategy.ALL)
                .centerCrop()
                .into(view);
    }

    public static void image(ImageView view, String url, int placeholder) {
        if (view == null) return;
        if (url == null || url.trim().isEmpty()) {
            view.setImageResource(placeholder);
            return;
        }
        Glide.with(view.getContext())
                .load(url)
                .placeholder(placeholder)
                .error(placeholder)
                .diskCacheStrategy(DiskCacheStrategy.ALL)
                .centerCrop()
                .into(view);
    }
}
EOF

# ============================================================ UiUtils
cat > "$U/UiUtils.java" <<'EOF'
package com.skillswap.utils;

import android.content.Context;
import android.content.res.ColorStateList;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.TextView;

import androidx.core.content.ContextCompat;

import com.google.android.material.snackbar.Snackbar;
import com.skillswap.R;
import com.skillswap.model.Exchange;
import com.skillswap.model.ExchangeRequest;

/** Utilidades de interfaz: colores de estado, snackbars, teclado. */
public final class UiUtils {

    private UiUtils() {
    }

    // ---------- Estados de solicitud / intercambio ----------
    public static int stateColor(String status) {
        if (status == null) return R.color.state_cancelled;
        switch (status) {
            case ExchangeRequest.STATUS_PENDING:
                return R.color.state_pending;
            case ExchangeRequest.STATUS_ACCEPTED:
                return R.color.state_accepted;
            case ExchangeRequest.STATUS_REJECTED:
                return R.color.state_rejected;
            case ExchangeRequest.STATUS_CANCELLED:
            case Exchange.STATUS_CANCELLED:
                return R.color.state_cancelled;
            case ExchangeRequest.STATUS_IN_PROGRESS:
            case Exchange.STATUS_IN_PROGRESS:
                return R.color.state_progress;
            case ExchangeRequest.STATUS_COMPLETED:
            case Exchange.STATUS_COMPLETED:
                return R.color.state_completed;
            case Exchange.STATUS_UPCOMING:
                return R.color.state_pending;
            default:
                return R.color.state_cancelled;
        }
    }

    public static int stateBackground(String status) {
        if (status == null) return R.color.state_cancelled_bg;
        switch (status) {
            case ExchangeRequest.STATUS_PENDING:
            case Exchange.STATUS_UPCOMING:
                return R.color.state_pending_bg;
            case ExchangeRequest.STATUS_ACCEPTED:
                return R.color.state_accepted_bg;
            case ExchangeRequest.STATUS_REJECTED:
                return R.color.state_rejected_bg;
            case ExchangeRequest.STATUS_IN_PROGRESS:
            case Exchange.STATUS_IN_PROGRESS:
                return R.color.state_progress_bg;
            case ExchangeRequest.STATUS_COMPLETED:
            case Exchange.STATUS_COMPLETED:
                return R.color.state_completed_bg;
            default:
                return R.color.state_cancelled_bg;
        }
    }

    public static String stateLabel(String status) {
        if (status == null) return "";
        switch (status) {
            case ExchangeRequest.STATUS_IN_PROGRESS:
                return "En proceso";
            case Exchange.STATUS_UPCOMING:
                return "Próximo";
            case Exchange.STATUS_COMPLETED:
                return "Completado";
            case Exchange.STATUS_CANCELLED:
                return "Cancelado";
            case ExchangeRequest.STATUS_PENDING:
                return "Pendiente";
            case ExchangeRequest.STATUS_ACCEPTED:
                return "Aceptada";
            case ExchangeRequest.STATUS_REJECTED:
                return "Rechazada";
            case ExchangeRequest.STATUS_CANCELLED:
                return "Cancelada";
            case ExchangeRequest.STATUS_COMPLETED:
                return "Completada";
            default:
                return status;
        }
    }

    /** Pinta un TextView como pildora de estado. */
    public static void bindStatePill(TextView view, String status) {
        if (view == null) return;
        Context c = view.getContext();
        view.setText(stateLabel(status));
        view.setTextColor(ContextCompat.getColor(c, stateColor(status)));
        view.setBackgroundResource(R.drawable.bg_pill);
        view.setBackgroundTintList(ColorStateList.valueOf(
                ContextCompat.getColor(c, stateBackground(status))));
    }

    // ---------- Niveles ----------
    public static int levelColor(String level) {
        if (level == null) return R.color.level_basic;
        if (level.startsWith("Av")) return R.color.level_advanced;
        if (level.startsWith("Int")) return R.color.level_intermediate;
        return R.color.level_basic;
    }

    // ---------- Compatibilidad ----------
    public static int compatibilityColor(int score) {
        if (score >= 85) return R.color.state_accepted;
        if (score >= 65) return R.color.brand_primary;
        if (score >= 45) return R.color.state_pending;
        return R.color.state_cancelled;
    }

    public static String compatibilityLabel(int score) {
        if (score >= 90) return "Match excelente";
        if (score >= 75) return "Muy compatible";
        if (score >= 60) return "Buena opción";
        if (score >= 40) return "Compatibilidad media";
        return "Compatibilidad baja";
    }

    // ---------- Helpers ----------
    public static void snack(View root, String message) {
        if (root == null || message == null) return;
        Snackbar.make(root, message, Snackbar.LENGTH_LONG).show();
    }

    public static void hideKeyboard(View view) {
        if (view == null) return;
        InputMethodManager imm = (InputMethodManager)
                view.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm != null) imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
    }

    public static void visible(View v, boolean show) {
        if (v != null) v.setVisibility(show ? View.VISIBLE : View.GONE);
    }

    public static int dp(Context context, int value) {
        return Math.round(value * context.getResources().getDisplayMetrics().density);
    }
}
EOF

echo "Utils base generados."
