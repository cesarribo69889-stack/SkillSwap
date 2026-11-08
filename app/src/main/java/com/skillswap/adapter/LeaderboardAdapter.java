package com.skillswap.adapter;

import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.R;
import com.skillswap.databinding.ItemLeaderboardBinding;
import com.skillswap.model.User;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.LeaderboardEngine;

import java.util.ArrayList;
import java.util.List;

/** INNOVACION 10 - Filas de la tabla de lideres. */
public class LeaderboardAdapter extends RecyclerView.Adapter<LeaderboardAdapter.VH> {

    public interface OnUserClick {
        void onClick(User user);
    }

    private final List<LeaderboardEngine.Puesto> items = new ArrayList<>();
    private final OnUserClick listener;

    public LeaderboardAdapter(OnUserClick listener) {
        this.listener = listener;
    }

    public void submit(List<LeaderboardEngine.Puesto> nuevos) {
        items.clear();
        if (nuevos != null) items.addAll(nuevos);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemLeaderboardBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        holder.bind(items.get(position));
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    class VH extends RecyclerView.ViewHolder {

        private final ItemLeaderboardBinding b;

        VH(ItemLeaderboardBinding binding) {
            super(binding.getRoot());
            this.b = binding;
        }

        void bind(final LeaderboardEngine.Puesto puesto) {
            User u = puesto.getUsuario();

            b.txtPosition.setText(puesto.getMedalla());
            b.txtName.setText(u.getFullName());
            b.txtCareer.setText(u.getCareer());
            b.txtPoints.setText(String.valueOf(u.getSkillPoints()));
            b.txtExchanges.setText(b.getRoot().getContext().getResources()
                    .getQuantityString(R.plurals.plu_exchanges,
                            u.getExchangesCount(), u.getExchangesCount()));
            ImageLoader.avatar(b.imgAvatar, u.getPhotoUrl());

            // La fila del propio usuario se resalta para encontrarla de un vistazo.
            b.cardRow.setStrokeWidth(puesto.esElUsuarioActual() ? 2 : 1);
            b.cardRow.setStrokeColor(ContextCompat.getColor(
                    b.getRoot().getContext(),
                    puesto.esElUsuarioActual()
                            ? R.color.brand_primary : R.color.divider));

            b.getRoot().setOnClickListener(v -> {
                if (listener != null) listener.onClick(u);
            });
        }
    }
}
