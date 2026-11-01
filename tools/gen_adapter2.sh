#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
A="$J/adapter"
mkdir -p "$A"

# ============================================================ ChatAdapter
cat > "$A/ChatAdapter.java" <<'EOF'
package com.skillswap.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

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
        String prefix = myUid.equals(c.getLastSenderId()) ? "Tú: " : "";
        holder.b.txtLastMessage.setText(prefix + c.getLastMessage());
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
EOF

# ============================================================ MessageAdapter
cat > "$A/MessageAdapter.java" <<'EOF'
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
EOF

# ============================================================ RequestAdapter
cat > "$A/RequestAdapter.java" <<'EOF'
package com.skillswap.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.databinding.ItemRequestBinding;
import com.skillswap.model.ExchangeRequest;
import com.skillswap.utils.DateUtils;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;

/** Solicitudes recibidas o enviadas. */
public class RequestAdapter extends RecyclerView.Adapter<RequestAdapter.VH> {

    public interface OnRequestAction {
        void onAccept(ExchangeRequest request);

        void onReject(ExchangeRequest request);

        void onCancel(ExchangeRequest request);

        void onOpenProfile(ExchangeRequest request);
    }

    private final List<ExchangeRequest> items = new ArrayList<>();
    private final OnRequestAction listener;
    private boolean receivedMode = true;

    public RequestAdapter(OnRequestAction listener) {
        this.listener = listener;
    }

    public void setReceivedMode(boolean received) {
        this.receivedMode = received;
    }

    public void submit(List<ExchangeRequest> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemRequestBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final ExchangeRequest r = items.get(position);
        boolean pending = ExchangeRequest.STATUS_PENDING.equals(r.getStatus());

        if (receivedMode) {
            holder.b.txtName.setText(r.getFromUserName());
            holder.b.lblOffered.setText("Te ofrece");
            holder.b.lblWanted.setText("Quiere aprender");
            holder.b.txtOffered.setText(r.getSkillOffered());
            holder.b.txtWanted.setText(r.getSkillWanted());
            ImageLoader.avatar(holder.b.imgAvatar, r.getFromUserPhoto());
        } else {
            holder.b.txtName.setText(r.getToUserName());
            holder.b.lblOffered.setText("Le ofreces");
            holder.b.lblWanted.setText("Quieres aprender");
            holder.b.txtOffered.setText(r.getSkillOffered());
            holder.b.txtWanted.setText(r.getSkillWanted());
            ImageLoader.avatar(holder.b.imgAvatar, r.getToUserPhoto());
        }

        holder.b.txtTime.setText(DateUtils.timeAgo(r.getCreatedAt()));
        UiUtils.bindStatePill(holder.b.txtStatus, r.getStatus());

        boolean hasMessage = r.getMessage() != null && !r.getMessage().trim().isEmpty();
        UiUtils.visible(holder.b.txtMessage, hasMessage);
        holder.b.txtMessage.setText(hasMessage ? "“" + r.getMessage() + "”" : "");

        holder.b.txtModality.setText(r.getModality());
        holder.b.txtSchedule.setText(r.getSchedule());

        UiUtils.visible(holder.b.actionsReceived, receivedMode && pending);
        UiUtils.visible(holder.b.btnCancel, !receivedMode && pending);

        holder.b.btnAccept.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onAccept(r);
            }
        });
        holder.b.btnReject.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onReject(r);
            }
        });
        holder.b.btnCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onCancel(r);
            }
        });
        holder.b.getRoot().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onOpenProfile(r);
            }
        });
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemRequestBinding b;

        VH(ItemRequestBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
EOF

# ============================================================ UserSkillAdapter
cat > "$A/UserSkillAdapter.java" <<'EOF'
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
EOF

# ============================================================ SkillCatalogAdapter
cat > "$A/SkillCatalogAdapter.java" <<'EOF'
package com.skillswap.adapter;

import android.content.res.ColorStateList;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.databinding.ItemSkillCatalogBinding;
import com.skillswap.model.Skill;
import com.skillswap.utils.SkillCatalog;

import java.util.ArrayList;
import java.util.List;

/** Catalogo global de habilidades. */
public class SkillCatalogAdapter extends RecyclerView.Adapter<SkillCatalogAdapter.VH> {

    public interface OnSkillSelected {
        void onSelected(Skill skill);
    }

    private final List<Skill> items = new ArrayList<>();
    private final OnSkillSelected listener;

    public SkillCatalogAdapter(OnSkillSelected listener) {
        this.listener = listener;
    }

    public void submit(List<Skill> data) {
        items.clear();
        if (data != null) items.addAll(data);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemSkillCatalogBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final Skill s = items.get(position);
        int color = ContextCompat.getColor(holder.itemView.getContext(),
                SkillCatalog.colorForCategory(s.getCategory()));

        holder.b.txtName.setText(s.getName());
        holder.b.txtCategory.setText(s.getCategory());
        holder.b.imgIcon.setImageResource(SkillCatalog.iconForCategory(s.getCategory()));
        holder.b.imgIcon.setImageTintList(ColorStateList.valueOf(color));
        holder.b.iconWrap.setBackgroundTintList(ColorStateList.valueOf(withAlpha(color, 30)));

        holder.b.getRoot().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onSelected(s);
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
        final ItemSkillCatalogBinding b;

        VH(ItemSkillCatalogBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
EOF

echo "Adapters 2 generados."
