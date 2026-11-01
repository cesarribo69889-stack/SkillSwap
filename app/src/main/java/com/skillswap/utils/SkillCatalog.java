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
