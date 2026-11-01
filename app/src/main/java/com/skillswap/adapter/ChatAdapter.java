package com.skillswap.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.R;
import com.skillswap.databinding.ItemChatBinding;
import com.skillswap.model.Chat;
import com.skillswap.utils.DateUtils;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;

/** Lista de conversaciones. */
public class ChatAdapter extends RecyclerView.Adapter<ChatAdapter.VH> {

    public interface OnChatClick {
        void onChatClick(Chat chat);
    }

    private final List<Chat> items = new ArrayList<>();
    private final String myUid;
    private final OnChatClick listener;

    public ChatAdapter(String myUid, OnChatClick listener) {
        this.myUid = myUid;
        this.listener = listener;
    }

    public void submit(List<Chat> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemChatBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final Chat c = items.get(position);

        holder.b.txtName.setText(c.getPartnerName(myUid));
        holder.b.txtLastMessage.setText(myUid.equals(c.getLastSenderId())
                ? holder.itemView.getContext().getString(
                        R.string.fmt_you_said, c.getLastMessage())
                : c.getLastMessage());
        holder.b.txtTime.setText(DateUtils.chatStamp(c.getLastMessageAt()));

        long unread = c.getUnreadFor(myUid);
        UiUtils.visible(holder.b.txtUnread, unread > 0);
        holder.b.txtUnread.setText(unread > 9 ? "9+" : String.valueOf(unread));

        ImageLoader.avatar(holder.b.imgAvatar, c.getPartnerPhoto(myUid));

        holder.b.getRoot().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onChatClick(c);
            }
        });
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemChatBinding b;

        VH(ItemChatBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
