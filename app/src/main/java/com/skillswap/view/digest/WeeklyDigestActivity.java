package com.skillswap.view.digest;

import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import com.skillswap.R;
import com.skillswap.databinding.ActivityWeeklyDigestBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Exchange;
import com.skillswap.model.PointEntry;
import com.skillswap.repository.ExchangeRepository;
import com.skillswap.repository.GamificationRepository;
import com.skillswap.repository.RepoCallback;
import com.skillswap.view.BaseActivity;
import com.skillswap.utils.WeeklyDigestEngine;

import com.google.firebase.firestore.ListenerRegistration;

import java.util.ArrayList;
import java.util.List;

/**
 * INNOVACION 12 - Resumen semanal de progreso.
 *
 * Los SkillPoints sueltos no dicen gran cosa. Esta pantalla los pone en
 * contexto: cuanto ganaste esta semana, como te fue frente a la anterior,
 * en que dias trabajaste y que convendria hacer ahora.
 *
 * No guarda nada nuevo: todo se calcula al vuelo desde el historial de
 * puntos y los intercambios que ya existen.
 */
public class WeeklyDigestActivity extends BaseActivity {

    private ActivityWeeklyDigestBinding binding;
    private ListenerRegistration exchangesReg;

    private final List<PointEntry> historial = new ArrayList<>();
    private final List<Exchange> intercambios = new ArrayList<>();

    private boolean historialListo = false;
    private boolean intercambiosListos = false;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityWeeklyDigestBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.weekly_digest));

        etiquetarCifras();
        prepararGrafico();

        String uid = FirebaseManager.uid();
        if (uid == null) return;

        GamificationRepository.get().fetchHistory(uid, new RepoCallback<List<PointEntry>>() {
            @Override
            public void onSuccess(List<PointEntry> data) {
                historial.clear();
                if (data != null) historial.addAll(data);
                historialListo = true;
                pintar();
            }

            @Override
            public void onError(String message) {
                historialListo = true;
                pintar();
            }
        });

        exchangesReg = ExchangeRepository.get().listenByUser(uid,
                new RepoCallback<List<Exchange>>() {
                    @Override
                    public void onSuccess(List<Exchange> data) {
                        intercambios.clear();
                        if (data != null) intercambios.addAll(data);
                        intercambiosListos = true;
                        pintar();
                    }

                    @Override
                    public void onError(String message) {
                        intercambiosListos = true;
                        pintar();
                    }
                });
    }

    private void etiquetarCifras() {
        binding.statPoints.txtStatLabel.setText(R.string.weekly_points);
        binding.statSessions.txtStatLabel.setText(R.string.weekly_sessions);
        binding.statClosed.txtStatLabel.setText(R.string.weekly_closed);
        binding.statDays.txtStatLabel.setText(R.string.weekly_active_days);
    }

    /** Los colores se pasan desde aqui para que el grafico siga el tema. */
    private void prepararGrafico() {
        binding.chart.setColores(
                ContextCompat.getColor(this, R.color.brand_primary),
                ContextCompat.getColor(this, R.color.brand_primary_container),
                ContextCompat.getColor(this, R.color.text_secondary));
    }

    /** Se pinta cuando han llegado las dos fuentes, para no parpadear. */
    private void pintar() {
        if (!historialListo || !intercambiosListos) return;

        long ahora = System.currentTimeMillis();
        WeeklyDigestEngine.Resumen r =
                WeeklyDigestEngine.calcular(historial, intercambios, ahora);

        binding.txtHeadline.setText(r.titular());
        binding.txtAdvice.setText(r.consejo());

        binding.statPoints.txtStatValue.setText(String.valueOf(r.getPuntosGanados()));
        binding.statSessions.txtStatValue.setText(String.valueOf(r.getSesionesRegistradas()));
        binding.statClosed.txtStatValue.setText(String.valueOf(r.getIntercambiosCerrados()));
        binding.statDays.txtStatValue.setText(String.valueOf(r.getDiasActivos()));

        binding.chart.setDatos(r.getPuntosPorDia(),
                WeeklyDigestEngine.etiquetasDias(ahora));
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (exchangesReg != null) exchangesReg.remove();
    }
}
