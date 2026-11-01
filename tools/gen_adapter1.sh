#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
A="$J/adapter"; U="$J/utils"
mkdir -p "$A"

# ============================================================ ChipFactory
cat > "$U/ChipFactory.java" <<'EOF'
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
EOF

# ============================================================ OnboardingAdapter
cat > "$A/OnboardingAdapter.java" <<'EOF'
package com.skillswap.adapter;

import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.R;
import com.skillswap.databinding.ItemOnboardingBinding;

/** Paginas del onboarding. */
public class OnboardingAdapter extends RecyclerView.Adapter<OnboardingAdapter.VH> {

    private static final int[] ICONS = {
            R.drawable.ic_swap, R.drawable.ic_target, R.drawable.ic_trophy
    };
    private static final int[] TITLES = {
            R.string.ob1_title, R.string.ob2_title, R.string.ob3_title
    };
    private static final int[] DESCS = {
            R.string.ob1_desc, R.string.ob2_desc, R.string.ob3_desc
    };

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemOnboardingBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        holder.binding.imgIcon.setImageResource(ICONS[position]);
        holder.binding.txtTitle.setText(TITLES[position]);
        holder.binding.txtDesc.setText(DESCS[position]);
    }

    @Override
    public int getItemCount() {
        return ICONS.length;
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemOnboardingBinding binding;

        VH(ItemOnboardingBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
        }
    }
}
EOF

# ============================================================ PopularSkillAdapter
cat > "$A/PopularSkillAdapter.java" <<'EOF'
package com.skillswap.adapter;

import android.content.res.ColorStateList;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.databinding.ItemPopularSkillBinding;
import com.skillswap.utils.SkillCatalog;

import java.util.ArrayList;
import java.util.List;

/** Habilidades populares mostradas en Home. */
public class PopularSkillAdapter extends RecyclerView.Adapter<PopularSkillAdapter.VH> {

    public interface OnSkillClick {
        void onSkillClick(String skillName);
    }

    private final List<String> items = new ArrayList<>();
    private final OnSkillClick listener;

    public PopularSkillAdapter(OnSkillClick listener) {
        this.listener = listener;
    }

    public void submit(List<String> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemPopularSkillBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final String name = items.get(position);
        String category = SkillCatalog.categoryOf(name);
        int color = ContextCompat.getColor(holder.itemView.getContext(),
                SkillCatalog.colorForCategory(category));

        holder.b.txtName.setText(name);
        holder.b.txtCategory.setText(category);
        holder.b.imgIcon.setImageResource(SkillCatalog.iconForCategory(category));
        holder.b.imgIcon.setImageTintList(ColorStateList.valueOf(color));
        holder.b.iconWrap.setBackgroundTintList(ColorStateList.valueOf(withAlpha(color, 30)));
        holder.b.getRoot().setStrokeColor(withAlpha(color, 60));

        holder.b.getRoot().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onSkillClick(name);
            }
        });
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    private static int withAlpha(int color, int alpha) {
        return (alpha << 24) | (color & 0x00FFFFFF);
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemPopularSkillBinding b;

        VH(ItemPopularSkillBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
EOF

# ============================================================ MatchHomeAdapter
cat > "$A/MatchHomeAdapter.java" <<'EOF'
package com.skillswap.adapter;

import android.content.res.ColorStateList;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.databinding.ItemMatchHomeBinding;
import com.skillswap.model.MatchResult;
import com.skillswap.model.User;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/** Matches destacados en la pantalla de Inicio. */
public class MatchHomeAdapter extends RecyclerView.Adapter<MatchHomeAdapter.VH> {

    public interface OnMatchClick {
        void onMatchClick(MatchResult match);
    }

    private final List<MatchResult> items = new ArrayList<>();
    private final OnMatchClick listener;

    public MatchHomeAdapter(OnMatchClick listener) {
        this.listener = listener;
    }

    public void submit(List<MatchResult> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemMatchHomeBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final MatchResult m = items.get(position);
        User u = m.getUser();
        if (u == null) return;

        holder.b.txtName.setText(u.getShortName());
        holder.b.txtCareer.setText(u.getCareer());
        holder.b.txtScore.setText(String.format(Locale.getDefault(), "%d %%", m.getScore()));
        holder.b.txtScore.setBackgroundTintList(ColorStateList.valueOf(
                ContextCompat.getColor(holder.itemView.getContext(),
                        UiUtils.compatibilityColor(m.getScore()))));

        if (!m.getTheyTeachYouWant().isEmpty()) {
            holder.b.txtTeaches.setText("Enseña " + join(m.getTheyTeachYouWant()));
        } else if (!m.getYouTeachTheyWant().isEmpty()) {
            holder.b.txtTeaches.setText("Busca " + join(m.getYouTeachTheyWant()));
        } else {
            holder.b.txtTeaches.setText("");
        }

        ImageLoader.avatar(holder.b.imgAvatar, u.getPhotoUrl());

        holder.b.getRoot().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onMatchClick(m);
            }
        });
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    private String join(List<String> values) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < values.size() && i < 2; i++) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(values.get(i));
        }
        return sb.toString();
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemMatchHomeBinding b;

        VH(ItemMatchHomeBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
EOF

# ============================================================ MatchAdapter (Explorar)
cat > "$A/MatchAdapter.java" <<'EOF'
package com.skillswap.adapter;

import android.content.res.ColorStateList;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.databinding.ItemMatchCardBinding;
import com.skillswap.model.MatchResult;
import com.skillswap.model.User;
import com.skillswap.utils.ChipFactory;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/** Tarjetas de estudiantes en la pantalla Explorar. */
public class MatchAdapter extends RecyclerView.Adapter<MatchAdapter.VH> {

    public interface OnMatchAction {
        void onViewProfile(MatchResult match);

        void onExchange(MatchResult match);
    }

    private final List<MatchResult> items = new ArrayList<>();
    private final OnMatchAction listener;

    public MatchAdapter(OnMatchAction listener) {
        this.listener = listener;
    }

    public void submit(List<MatchResult> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemMatchCardBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final MatchResult m = items.get(position);
        final User u = m.getUser();
        if (u == null) return;

        holder.b.txtName.setText(u.getFullName());
        holder.b.txtCareer.setText(u.getAcademicLine());
        holder.b.txtRating.setText(u.getTotalRatings() > 0
                ? String.format(Locale.getDefault(), "%.1f", u.getReputation())
                : "Nuevo");
        holder.b.txtExchanges.setText(u.getExchangesCount() + " intercambios");

        holder.b.txtScore.setText(String.format(Locale.getDefault(), "%d%%", m.getScore()));
        int color = ContextCompat.getColor(holder.itemView.getContext(),
                UiUtils.compatibilityColor(m.getScore()));
        holder.b.txtScore.setTextColor(color);
        holder.b.txtScore.setBackgroundTintList(ColorStateList.valueOf(withAlpha(color, 32)));
        holder.b.txtScoreLabel.setText(UiUtils.compatibilityLabel(m.getScore()));

        holder.b.txtTeaches.setText(m.getTheyTeachYouWant().isEmpty()
                ? "—" : first(m.getTheyTeachYouWant()));
        holder.b.txtLearns.setText(m.getYouTeachTheyWant().isEmpty()
                ? "—" : first(m.getYouTeachTheyWant()));

        ChipFactory.fillSkills(holder.b.chipsSkills, u.getTeachSkills(), true);
        ImageLoader.avatar(holder.b.imgAvatar, u.getPhotoUrl());

        holder.b.btnProfile.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onViewProfile(m);
            }
        });
        holder.b.btnExchange.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onExchange(m);
            }
        });
        holder.b.getRoot().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onViewProfile(m);
            }
        });
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    private String first(List<String> values) {
        return values.isEmpty() ? "—" : values.get(0);
    }

    private static int withAlpha(int color, int alpha) {
        return (alpha << 24) | (color & 0x00FFFFFF);
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemMatchCardBinding b;

        VH(ItemMatchCardBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
EOF

# ============================================================ ExchangeAdapter
cat > "$A/ExchangeAdapter.java" <<'EOF'
package com.skillswap.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.databinding.ItemExchangeBinding;
import com.skillswap.model.Exchange;
import com.skillswap.utils.DateUtils;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;

/** Lista de intercambios del usuario. */
public class ExchangeAdapter extends RecyclerView.Adapter<ExchangeAdapter.VH> {

    public interface OnExchangeAction {
        void onOpenChat(Exchange exchange);

        void onOpenDetail(Exchange exchange);
    }

    private final List<Exchange> items = new ArrayList<>();
    private final String myUid;
    private final OnExchangeAction listener;

    public ExchangeAdapter(String myUid, OnExchangeAction listener) {
        this.myUid = myUid;
        this.listener = listener;
    }

    public void submit(List<Exchange> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemExchangeBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final Exchange e = items.get(position);

        holder.b.txtName.setText(e.getPartnerName(myUid));
        holder.b.txtModality.setText(e.getModality());
        holder.b.txtITeach.setText(e.getSkillITeach(myUid));
        holder.b.txtILearn.setText(e.getSkillILearn(myUid));
        holder.b.txtDate.setText(DateUtils.formatDate(e.getStartDate()));

        UiUtils.bindStatePill(holder.b.txtStatus, e.getStatus());

        holder.b.progressBar.setProgress(e.getProgress());
        if (e.getSessionsTotal() > 0) {
            holder.b.txtProgress.setText("Sesión " + e.getSessionsDone() + " de "
                    + e.getSessionsTotal());
        } else {
            holder.b.txtProgress.setText(e.getProgress() + " % completado");
        }

        ImageLoader.avatar(holder.b.imgAvatar, e.getPartnerPhoto(myUid));

        holder.b.btnChat.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onOpenChat(e);
            }
        });
        View.OnClickListener detail = new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onOpenDetail(e);
            }
        };
        holder.b.btnDetail.setOnClickListener(detail);
        holder.b.getRoot().setOnClickListener(detail);
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemExchangeBinding b;

        VH(ItemExchangeBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
EOF

echo "Adapters 1 generados."
