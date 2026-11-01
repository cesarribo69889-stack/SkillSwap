package com.skillswap.adapter;

import android.content.res.ColorStateList;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.databinding.ItemUserSkillBinding;
import com.skillswap.model.UserSkill;
import com.skillswap.utils.SkillCatalog;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;

/** Habilidades del usuario con opciones de editar y eliminar. */
public class UserSkillAdapter extends RecyclerView.Adapter<UserSkillAdapter.VH> {

    public interface OnSkillAction {
        void onEdit(UserSkill skill);

        void onDelete(UserSkill skill);
    }

    private final List<UserSkill> items = new ArrayList<>();
    private final OnSkillAction listener;

    public UserSkillAdapter(OnSkillAction listener) {
        this.listener = listener;
    }

    public void submit(List<UserSkill> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemUserSkillBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final UserSkill s = items.get(position);
        String category = s.getCategory() == null || s.getCategory().isEmpty()
                ? SkillCatalog.categoryOf(s.getName()) : s.getCategory();
        int color = ContextCompat.getColor(holder.itemView.getContext(),
                SkillCatalog.colorForCategory(category));

        holder.b.txtName.setText(s.getName());
        holder.b.txtCategory.setText(category);
        holder.b.imgIcon.setImageResource(SkillCatalog.iconForCategory(category));
        holder.b.imgIcon.setImageTintList(ColorStateList.valueOf(color));
        holder.b.iconWrap.setBackgroundTintList(ColorStateList.valueOf(withAlpha(color, 30)));

        int levelColor = ContextCompat.getColor(holder.itemView.getContext(),
                UiUtils.levelColor(s.getLevel()));
        holder.b.txtLevel.setText(s.getLevel());
        holder.b.txtLevel.setTextColor(levelColor);
        holder.b.txtLevel.setBackgroundTintList(ColorStateList.valueOf(withAlpha(levelColor, 34)));

        holder.b.btnEdit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onEdit(s);
            }
        });
        holder.b.btnDelete.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onDelete(s);
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
        final ItemUserSkillBinding b;

        VH(ItemUserSkillBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
