package com.skillswap.adapter;

import android.content.res.ColorStateList;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.R;
import com.skillswap.databinding.ItemNotificationBinding;
import com.skillswap.model.AppNotification;
import com.skillswap.utils.DateUtils;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;

/** Centro interno de notificaciones. */
public class NotificationAdapter extends RecyclerView.Adapter<NotificationAdapter.VH> {

    public interface OnNotificationClick {
        void onClick(AppNotification notification);
    }

    private final List<AppNotification> items = new ArrayList<>();
    private final OnNotificationClick listener;

    public NotificationAdapter(OnNotificationClick listener) {
        this.listener = listener;
    }

    public void submit(List<AppNotification> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemNotificationBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final AppNotification n = items.get(position);

        holder.b.txtTitle.setText(n.getTitle());
        holder.b.txtBody.setText(n.getBody());
        holder.b.txtTime.setText(DateUtils.timeAgo(n.getCreatedAt()));
        UiUtils.visible(holder.b.dotUnread, !n.isRead());

        int icon = iconFor(n.getType());
        int color = ContextCompat.getColor(holder.itemView.getContext(), colorFor(n.getType()));
        holder.b.imgIcon.setImageResource(icon);
        holder.b.imgIcon.setImageTintList(ColorStateList.valueOf(color));
        holder.b.iconWrap.setBackgroundTintList(ColorStateList.valueOf(withAlpha(color, 30)));

        holder.b.getRoot().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onClick(n);
            }
        });
    }

    private int iconFor(String type) {
        if (type == null) return R.drawable.ic_notifications;
        switch (type) {
            case AppNotification.TYPE_NEW_REQUEST:
                return R.drawable.ic_inbox;
            case AppNotification.TYPE_REQUEST_ACCEPTED:
                return R.drawable.ic_check_circle;
            case AppNotification.TYPE_REQUEST_REJECTED:
                return R.drawable.ic_close;
            case AppNotification.TYPE_NEW_MESSAGE:
                return R.drawable.ic_chat;
            case AppNotification.TYPE_NEW_MATCH:
                return R.drawable.ic_target;
            case AppNotification.TYPE_EXCHANGE_COMPLETED:
                return R.drawable.ic_swap;
            case AppNotification.TYPE_NEW_RATING:
                return R.drawable.ic_star;
            case AppNotification.TYPE_BADGE:
                return R.drawable.ic_trophy;
            case AppNotification.TYPE_CHALLENGE:
                return R.drawable.ic_challenge;
            default:
                return R.drawable.ic_notifications;
        }
    }

    private int colorFor(String type) {
        if (type == null) return R.color.brand_primary;
        switch (type) {
            case AppNotification.TYPE_REQUEST_ACCEPTED:
            case AppNotification.TYPE_EXCHANGE_COMPLETED:
                return R.color.state_accepted;
            case AppNotification.TYPE_REQUEST_REJECTED:
                return R.color.state_rejected;
            case AppNotification.TYPE_NEW_MESSAGE:
                return R.color.brand_secondary_dark;
            case AppNotification.TYPE_NEW_RATING:
            case AppNotification.TYPE_BADGE:
                return R.color.star_gold;
            case AppNotification.TYPE_CHALLENGE:
                return R.color.state_progress;
            default:
                return R.color.brand_primary;
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
        final ItemNotificationBinding b;

        VH(ItemNotificationBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
