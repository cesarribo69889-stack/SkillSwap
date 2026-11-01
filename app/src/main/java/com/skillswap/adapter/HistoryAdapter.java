package com.skillswap.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.databinding.ItemHistoryBinding;
import com.skillswap.model.Exchange;
import com.skillswap.utils.DateUtils;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;

/** Historial de intercambios completados. */
public class HistoryAdapter extends RecyclerView.Adapter<HistoryAdapter.VH> {

    public interface OnHistoryAction {
        void onRate(Exchange exchange);

        void onOpen(Exchange exchange);
    }

    private final List<Exchange> items = new ArrayList<>();
    private final String myUid;
    private final OnHistoryAction listener;

    public HistoryAdapter(String myUid, OnHistoryAction listener) {
        this.myUid = myUid;
        this.listener = listener;
    }

    public void submit(List<Exchange> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemHistoryBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final Exchange e = items.get(position);

        holder.b.txtName.setText(e.getPartnerName(myUid));
        holder.b.txtDate.setText(DateUtils.formatDate(
                e.getEndDate() > 0 ? e.getEndDate() : e.getStartDate()));
        holder.b.txtTaught.setText(e.getSkillITeach(myUid));
        holder.b.txtLearned.setText(e.getSkillILearn(myUid));

        boolean rated = e.hasRated(myUid);
        holder.b.txtRating.setText(rated ? "Calificado" : "Sin calificar");
        UiUtils.visible(holder.b.btnRate, !rated);

        ImageLoader.avatar(holder.b.imgAvatar, e.getPartnerPhoto(myUid));

        holder.b.btnRate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onRate(e);
            }
        });
        holder.b.getRoot().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onOpen(e);
            }
        });
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemHistoryBinding b;

        VH(ItemHistoryBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
