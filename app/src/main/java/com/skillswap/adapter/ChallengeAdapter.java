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
public class   ChallengeAdapter extends RecyclerView.Adapter<ChallengeAdapter.VH> {

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
        holder.b.txtParticipants.setText(holder.itemView.getResources().getQuantityString(
                R.plurals.plu_participants_of, c.getMaxParticipants(),
                c.getParticipantsCount(), c.getMaxParticipants()));
        holder.b.txtProgress.setText(holder.itemView.getContext().getString(
                R.string.fmt_percent, c.getProgress()));
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
            holder.b.btnJoin.setText(R.string.st_already_joined);
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
