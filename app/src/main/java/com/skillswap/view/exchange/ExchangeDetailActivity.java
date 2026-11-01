package com.skillswap.view.exchange;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.skillswap.R;
import com.skillswap.databinding.ActivityExchangeDetailBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Exchange;
import com.skillswap.model.LearningContract;
import com.skillswap.model.Resource;
import com.skillswap.utils.Constants;
import com.skillswap.utils.DateUtils;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;
import com.skillswap.view.BaseActivity;
import com.skillswap.view.chat.ChatActivity;
import com.skillswap.view.contracts.ContractActivity;
import com.skillswap.view.ratings.RateExchangeActivity;
import com.skillswap.viewmodel.ExchangeViewModel;

/** Detalle de un intercambio: progreso, contrato, evidencia y cierre. */
public class ExchangeDetailActivity extends BaseActivity {

    private ActivityExchangeDetailBinding binding;
    private ExchangeViewModel viewModel;
    private Exchange exchange;
    private LearningContract contract;
    private String exchangeId;
    private final String myUid = FirebaseManager.uid();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityExchangeDetailBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        exchangeId = getIntent().getStringExtra(Constants.EXTRA_EXCHANGE_ID);
        viewModel = new ViewModelProvider(this).get(ExchangeViewModel.class);

        setupToolbar(binding.toolbarInc.toolbar, "Detalle del intercambio");
        setupListeners();
        observe();

        if (exchangeId != null) viewModel.observeDetail(exchangeId);
    }

    private void setupListeners() {
        binding.btnChat.setOnClickListener(v -> {
            if (exchange == null) return;
            Intent intent = new Intent(this, ChatActivity.class);
            intent.putExtra(Constants.EXTRA_CHAT_ID,
                    exchange.getChatId().isEmpty() ? exchange.getId() : exchange.getChatId());
            startActivity(intent);
        });

        binding.cardContract.setOnClickListener(v -> {
            if (exchange == null) return;
            Intent intent = new Intent(this, ContractActivity.class);
            intent.putExtra(Constants.EXTRA_EXCHANGE_ID, exchange.getId());
            startActivity(intent);
        });

        binding.cardEvidence.setOnClickListener(v -> {
            if (exchange == null) return;
            Intent intent = new Intent(this, EvidenceActivity.class);
            intent.putExtra(Constants.EXTRA_EXCHANGE_ID, exchange.getId());
            startActivity(intent);
        });

        binding.btnSession.setOnClickListener(v -> {
            if (exchange == null) return;
            if (exchange.getSessionsTotal() <= 0) {
                info("Define el contrato primero",
                        "Acuerden cuántas sesiones tendrá el intercambio en el "
                                + "Contrato de aprendizaje para poder registrar el avance.");
                return;
            }
            if (exchange.getSessionsDone() >= exchange.getSessionsTotal()) {
                toast(binding.getRoot(), "Ya registraron todas las sesiones acordadas");
                return;
            }
            viewModel.updateProgress(exchange, exchange.getSessionsDone() + 1);
        });

        binding.btnPrimary.setOnClickListener(v -> onPrimaryAction());
    }

    private void onPrimaryAction() {
        if (exchange == null) return;

        if (Exchange.STATUS_COMPLETED.equals(exchange.getStatus())) {
            if (exchange.hasRated(myUid)) {
                toast(binding.getRoot(), "Ya calificaste este intercambio");
                return;
            }
            Intent intent = new Intent(this, RateExchangeActivity.class);
            intent.putExtra(Constants.EXTRA_EXCHANGE_ID, exchange.getId());
            startActivity(intent);
            return;
        }

        if (exchange.hasCompleted(myUid)) {
            info("Esperando confirmación",
                    "Ya marcaste el intercambio como terminado. Se cerrará cuando "
                            + exchange.getPartnerName(myUid) + " también lo confirme.");
            return;
        }

        confirm("Marcar como completado",
                "Confirmarás que el intercambio de " + exchange.getSkillITeach(myUid)
                        + " ⇄ " + exchange.getSkillILearn(myUid) + " ya terminó.",
                "Completar",
                () -> viewModel.markCompleted(exchange));
    }

    private void observe() {
        viewModel.detail().observe(this, new Observer<Exchange>() {
            @Override
            public void onChanged(Exchange data) {
                if (data == null) return;
                exchange = data;
                render();
            }
        });

        viewModel.contract().observe(this, new Observer<LearningContract>() {
            @Override
            public void onChanged(LearningContract data) {
                contract = data;
                renderContract();
            }
        });

        viewModel.completeState().observe(this, new Observer<Resource<Exchange>>() {
            @Override
            public void onChanged(Resource<Exchange> state) {
                if (state == null) return;
                binding.btnPrimary.setEnabled(!state.isLoading());
                if (state.isSuccess() && state.getData() != null) {
                    if (Exchange.STATUS_COMPLETED.equals(state.getData().getStatus())) {
                        info("¡Intercambio completado! 🎉",
                                "Ganaste " + Constants.POINTS_EXCHANGE_COMPLETED
                                        + " SkillPoints y tu pasaporte se actualizó. "
                                        + "Ahora puedes calificar la experiencia.");
                    } else {
                        toast(binding.getRoot(),
                                "Listo. Falta la confirmación de tu compañero.");
                    }
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });

        viewModel.actionState().observe(this, new Observer<Resource<Boolean>>() {
            @Override
            public void onChanged(Resource<Boolean> state) {
                if (state == null) return;
                if (state.isError()) toast(binding.getRoot(), state.getMessage());
            }
        });
    }

    private void render() {
        binding.txtName.setText(exchange.getPartnerName(myUid));
        binding.txtStatus.setText(UiUtils.stateLabel(exchange.getStatus()));
        binding.txtITeach.setText(exchange.getSkillITeach(myUid));
        binding.txtILearn.setText(exchange.getSkillILearn(myUid));
        binding.txtModality.setText(getString(R.string.fmt_modality, exchange.getModality()));
        binding.txtSchedule.setText(exchange.getSchedule().isEmpty()
                ? getString(R.string.st_schedule_pending) : exchange.getSchedule());
        binding.txtDate.setText(getString(R.string.fmt_start_date,
                DateUtils.formatDate(exchange.getStartDate())));

        binding.progressBar.setProgress(exchange.getProgress());
        binding.txtProgressValue.setText(getString(R.string.fmt_percent, exchange.getProgress()));
        binding.txtSessions.setText(exchange.getSessionsTotal() > 0
                ? getString(R.string.fmt_session_of,
                        exchange.getSessionsDone(), exchange.getSessionsTotal())
                : getString(R.string.st_sessions_pending));

        ImageLoader.avatar(binding.imgAvatar, exchange.getPartnerPhoto(myUid));

        boolean completed = Exchange.STATUS_COMPLETED.equals(exchange.getStatus());
        UiUtils.visible(binding.btnSession, !completed);

        if (completed) {
            binding.btnPrimary.setText(exchange.hasRated(myUid)
                    ? "Ya calificado" : getString(R.string.rate_exchange));
            binding.btnPrimary.setEnabled(!exchange.hasRated(myUid));
        } else if (exchange.hasCompleted(myUid)) {
            binding.btnPrimary.setText(R.string.st_waiting_confirmation);
        } else {
            binding.btnPrimary.setText(R.string.mark_completed);
            binding.btnPrimary.setEnabled(true);
        }
    }

    private void renderContract() {
        if (contract == null) {
            binding.txtContractStatus.setText(R.string.st_contract_none);
            return;
        }
        if (contract.isFullyAccepted()) {
            binding.txtContractStatus.setText(getResources().getQuantityString(
                    R.plurals.plu_contract_active, contract.getSessions(),
                    contract.getSessions(), contract.getSessionDuration()));
        } else if (contract.hasAccepted(myUid)) {
            binding.txtContractStatus.setText(R.string.st_contract_waiting_partner);
        } else {
            binding.txtContractStatus.setText(R.string.st_contract_waiting_you);
        }
    }
}
