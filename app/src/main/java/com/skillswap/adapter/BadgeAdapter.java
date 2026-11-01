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
