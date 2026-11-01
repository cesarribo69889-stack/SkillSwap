package com.skillswap.adapter;

import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.databinding.ItemMessageReceivedBinding;
import com.skillswap.databinding.ItemMessageSentBinding;
import com.skillswap.databinding.ItemMessageSystemBinding;
import com.skillswap.model.ChatMessage;
import com.skillswap.utils.DateUtils;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;

/** Mensajes del chat: enviados, recibidos y del sistema. */
public class MessageAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private static final int TYPE_SENT = 1;
    private static final int TYPE_RECEIVED = 2;
    private static final int TYPE_SYSTEM = 3;

    private final List<ChatMessage> items = new ArrayList<>();
    private final String myUid;

    public MessageAdapter(String myUid) {
        this.myUid = myUid;
    }

    public void submit(List<ChatMessage> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    public int lastIndex() {
        return Math.max(0, items.size() - 1);
    }

    @Override
    public int getItemViewType(int position) {
        ChatMessage m = items.get(position);
        if (ChatMessage.TYPE_SYSTEM.equals(m.getType())) return TYPE_SYSTEM;
        return myUid.equals(m.getSenderId()) ? TYPE_SENT : TYPE_RECEIVED;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        if (viewType == TYPE_SENT) {
            return new SentVH(ItemMessageSentBinding.inflate(inflater, parent, false));
        }
        if (viewType == TYPE_SYSTEM) {
            return new SystemVH(ItemMessageSystemBinding.inflate(inflater, parent, false));
        }
        return new ReceivedVH(ItemMessageReceivedBinding.inflate(inflater, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        ChatMessage m = items.get(position);
        boolean showDay = needsDayHeader(position);
        String dayText = DateUtils.formatDayHeader(m.getTimestamp());

        if (holder instanceof SentVH) {
            SentVH h = (SentVH) holder;
            h.b.txtMessage.setText(m.getText());
            h.b.txtTime.setText(DateUtils.formatTime(m.getTimestamp()));
            h.b.txtDayHeader.setText(dayText);
            UiUtils.visible(h.b.txtDayHeader, showDay);
        } else if (holder instanceof ReceivedVH) {
            ReceivedVH h = (ReceivedVH) holder;
            h.b.txtMessage.setText(m.getText());
            h.b.txtTime.setText(DateUtils.formatTime(m.getTimestamp()));
            h.b.txtDayHeader.setText(dayText);
            UiUtils.visible(h.b.txtDayHeader, showDay);
            ImageLoader.avatar(h.b.imgAvatar, m.getSenderPhoto());
        } else if (holder instanceof SystemVH) {
            SystemVH h = (SystemVH) holder;
            h.b.txtMessage.setText(m.getText());
            h.b.txtDayHeader.setText(dayText);
            UiUtils.visible(h.b.txtDayHeader, showDay);
        }
    }

    private boolean needsDayHeader(int position) {
        if (position == 0) return true;
        return !DateUtils.sameDay(items.get(position).getTimestamp(),
                items.get(position - 1).getTimestamp());
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class SentVH extends RecyclerView.ViewHolder {
        final ItemMessageSentBinding b;

        SentVH(ItemMessageSentBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }

    static class ReceivedVH extends RecyclerView.ViewHolder {
        final ItemMessageReceivedBinding b;

        ReceivedVH(ItemMessageReceivedBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }

    static class SystemVH extends RecyclerView.ViewHolder {
        final ItemMessageSystemBinding b;

        SystemVH(ItemMessageSystemBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
