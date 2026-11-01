#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
A="$J/adapter"
mkdir -p "$A"

# ============================================================ ChallengeAdapter
cat > "$A/ChallengeAdapter.java" <<'EOF'
package com.skillswap.adapter;

import android.content.res.ColorStateList;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.R;
import com.skillswap.databinding.ItemChallengeBinding;
import com.skillswap.model.Challenge;
import com.skillswap.utils.ChipFactory;
import com.skillswap.utils.DateUtils;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;

/** Skill Challenges disponibles. */
public class ChallengeAdapter extends RecyclerView.Adapter<ChallengeAdapter.VH> {

    public interface OnChallengeAction {
        void onOpen(Challenge challenge);

        void onJoin(Challenge challenge);
    }

    private static final int[] BANNERS = {
            R.drawable.bg_gradient_blue,
            R.drawable.bg_gradient_purple,
            R.drawable.bg_gradient_teal,
            R.drawable.bg_gradient_coral
    };

    private final List<Challenge> items = new ArrayList<>();
    private final String myUid;
    private final OnChallengeAction listener;

    public ChallengeAdapter(String myUid, OnChallengeAction listener) {
        this.myUid = myUid;
        this.listener = listener;
    }

    public void submit(List<Challenge> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemChallengeBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final Challenge c = items.get(position);

        holder.b.banner.setBackgroundResource(BANNERS[position % BANNERS.length]);
        holder.b.txtTitle.setText(c.getTitle());
        holder.b.txtObjective.setText(c.getObjective());
        holder.b.txtDeadline.setText(DateUtils.daysLeft(c.getDeadline()));
        holder.b.txtParticipants.setText(c.getParticipantsCount() + " de "
                + c.getMaxParticipants() + " participantes");
        holder.b.txtProgress.setText(c.getProgress() + " %");
        holder.b.progressBar.setProgress(c.getProgress());

        int color = ContextCompat.getColor(holder.itemView.getContext(), statusColor(c.getStatus()));
        holder.b.txtStatus.setText(statusLabel(c.getStatus()));
        holder.b.txtStatus.setTextColor(ContextCompat.getColor(
                holder.itemView.getContext(), R.color.white));
        holder.b.txtStatus.setBackgroundTintList(ColorStateList.valueOf(withAlpha(color, 210)));

        ChipFactory.fillTexts(holder.b.chipsSkills, c.getRequiredSkills());

        boolean joined = c.getParticipantIds().contains(myUid);
        boolean canJoin = !joined && !c.isFull() && Challenge.STATUS_OPEN.equals(c.getStatus());
        UiUtils.visible(holder.b.btnJoin, canJoin);
        if (joined) {
            holder.b.btnJoin.setText("Ya participas");
        }

        holder.b.btnJoin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onJoin(c);
            }
        });
        holder.b.getRoot().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onOpen(c);
            }
        });
    }

    private String statusLabel(String status) {
        if (Challenge.STATUS_FINISHED.equals(status)) return "Finalizado";
        if (Challenge.STATUS_IN_PROGRESS.equals(status)) return "En proceso";
        return "Abierto";
    }

    private int statusColor(String status) {
        if (Challenge.STATUS_FINISHED.equals(status)) return R.color.state_completed;
        if (Challenge.STATUS_IN_PROGRESS.equals(status)) return R.color.state_progress;
        return R.color.state_accepted;
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    private static int withAlpha(int color, int alpha) {
        return (alpha << 24) | (color & 0x00FFFFFF);
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemChallengeBinding b;

        VH(ItemChallengeBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
EOF

# ============================================================ ChallengeHomeAdapter
cat > "$A/ChallengeHomeAdapter.java" <<'EOF'
package com.skillswap.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.R;
import com.skillswap.databinding.ItemChallengeHomeBinding;
import com.skillswap.model.Challenge;
import com.skillswap.utils.DateUtils;

import java.util.ArrayList;
import java.util.List;

/** Retos destacados en la pantalla de Inicio. */
public class ChallengeHomeAdapter extends RecyclerView.Adapter<ChallengeHomeAdapter.VH> {

    public interface OnChallengeClick {
        void onClick(Challenge challenge);
    }

    private static final int[] BANNERS = {
            R.drawable.bg_gradient_blue,
            R.drawable.bg_gradient_coral,
            R.drawable.bg_gradient_teal
    };

    private final List<Challenge> items = new ArrayList<>();
    private final OnChallengeClick listener;

    public ChallengeHomeAdapter(OnChallengeClick listener) {
        this.listener = listener;
    }

    public void submit(List<Challenge> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemChallengeHomeBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final Challenge c = items.get(position);
        holder.b.txtTitle.setText(c.getTitle());
        holder.b.txtSkills.setText(joinSkills(c.getRequiredSkills()));
        holder.b.txtDeadline.setText(DateUtils.daysLeft(c.getDeadline()));
        holder.b.getRoot().getChildAt(0)
                .setBackgroundResource(BANNERS[position % BANNERS.length]);

        holder.b.getRoot().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onClick(c);
            }
        });
    }

    private String joinSkills(List<String> values) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < values.size() && i < 3; i++) {
            if (sb.length() > 0) sb.append(" · ");
            sb.append(values.get(i));
        }
        return sb.toString();
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemChallengeHomeBinding b;

        VH(ItemChallengeHomeBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
EOF

# ============================================================ ChallengeParticipantAdapter
cat > "$A/ChallengeParticipantAdapter.java" <<'EOF'
package com.skillswap.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import android.content.res.ColorStateList;

import com.skillswap.R;
import com.skillswap.databinding.ItemChallengeParticipantBinding;
import com.skillswap.model.ChallengeParticipant;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;

/** Postulantes y miembros de un reto. */
public class ChallengeParticipantAdapter
        extends RecyclerView.Adapter<ChallengeParticipantAdapter.VH> {

    public interface OnParticipantAction {
        void onRespond(ChallengeParticipant participant, boolean accept);
    }

    private final List<ChallengeParticipant> items = new ArrayList<>();
    private final OnParticipantAction listener;
    private boolean owner = false;

    public ChallengeParticipantAdapter(OnParticipantAction listener) {
        this.listener = listener;
    }

    public void setOwner(boolean owner) {
        this.owner = owner;
    }

    public void submit(List<ChallengeParticipant> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemChallengeParticipantBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final ChallengeParticipant p = items.get(position);

        holder.b.txtName.setText(p.getUserName());
        holder.b.txtSkill.setText("Aporta " + p.getSkill());

        int color = ContextCompat.getColor(holder.itemView.getContext(), statusColor(p.getStatus()));
        holder.b.txtStatus.setText(p.getStatus());
        holder.b.txtStatus.setTextColor(color);
        holder.b.txtStatus.setBackgroundTintList(ColorStateList.valueOf(withAlpha(color, 32)));

        boolean pending = ChallengeParticipant.STATUS_PENDING.equals(p.getStatus());
        UiUtils.visible(holder.b.actions, owner && pending);

        ImageLoader.avatar(holder.b.imgAvatar, p.getUserPhoto());

        holder.b.btnAccept.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onRespond(p, true);
            }
        });
        holder.b.btnReject.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onRespond(p, false);
            }
        });
    }

    private int statusColor(String status) {
        if (ChallengeParticipant.STATUS_ACCEPTED.equals(status)) return R.color.state_accepted;
        if (ChallengeParticipant.STATUS_REJECTED.equals(status)) return R.color.state_rejected;
        return R.color.state_pending;
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    private static int withAlpha(int color, int alpha) {
        return (alpha << 24) | (color & 0x00FFFFFF);
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemChallengeParticipantBinding b;

        VH(ItemChallengeParticipantBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
EOF

echo "Adapters 4 generados."
