package com.skillswap.adapter;

import android.content.res.ColorStateList;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.R;
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
        holder.b.txtRole.setText(holder.itemView.getContext().getString(
                R.string.fmt_role_category, labelFor(e.getRole()), category));
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
