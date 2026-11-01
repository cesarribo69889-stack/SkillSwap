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
