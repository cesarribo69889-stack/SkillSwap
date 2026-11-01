package com.skillswap.model;

import java.io.Serializable;

/** Una linea de explicacion del SkillMatch. */
public class MatchReason implements Serializable {

    private String text = "";
    private boolean positive = true;
    private int weight = 0;

    public MatchReason() {
    }

    public MatchReason(String text, boolean positive, int weight) {
        this.text = text;
        this.positive = positive;
        this.weight = weight;
    }

    public String getText() { return text; }
    public void setText(String text) { this.text = text; }

    public boolean isPositive() { return positive; }
    public void setPositive(boolean positive) { this.positive = positive; }

    public int getWeight() { return weight; }
    public void setWeight(int weight) { this.weight = weight; }
}
