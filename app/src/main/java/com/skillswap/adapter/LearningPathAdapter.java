package com.skillswap.adapter;

import android.content.Context;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.skillswap.R;
import com.skillswap.databinding.ItemLearningPathBinding;
import com.skillswap.utils.LearningPathEngine;
import com.skillswap.utils.UiUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * INNOVACION 9 - Tarjetas de ruta de aprendizaje.
 *
 * Los pasos se dibujan por codigo dentro de la tarjeta en vez de usar un
 * RecyclerView anidado: son pocos (3 a 5) y asi se evita el coste y los
 * problemas de reciclado de una lista dentro de otra.
 */
public class LearningPathAdapter extends RecyclerView.Adapter<LearningPathAdapter.VH> {

    public interface OnSkillClick {
        void onClick(String habilidad);
    }

    private final List<LearningPathEngine.Ruta> items = new ArrayList<>();
    private final OnSkillClick listener;

    public LearningPathAdapter(OnSkillClick listener) {
        this.listener = listener;
    }

    public void submit(List<LearningPathEngine.Ruta> nuevos) {
        items.clear();
        if (nuevos != null) items.addAll(nuevos);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new VH(ItemLearningPathBinding.inflate(
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

        private final ItemLearningPathBinding b;

        VH(ItemLearningPathBinding binding) {
            super(binding.getRoot());
            this.b = binding;
        }

        void bind(LearningPathEngine.Ruta ruta) {
            Context ctx = b.getRoot().getContext();

            b.txtPathName.setText(ruta.getNombre());
            b.txtPathDescription.setText(ruta.getDescripcion());
            b.txtPathProgress.setText(ctx.getString(R.string.fmt_path_progress,
                    ruta.getCompletados(), ruta.getPasos().size()));
            b.progressPath.setMax(100);
            b.progressPath.setProgress(ruta.getProgreso());

            b.containerSteps.removeAllViews();
            for (LearningPathEngine.Paso paso : ruta.getPasos()) {
                b.containerSteps.addView(crearPaso(ctx, paso));
            }
        }

        /** Una linea por paso: marca de estado + habilidad + por que va ahi. */
        private LinearLayout crearPaso(Context ctx, final LearningPathEngine.Paso paso) {
            LinearLayout fila = new LinearLayout(ctx);
            fila.setOrientation(LinearLayout.HORIZONTAL);
            fila.setGravity(Gravity.CENTER_VERTICAL);
            fila.setPadding(0, UiUtils.dp(ctx, 6), 0, UiUtils.dp(ctx, 6));

            TextView marca = new TextView(ctx);
            marca.setText(paso.estaCompletado() ? "✓" : (paso.estaEnCurso() ? "→" : "·"));
            marca.setTextSize(16);
            marca.setWidth(UiUtils.dp(ctx, 26));
            marca.setTextColor(ContextCompat.getColor(ctx,
                    paso.estaCompletado() ? R.color.state_accepted
                            : paso.estaEnCurso() ? R.color.brand_primary
                            : R.color.text_tertiary));
            fila.addView(marca);

            LinearLayout textos = new LinearLayout(ctx);
            textos.setOrientation(LinearLayout.VERTICAL);
            textos.setLayoutParams(new LinearLayout.LayoutParams(
                    0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));

            TextView titulo = new TextView(ctx);
            titulo.setText(paso.getHabilidad());
            titulo.setTextAppearance(R.style.TextAppearance_SkillSwap_Body);
            if (paso.estaEnCurso()) {
                titulo.setTypeface(titulo.getTypeface(), android.graphics.Typeface.BOLD);
            }
            textos.addView(titulo);

            TextView porQue = new TextView(ctx);
            porQue.setText(paso.getPorQue());
            porQue.setTextAppearance(R.style.TextAppearance_SkillSwap_Caption);
            textos.addView(porQue);

            fila.addView(textos);

            // El paso que toca ahora lleva a buscar a alguien que lo enseñe.
            if (paso.estaEnCurso() && listener != null) {
                fila.setOnClickListener(v -> listener.onClick(paso.getHabilidad()));
            }
            return fila;
        }
    }
}
