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
