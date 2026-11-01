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
        holder.b.txtSkill.setText(holder.itemView.getContext().getString(
                R.string.fmt_contributes, p.getSkill()));

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
