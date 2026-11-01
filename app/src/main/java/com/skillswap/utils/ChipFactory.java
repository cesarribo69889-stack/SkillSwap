package com.skillswap.utils;

import android.content.Context;
import android.content.res.ColorStateList;
import android.view.View;

import androidx.core.content.ContextCompat;

import com.google.android.material.chip.Chip;
import com.google.android.material.chip.ChipGroup;
import com.skillswap.R;
import com.skillswap.model.UserSkill;

import java.util.List;

/** Construye chips de habilidades con el estilo de SkillSwap. */
public final class ChipFactory {

    public interface OnChipClick {
        void onClick(String value);
    }

    private ChipFactory() {
    }

    /** Chip informativo coloreado segun la categoria de la habilidad. */
    public static Chip skillChip(Context context, String name, String level) {
        Chip chip = new Chip(context);
        chip.setText(level == null || level.isEmpty() ? name : name + " · " + level);
        chip.setTextSize(12f);
        chip.setChipCornerRadius(UiUtils.dp(context, 14));
        chip.setChipMinHeight(UiUtils.dp(context, 30));
        chip.setEnsureMinTouchTargetSize(false);
        chip.setClickable(false);
        chip.setCheckable(false);

        int color = ContextCompat.getColor(context, SkillCatalog.colorForSkill(name));
        chip.setChipStrokeWidth(0f);
        chip.setChipBackgroundColor(ColorStateList.valueOf(withAlpha(color, 28)));
        chip.setTextColor(color);
        chip.setChipIconVisible(false);
        return chip;
    }

    /** Chip seleccionable (filtros, selección de habilidad). */
    public static Chip choiceChip(Context context, String text, boolean checked) {
        Chip chip = new Chip(context);
        chip.setText(text);
        chip.setCheckable(true);
        chip.setChecked(checked);
        chip.setTextSize(13f);
        chip.setChipCornerRadius(UiUtils.dp(context, 14));
        chip.setChipMinHeight(UiUtils.dp(context, 36));
        chip.setEnsureMinTouchTargetSize(false);
        chip.setCheckedIconVisible(true);
        return chip;
    }

    /** Chip de filtro activo con icono de cierre. */
    public static Chip removableChip(Context context, String text, final String value,
                                     final OnChipClick listener) {
        Chip chip = new Chip(context);
        chip.setText(text);
        chip.setCloseIconVisible(true);
        chip.setTextSize(12f);
        chip.setChipCornerRadius(UiUtils.dp(context, 14));
        chip.setChipMinHeight(UiUtils.dp(context, 32));
        chip.setEnsureMinTouchTargetSize(false);
        chip.setChipBackgroundColor(ColorStateList.valueOf(
                ContextCompat.getColor(context, R.color.brand_primary_container)));
        chip.setTextColor(ContextCompat.getColor(context, R.color.brand_primary_dark));
        chip.setOnCloseIconClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onClick(value);
            }
        });
        return chip;
    }

    /** Rellena un ChipGroup con las habilidades indicadas. */
    public static void fillSkills(ChipGroup group, List<UserSkill> skills, boolean showLevel) {
        if (group == null) return;
        group.removeAllViews();
        if (skills == null) return;
        for (UserSkill s : skills) {
            group.addView(skillChip(group.getContext(), s.getName(),
                    showLevel ? s.getLevel() : null));
        }
    }

    /** Rellena un ChipGroup con textos simples. */
    public static void fillTexts(ChipGroup group, List<String> values) {
        if (group == null) return;
        group.removeAllViews();
        if (values == null) return;
        for (String v : values) {
            group.addView(skillChip(group.getContext(), v, null));
        }
    }

    private static int withAlpha(int color, int alpha) {
        return (alpha << 24) | (color & 0x00FFFFFF);
    }
}
