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
