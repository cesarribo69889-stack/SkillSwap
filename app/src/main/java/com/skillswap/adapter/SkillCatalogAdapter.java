package com.skillswap.adapter;

import android.content.res.ColorStateList;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.databinding.ItemSkillCatalogBinding;
import com.skillswap.model.Skill;
import com.skillswap.utils.SkillCatalog;

import java.util.ArrayList;
import java.util.List;

/** Catalogo global de habilidades. */
public class SkillCatalogAdapter extends RecyclerView.Adapter<SkillCatalogAdapter.VH> {

    public interface OnSkillSelected {
        void onSelected(Skill skill);
    }

    private final List<Skill> items = new ArrayList<>();
    private final OnSkillSelected listener;

    public SkillCatalogAdapter(OnSkillSelected listener) {
        this.listener = listener;
    }

    public void submit(List<Skill> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemSkillCatalogBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final Skill s = items.get(position);
        int color = ContextCompat.getColor(holder.itemView.getContext(),
                SkillCatalog.colorForCategory(s.getCategory()));

        holder.b.txtName.setText(s.getName());
        holder.b.txtCategory.setText(s.getCategory());
        holder.b.imgIcon.setImageResource(SkillCatalog.iconForCategory(s.getCategory()));
        holder.b.imgIcon.setImageTintList(ColorStateList.valueOf(color));
        holder.b.iconWrap.setBackgroundTintList(ColorStateList.valueOf(withAlpha(color, 30)));

        holder.b.getRoot().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onSelected(s);
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
        final ItemSkillCatalogBinding b;

        VH(ItemSkillCatalogBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
