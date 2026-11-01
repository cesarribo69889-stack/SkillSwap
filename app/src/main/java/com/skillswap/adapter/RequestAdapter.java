package com.skillswap.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.R;
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
            holder.b.lblOffered.setText(R.string.st_they_offer);
            holder.b.lblWanted.setText(R.string.st_they_want);
            holder.b.txtOffered.setText(r.getSkillOffered());
            holder.b.txtWanted.setText(r.getSkillWanted());
            ImageLoader.avatar(holder.b.imgAvatar, r.getFromUserPhoto());
        } else {
            holder.b.txtName.setText(r.getToUserName());
            holder.b.lblOffered.setText(R.string.st_you_offer);
            holder.b.lblWanted.setText(R.string.st_you_want);
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
