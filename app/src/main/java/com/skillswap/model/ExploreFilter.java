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
