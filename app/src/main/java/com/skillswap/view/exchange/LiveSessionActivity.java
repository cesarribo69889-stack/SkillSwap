package com.skillswap.view.exchange;

import android.os.Bundle;
import android.os.CountDownTimer;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.skillswap.R;
import com.skillswap.databinding.ActivityLiveSessionBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Exchange;
import com.skillswap.model.LearningContract;
import com.skillswap.repository.ExchangeRepository;
import com.skillswap.repository.RepoCallback;
import com.skillswap.utils.Constants;
import com.skillswap.view.BaseActivity;
import com.skillswap.viewmodel.ContractViewModel;

import java.util.Locale;

/**
 * INNOVACION 11 - Modo sesion en vivo.
 *
 * Hasta ahora el avance se marcaba "a ojo": el estudiante pulsaba
 * "registrar sesion" cuando le parecia. Esta pantalla cronometra la sesion
 * real contra la duracion que ambos firmaron en el Contrato de Aprendizaje,
 * y solo deja registrarla cuando de verdad se trabajo.
 *
 * Regla: hay que completar al menos el 50 % del tiempo acordado. Menos que
 * eso no es una sesion, y dejar que cuente vaciaria de sentido al contrato.
 */
public class LiveSessionActivity extends BaseActivity {

    /** Porcentaje minimo del tiempo acordado para poder registrar la sesion. */
    private static final int MINIMO_PARA_REGISTRAR = 50;

    private static final long TICK = 1000L;

    private ActivityLiveSessionBinding binding;
    private ContractViewModel viewModel;

    private Exchange exchange;
    private LearningContract contract;

    private CountDownTimer timer;
    private long duracionTotalMs = 0;
    private long restanteMs = 0;
    private boolean corriendo = false;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityLiveSessionBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.live_session));

        viewModel = new ViewModelProvider(this).get(ContractViewModel.class);

        binding.btnStartPause.setOnClickListener(v -> alternar());
        binding.btnReset.setOnClickListener(v -> reiniciar());
        binding.btnFinish.setOnClickListener(v -> confirmarRegistro());

        observe();

        String exchangeId = getIntent().getStringExtra(Constants.EXTRA_EXCHANGE_ID);
        if (exchangeId != null) viewModel.load(exchangeId);
    }

    private void observe() {
        viewModel.exchange().observe(this, new Observer<Exchange>() {
            @Override
            public void onChanged(Exchange data) {
                if (data == null) return;
                exchange = data;
                pintarCabecera();
            }
        });

        viewModel.contract().observe(this, new Observer<LearningContract>() {
            @Override
            public void onChanged(LearningContract data) {
                contract = data;
                prepararCronometro();
                pintarCabecera();
            }
        });
    }

    private void pintarCabecera() {
        if (exchange == null) return;
        String uid = FirebaseManager.uid();

        binding.txtPartner.setText(getString(R.string.fmt_session_with,
                exchange.getPartnerName(uid)));

        int total = Math.max(1, exchange.getSessionsTotal());
        int siguiente = Math.min(total, exchange.getSessionsDone() + 1);
        binding.txtSkill.setText(getString(R.string.fmt_session_skill,
                exchange.getSkillILearn(uid), siguiente, total));

        if (contract != null) {
            binding.txtObjective.setText(contract.getObjective());
            binding.txtAgreedDuration.setText(getResources().getQuantityString(
                    R.plurals.plu_contract_active,
                    contract.getSessions(), contract.getSessions(),
                    contract.getSessionDuration()));
        }
    }

    /** Toma la duracion del contrato; si aun no hay contrato, no deja empezar. */
    private void prepararCronometro() {
        if (contract == null || !contract.isFullyAccepted()) {
            binding.txtTimer.setText(R.string.live_session_no_contract_timer);
            binding.txtTimerHint.setText(R.string.live_session_no_contract);
            binding.btnStartPause.setEnabled(false);
            binding.btnReset.setEnabled(false);
            binding.btnFinish.setEnabled(false);
            return;
        }

        duracionTotalMs = contract.getSessionDuration() * 60L * 1000L;
        restanteMs = duracionTotalMs;
        binding.btnStartPause.setEnabled(true);
        binding.btnReset.setEnabled(true);
        binding.progressSession.setMax(100);
        pintarTiempo();
    }

    private void alternar() {
        if (corriendo) pausar();
        else arrancar();
    }

    private void arrancar() {
        if (restanteMs <= 0) return;
        timer = new CountDownTimer(restanteMs, TICK) {
            @Override
            public void onTick(long msRestantes) {
                restanteMs = msRestantes;
                pintarTiempo();
            }

            @Override
            public void onFinish() {
                restanteMs = 0;
                corriendo = false;
                pintarTiempo();
                binding.btnStartPause.setText(R.string.live_session_start);
                info(getString(R.string.live_session_done_title),
                        getString(R.string.live_session_done_body));
            }
        }.start();

        corriendo = true;
        binding.btnStartPause.setText(R.string.live_session_pause);
    }

    private void pausar() {
        if (timer != null) timer.cancel();
        corriendo = false;
        binding.btnStartPause.setText(R.string.live_session_resume);
    }

    private void reiniciar() {
        if (timer != null) timer.cancel();
        corriendo = false;
        restanteMs = duracionTotalMs;
        binding.btnStartPause.setText(R.string.live_session_start);
        pintarTiempo();
    }

    private void pintarTiempo() {
        long totalSeg = restanteMs / 1000;
        binding.txtTimer.setText(String.format(Locale.getDefault(),
                "%02d:%02d", totalSeg / 60, totalSeg % 60));

        int avance = porcentajeTranscurrido();
        binding.progressSession.setProgress(avance);

        boolean suficiente = avance >= MINIMO_PARA_REGISTRAR;
        binding.btnFinish.setEnabled(suficiente);
        binding.txtTimerHint.setText(suficiente
                ? getString(R.string.live_session_can_register)
                : getString(R.string.fmt_session_need_more, MINIMO_PARA_REGISTRAR));
    }

    private int porcentajeTranscurrido() {
        if (duracionTotalMs <= 0) return 0;
        long transcurrido = duracionTotalMs - restanteMs;
        return (int) Math.round(transcurrido * 100.0 / duracionTotalMs);
    }

    private void confirmarRegistro() {
        if (exchange == null) return;
        final int minutos = (int) ((duracionTotalMs - restanteMs) / 60000);

        confirm(getString(R.string.live_session_register),
                getString(R.string.fmt_session_confirm, minutos),
                getString(R.string.lbl_register),
                this::registrar);
    }

    private void registrar() {
        if (timer != null) timer.cancel();
        corriendo = false;
        binding.btnFinish.setEnabled(false);

        int hechas = Math.min(exchange.getSessionsTotal(), exchange.getSessionsDone() + 1);
        ExchangeRepository.get().updateProgress(exchange, hechas, new RepoCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                info(getString(R.string.live_session_saved_title),
                        getString(R.string.live_session_saved_body));
                exchange.setSessionsDone(hechas);
                pintarCabecera();
            }

            @Override
            public void onError(String message) {
                binding.btnFinish.setEnabled(true);
                toast(binding.getRoot(), message);
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // Sin esto el temporizador sigue vivo tras cerrar la pantalla.
        if (timer != null) timer.cancel();
    }
}
