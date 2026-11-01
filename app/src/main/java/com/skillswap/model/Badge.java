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
