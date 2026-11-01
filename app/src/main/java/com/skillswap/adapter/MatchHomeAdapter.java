package com.skillswap.adapter;

import android.content.res.ColorStateList;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.R;
import com.skillswap.databinding.ItemMatchHomeBinding;
import com.skillswap.model.MatchResult;
import com.skillswap.model.User;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/** Matches destacados en la pantalla de Inicio. */
public class MatchHomeAdapter extends RecyclerView.Adapter<MatchHomeAdapter.VH> {

    public interface OnMatchClick {
        void onMatchClick(MatchResult match);
    }

    private final List<MatchResult> items = new ArrayList<>();
    private final OnMatchClick listener;

    public MatchHomeAdapter(OnMatchClick listener) {
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
        return new VH(ItemMatchHomeBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final MatchResult m = items.get(position);
        User u = m.getUser();
        if (u == null) return;

        holder.b.txtName.setText(u.getShortName());
        holder.b.txtCareer.setText(u.getCareer());
        holder.b.txtScore.setText(String.format(Locale.getDefault(), "%d %%", m.getScore()));
        holder.b.txtScore.setBackgroundTintList(ColorStateList.valueOf(
                ContextCompat.getColor(holder.itemView.getContext(),
                        UiUtils.compatibilityColor(m.getScore()))));

        if (!m.getTheyTeachYouWant().isEmpty()) {
            holder.b.txtTeaches.setText(holder.itemView.getContext().getString(
                    R.string.fmt_teaches, join(m.getTheyTeachYouWant())));
        } else if (!m.getYouTeachTheyWant().isEmpty()) {
            holder.b.txtTeaches.setText(holder.itemView.getContext().getString(
                    R.string.fmt_searches, join(m.getYouTeachTheyWant())));
        } else {
            holder.b.txtTeaches.setText("");
        }

        ImageLoader.avatar(holder.b.imgAvatar, u.getPhotoUrl());

        holder.b.getRoot().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onMatchClick(m);
            }
        });
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    private String join(List<String> values) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < values.size() && i < 2; i++) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(values.get(i));
        }
        return sb.toString();
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemMatchHomeBinding b;

        VH(ItemMatchHomeBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
