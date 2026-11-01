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
