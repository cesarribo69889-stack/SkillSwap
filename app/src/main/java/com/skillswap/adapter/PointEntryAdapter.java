package com.skillswap.adapter;

import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.R;
import com.skillswap.databinding.ItemPointEntryBinding;
import com.skillswap.model.PointEntry;
import com.skillswap.utils.DateUtils;

import java.util.ArrayList;
import java.util.List;

/** Historial de movimientos de SkillPoints. */
public class PointEntryAdapter extends RecyclerView.Adapter<PointEntryAdapter.VH> {

    private final List<PointEntry> items = new ArrayList<>();

    public void submit(List<PointEntry> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemPointEntryBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        PointEntry p = items.get(position);
        holder.b.txtReason.setText(p.getReason());
        holder.b.txtDate.setText(DateUtils.timeAgo(p.getCreatedAt()));
        holder.b.txtPoints.setText(holder.itemView.getContext().getString(
                R.string.fmt_points_delta,
                p.getPoints() >= 0 ? "+" : "", p.getPoints()));
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemPointEntryBinding b;

        VH(ItemPointEntryBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
