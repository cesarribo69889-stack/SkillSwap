#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
A="$J/adapter"
mkdir -p "$A"

# ============================================================ RatingAdapter
cat > "$A/RatingAdapter.java" <<'EOF'
package com.skillswap.adapter;

import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.databinding.ItemRatingBinding;
import com.skillswap.model.Rating;
import com.skillswap.utils.DateUtils;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/** Calificaciones recibidas por un estudiante. */
public class RatingAdapter extends RecyclerView.Adapter<RatingAdapter.VH> {

    private final List<Rating> items = new ArrayList<>();

    public void submit(List<Rating> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemRatingBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        Rating r = items.get(position);
        holder.b.txtName.setText(r.getFromUserName());
        holder.b.txtSkill.setText(r.getSkillTaught());
        holder.b.txtStars.setText(String.format(Locale.getDefault(), "%.1f", r.getOverall()));
        holder.b.txtDate.setText(DateUtils.timeAgo(r.getCreatedAt()));

        boolean hasComment = r.getComment() != null && !r.getComment().trim().isEmpty();
        UiUtils.visible(holder.b.txtComment, hasComment);
        holder.b.txtComment.setText(hasComment ? "“" + r.getComment() + "”" : "");

        ImageLoader.avatar(holder.b.imgAvatar, r.getFromUserPhoto());
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemRatingBinding b;

        VH(ItemRatingBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
EOF

# ============================================================ NotificationAdapter
cat > "$A/NotificationAdapter.java" <<'EOF'
package com.skillswap.adapter;

import android.content.res.ColorStateList;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.R;
import com.skillswap.databinding.ItemNotificationBinding;
import com.skillswap.model.AppNotification;
import com.skillswap.utils.DateUtils;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;

/** Centro interno de notificaciones. */
public class NotificationAdapter extends RecyclerView.Adapter<NotificationAdapter.VH> {

    public interface OnNotificationClick {
        void onClick(AppNotification notification);
    }

    private final List<AppNotification> items = new ArrayList<>();
    private final OnNotificationClick listener;

    public NotificationAdapter(OnNotificationClick listener) {
        this.listener = listener;
    }

    public void submit(List<AppNotification> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemNotificationBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final AppNotification n = items.get(position);

        holder.b.txtTitle.setText(n.getTitle());
        holder.b.txtBody.setText(n.getBody());
        holder.b.txtTime.setText(DateUtils.timeAgo(n.getCreatedAt()));
        UiUtils.visible(holder.b.dotUnread, !n.isRead());

        int icon = iconFor(n.getType());
        int color = ContextCompat.getColor(holder.itemView.getContext(), colorFor(n.getType()));
        holder.b.imgIcon.setImageResource(icon);
        holder.b.imgIcon.setImageTintList(ColorStateList.valueOf(color));
        holder.b.iconWrap.setBackgroundTintList(ColorStateList.valueOf(withAlpha(color, 30)));

        holder.b.getRoot().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onClick(n);
            }
        });
    }

    private int iconFor(String type) {
        if (type == null) return R.drawable.ic_notifications;
        switch (type) {
            case AppNotification.TYPE_NEW_REQUEST:
                return R.drawable.ic_inbox;
            case AppNotification.TYPE_REQUEST_ACCEPTED:
                return R.drawable.ic_check_circle;
            case AppNotification.TYPE_REQUEST_REJECTED:
                return R.drawable.ic_close;
            case AppNotification.TYPE_NEW_MESSAGE:
                return R.drawable.ic_chat;
            case AppNotification.TYPE_NEW_MATCH:
                return R.drawable.ic_target;
            case AppNotification.TYPE_EXCHANGE_COMPLETED:
                return R.drawable.ic_swap;
            case AppNotification.TYPE_NEW_RATING:
                return R.drawable.ic_star;
            case AppNotification.TYPE_BADGE:
                return R.drawable.ic_trophy;
            case AppNotification.TYPE_CHALLENGE:
                return R.drawable.ic_challenge;
            default:
                return R.drawable.ic_notifications;
        }
    }

    private int colorFor(String type) {
        if (type == null) return R.color.brand_primary;
        switch (type) {
            case AppNotification.TYPE_REQUEST_ACCEPTED:
            case AppNotification.TYPE_EXCHANGE_COMPLETED:
                return R.color.state_accepted;
            case AppNotification.TYPE_REQUEST_REJECTED:
                return R.color.state_rejected;
            case AppNotification.TYPE_NEW_MESSAGE:
                return R.color.brand_secondary_dark;
            case AppNotification.TYPE_NEW_RATING:
            case AppNotification.TYPE_BADGE:
                return R.color.star_gold;
            case AppNotification.TYPE_CHALLENGE:
                return R.color.state_progress;
            default:
                return R.color.brand_primary;
        }
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    private static int withAlpha(int color, int alpha) {
        return (alpha << 24) | (color & 0x00FFFFFF);
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemNotificationBinding b;

        VH(ItemNotificationBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
EOF

# ============================================================ PassportAdapter
cat > "$A/PassportAdapter.java" <<'EOF'
package com.skillswap.adapter;

import android.content.res.ColorStateList;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.databinding.ItemPassportBinding;
import com.skillswap.model.PassportEntry;
import com.skillswap.utils.SkillCatalog;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/** Entradas del Pasaporte de Habilidades. */
public class PassportAdapter extends RecyclerView.Adapter<PassportAdapter.VH> {

    private final List<PassportEntry> items = new ArrayList<>();

    public void submit(List<PassportEntry> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemPassportBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        PassportEntry e = items.get(position);
        String category = e.getCategory() == null || e.getCategory().isEmpty()
                ? SkillCatalog.categoryOf(e.getSkillName()) : e.getCategory();
        int color = ContextCompat.getColor(holder.itemView.getContext(),
                SkillCatalog.colorForCategory(category));

        holder.b.txtSkill.setText(e.getSkillName());
        holder.b.txtRole.setText(labelFor(e.getRole()) + " · " + category);
        holder.b.imgIcon.setImageResource(SkillCatalog.iconForCategory(category));
        holder.b.imgIcon.setImageTintList(ColorStateList.valueOf(color));
        holder.b.iconWrap.setBackgroundTintList(ColorStateList.valueOf(withAlpha(color, 30)));

        int levelColor = ContextCompat.getColor(holder.itemView.getContext(),
                UiUtils.levelColor(e.getLevel()));
        holder.b.txtLevel.setText(e.getLevel());
        holder.b.txtLevel.setTextColor(levelColor);
        holder.b.txtLevel.setBackgroundTintList(ColorStateList.valueOf(withAlpha(levelColor, 34)));

        holder.b.txtExchanges.setText(e.getSummary());
        holder.b.txtRating.setText(e.getRatingsCount() > 0
                ? String.format(Locale.getDefault(), "%.1f", e.getAverageRating())
                : "—");
        holder.b.progressBar.setProgress(e.getProgress());
    }

    private String labelFor(String role) {
        if (PassportEntry.ROLE_TAUGHT.equals(role)) return "Enseñada";
        if (PassportEntry.ROLE_LEARNED.equals(role)) return "Aprendida";
        return "Practicada";
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    private static int withAlpha(int color, int alpha) {
        return (alpha << 24) | (color & 0x00FFFFFF);
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemPassportBinding b;

        VH(ItemPassportBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
EOF

# ============================================================ BadgeAdapter
cat > "$A/BadgeAdapter.java" <<'EOF'
package com.skillswap.adapter;

import android.content.res.ColorStateList;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.R;
import com.skillswap.databinding.ItemBadgeBinding;
import com.skillswap.model.Badge;

import java.util.ArrayList;
import java.util.List;

/** Insignias desbloqueadas y por desbloquear. */
public class BadgeAdapter extends RecyclerView.Adapter<BadgeAdapter.VH> {

    public interface OnBadgeClick {
        void onClick(Badge badge);
    }

    private final List<Badge> items = new ArrayList<>();
    private final OnBadgeClick listener;

    public BadgeAdapter(OnBadgeClick listener) {
        this.listener = listener;
    }

    public void submit(List<Badge> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemBadgeBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final Badge b = items.get(position);
        int color = ContextCompat.getColor(holder.itemView.getContext(), colorFor(b.getColorKey()));

        holder.b.txtName.setText(b.getName());
        holder.b.imgIcon.setImageResource(iconFor(b.getIconKey()));

        if (b.isUnlocked()) {
            holder.b.imgIcon.setImageTintList(ColorStateList.valueOf(color));
            holder.b.iconWrap.setBackgroundTintList(ColorStateList.valueOf(withAlpha(color, 34)));
            holder.b.getRoot().setAlpha(1f);
        } else {
            int gray = ContextCompat.getColor(holder.itemView.getContext(), R.color.text_tertiary);
            holder.b.imgIcon.setImageTintList(ColorStateList.valueOf(gray));
            holder.b.iconWrap.setBackgroundTintList(ColorStateList.valueOf(withAlpha(gray, 24)));
            holder.b.getRoot().setAlpha(0.55f);
        }

        holder.b.getRoot().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onClick(b);
            }
        });
    }

    private int iconFor(String key) {
        if (key == null) return R.drawable.ic_trophy;
        switch (key) {
            case "check": return R.drawable.ic_check_circle;
            case "swap": return R.drawable.ic_swap;
            case "school": return R.drawable.ic_school;
            case "star": return R.drawable.ic_star;
            case "group": return R.drawable.ic_group;
            case "contract": return R.drawable.ic_contract;
            case "language": return R.drawable.ic_language;
            default: return R.drawable.ic_trophy;
        }
    }

    private int colorFor(String key) {
        if (key == null) return R.color.brand_primary;
        switch (key) {
            case "secondary": return R.color.brand_secondary_dark;
            case "accent": return R.color.brand_accent;
            case "yellow": return R.color.brand_yellow;
            default: return R.color.brand_primary;
        }
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    private static int withAlpha(int color, int alpha) {
        return (alpha << 24) | (color & 0x00FFFFFF);
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemBadgeBinding b;

        VH(ItemBadgeBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
EOF

# ============================================================ PointEntryAdapter
cat > "$A/PointEntryAdapter.java" <<'EOF'
package com.skillswap.adapter;

import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.databinding.ItemPointEntryBinding;
import com.skillswap.model.PointEntry;
import com.skillswap.utils.DateUtils;

import java.util.ArrayList;
import java.util.List;

/** Historial de movimientos de SkillPoints. */
public class PointEntryAdapter extends RecyclerView.Adapter<PointEntryAdapter.VH> {

    private final List<PointEntry> items = new ArrayList<>();

    public void submit(List<PointEntry> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemPointEntryBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        PointEntry p = items.get(position);
        holder.b.txtReason.setText(p.getReason());
        holder.b.txtDate.setText(DateUtils.timeAgo(p.getCreatedAt()));
        holder.b.txtPoints.setText((p.getPoints() >= 0 ? "+" : "") + p.getPoints());
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemPointEntryBinding b;

        VH(ItemPointEntryBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
EOF

# ============================================================ EvidenceAdapter
cat > "$A/EvidenceAdapter.java" <<'EOF'
package com.skillswap.adapter;

import android.content.res.ColorStateList;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.R;
import com.skillswap.databinding.ItemEvidenceBinding;
import com.skillswap.model.LearningEvidence;
import com.skillswap.utils.DateUtils;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;

/** Registros de validacion practica del aprendizaje. */
public class EvidenceAdapter extends RecyclerView.Adapter<EvidenceAdapter.VH> {

    private final List<LearningEvidence> items = new ArrayList<>();

    public void submit(List<LearningEvidence> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemEvidenceBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        LearningEvidence e = items.get(position);

        holder.b.txtSkill.setText(e.getSkillName());
        holder.b.txtActivity.setText(e.getActivity());
        holder.b.txtDate.setText(DateUtils.formatDate(e.getCreatedAt()));

        int color = ContextCompat.getColor(holder.itemView.getContext(),
                e.isObjectiveAchieved() ? R.color.state_accepted : R.color.state_pending);
        holder.b.txtAchieved.setText(e.isObjectiveAchieved()
                ? "Objetivo cumplido" : "En progreso");
        holder.b.txtAchieved.setTextColor(color);
        holder.b.txtAchieved.setBackgroundTintList(ColorStateList.valueOf(withAlpha(color, 32)));

        boolean hasImage = e.getEvidenceUrl() != null && !e.getEvidenceUrl().isEmpty();
        UiUtils.visible(holder.b.imgEvidence, hasImage);
        if (hasImage) {
            ImageLoader.image(holder.b.imgEvidence, e.getEvidenceUrl(), R.drawable.bg_rounded_soft);
        }
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    private static int withAlpha(int color, int alpha) {
        return (alpha << 24) | (color & 0x00FFFFFF);
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemEvidenceBinding b;

        VH(ItemEvidenceBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
EOF

# ============================================================ HistoryAdapter
cat > "$A/HistoryAdapter.java" <<'EOF'
package com.skillswap.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.databinding.ItemHistoryBinding;
import com.skillswap.model.Exchange;
import com.skillswap.utils.DateUtils;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;

/** Historial de intercambios completados. */
public class HistoryAdapter extends RecyclerView.Adapter<HistoryAdapter.VH> {

    public interface OnHistoryAction {
        void onRate(Exchange exchange);

        void onOpen(Exchange exchange);
    }

    private final List<Exchange> items = new ArrayList<>();
    private final String myUid;
    private final OnHistoryAction listener;

    public HistoryAdapter(String myUid, OnHistoryAction listener) {
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
        return new VH(ItemHistoryBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final Exchange e = items.get(position);

        holder.b.txtName.setText(e.getPartnerName(myUid));
        holder.b.txtDate.setText(DateUtils.formatDate(
                e.getEndDate() > 0 ? e.getEndDate() : e.getStartDate()));
        holder.b.txtTaught.setText(e.getSkillITeach(myUid));
        holder.b.txtLearned.setText(e.getSkillILearn(myUid));

        boolean rated = e.hasRated(myUid);
        holder.b.txtRating.setText(rated ? "Calificado" : "Sin calificar");
        UiUtils.visible(holder.b.btnRate, !rated);

        ImageLoader.avatar(holder.b.imgAvatar, e.getPartnerPhoto(myUid));

        holder.b.btnRate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onRate(e);
            }
        });
        holder.b.getRoot().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onOpen(e);
            }
        });
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemHistoryBinding b;

        VH(ItemHistoryBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
EOF

echo "Adapters 3 generados."
