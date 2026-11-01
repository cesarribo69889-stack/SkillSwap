package com.skillswap.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.R;
import com.skillswap.databinding.ItemExchangeBinding;
import com.skillswap.model.Exchange;
import com.skillswap.utils.DateUtils;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;

/** Lista de intercambios del usuario. */
public class ExchangeAdapter extends RecyclerView.Adapter<ExchangeAdapter.VH> {

    public interface OnExchangeAction {
        void onOpenChat(Exchange exchange);

        void onOpenDetail(Exchange exchange);
    }

    private final List<Exchange> items = new ArrayList<>();
    private final String myUid;
    private final OnExchangeAction listener;

    public ExchangeAdapter(String myUid, OnExchangeAction listener) {
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
        return new VH(ItemExchangeBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        final Exchange e = items.get(position);

        holder.b.txtName.setText(e.getPartnerName(myUid));
        holder.b.txtModality.setText(e.getModality());
        holder.b.txtITeach.setText(e.getSkillITeach(myUid));
        holder.b.txtILearn.setText(e.getSkillILearn(myUid));
        holder.b.txtDate.setText(DateUtils.formatDate(e.getStartDate()));

        UiUtils.bindStatePill(holder.b.txtStatus, e.getStatus());

        holder.b.progressBar.setProgress(e.getProgress());
        if (e.getSessionsTotal() > 0) {
            holder.b.txtProgress.setText(holder.itemView.getContext().getString(
                    R.string.fmt_session_of, e.getSessionsDone(), e.getSessionsTotal()));
        } else {
            holder.b.txtProgress.setText(holder.itemView.getContext().getString(
                    R.string.fmt_percent_completed, e.getProgress()));
        }

        ImageLoader.avatar(holder.b.imgAvatar, e.getPartnerPhoto(myUid));

        holder.b.btnChat.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onOpenChat(e);
            }
        });
        View.OnClickListener detail = new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) listener.onOpenDetail(e);
            }
        };
        holder.b.btnDetail.setOnClickListener(detail);
        holder.b.getRoot().setOnClickListener(detail);
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemExchangeBinding b;

        VH(ItemExchangeBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
