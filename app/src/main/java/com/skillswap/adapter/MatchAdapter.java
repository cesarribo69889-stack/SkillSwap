package com.skillswap.adapter;

import android.content.res.ColorStateList;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.R;
import com.skillswap.databinding.ItemMatchCardBinding;
import com.skillswap.model.MatchResult;
import com.skillswap.model.User;
import com.skillswap.utils.ChipFactory;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/** Tarjetas de estudiantes en la pantalla Explorar. */
public class MatchAdapter extends RecyclerView.Adapter<MatchAdapter.VH> {

    public interface OnMatchAction {
        void onViewProfile(MatchResult match);

        void onExchange(MatchResult match);
    }

    private final List<MatchResult> items = new ArrayList<>();
    private final OnMatchAction listener;

    public MatchAdapter(OnMatchAction listener) {
        this.listener = listener;
    }

    public void submit(List<MatchResult> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemMatchCardBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final MatchResult m = items.get(position);
        final User u = m.getUser();
        if (u == null) return;

        holder.b.txtName.setText(u.getFullName());
        holder.b.txtCareer.setText(u.getAcademicLine());
        holder.b.txtRating.setText(u.getTotalRatings() > 0
                ? String.format(Locale.getDefault(), "%.1f", u.getReputation())
                : "Nuevo");
        holder.b.txtExchanges.setText(holder.itemView.getResources().getQuantityString(
                R.plurals.plu_exchanges, u.getExchangesCount(), u.getExchangesCount()));

        holder.b.txtScore.setText(String.format(Locale.getDefault(), "%d%%", m.getScore()));
        int color = ContextCompat.getColor(holder.itemView.getContext(),
                UiUtils.compatibilityColor(m.getScore()));
        holder.b.txtScore.setTextColor(color);
        holder.b.txtScore.setBackgroundTintList(ColorStateList.valueOf(withAlpha(color, 32)));
        holder.b.txtScoreLabel.setText(UiUtils.compatibilityLabel(m.getScore()));

        holder.b.txtTeaches.setText(m.getTheyTeachYouWant().isEmpty()
                ? "—" : first(m.getTheyTeachYouWant()));
        holder.b.txtLearns.setText(m.getYouTeachTheyWant().isEmpty()
                ? "—" : first(m.getYouTeachTheyWant()));

        ChipFactory.fillSkills(holder.b.chipsSkills, u.getTeachSkills(), true);
        ImageLoader.avatar(holder.b.imgAvatar, u.getPhotoUrl());

        holder.b.btnProfile.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onViewProfile(m);
            }
        });
        holder.b.btnExchange.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onExchange(m);
            }
        });
        holder.b.getRoot().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onViewProfile(m);
            }
        });
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    private String first(List<String> values) {
        return values.isEmpty() ? "—" : values.get(0);
    }

    private static int withAlpha(int color, int alpha) {
        return (alpha << 24) | (color & 0x00FFFFFF);
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemMatchCardBinding b;

        VH(ItemMatchCardBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
