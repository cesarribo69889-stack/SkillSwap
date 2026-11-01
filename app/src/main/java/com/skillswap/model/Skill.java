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
