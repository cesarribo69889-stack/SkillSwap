package com.skillswap.adapter;

import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.databinding.ItemRatingBinding;
import com.skillswap.model.Rating;
import com.skillswap.utils.DateUtils;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/** Calificaciones recibidas por un estudiante. */
public class RatingAdapter extends RecyclerView.Adapter<RatingAdapter.VH> {

    private final List<Rating> items = new ArrayList<>();

    public void submit(List<Rating> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemRatingBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        Rating r = items.get(position);
        holder.b.txtName.setText(r.getFromUserName());
        holder.b.txtSkill.setText(r.getSkillTaught());
        holder.b.txtStars.setText(String.format(Locale.getDefault(), "%.1f", r.getOverall()));
        holder.b.txtDate.setText(DateUtils.timeAgo(r.getCreatedAt()));

        boolean hasComment = r.getComment() != null && !r.getComment().trim().isEmpty();
        UiUtils.visible(holder.b.txtComment, hasComment);
        holder.b.txtComment.setText(hasComment ? "“" + r.getComment() + "”" : "");

        ImageLoader.avatar(holder.b.imgAvatar, r.getFromUserPhoto());
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemRatingBinding b;

        VH(ItemRatingBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
