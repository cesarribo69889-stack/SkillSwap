package com.skillswap.view.contracts;

import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.skillswap.R;
import com.skillswap.databinding.ActivityContractBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Exchange;
import com.skillswap.model.LearningContract;
import com.skillswap.model.Resource;
import com.skillswap.utils.Constants;
import com.skillswap.utils.UiUtils;
import com.skillswap.utils.Validators;
import com.skillswap.view.BaseActivity;
import com.skillswap.viewmodel.ContractViewModel;

/**
 * INNOVACION 3 - Contrato de aprendizaje.
 * Ambos estudiantes deben aceptar el acuerdo antes de iniciar.
 */
public class ContractActivity extends BaseActivity {

    private ActivityContractBinding binding;
    private ContractViewModel viewModel;
    private Exchange exchange;
    private LearningContract contract;
    private final String myUid = FirebaseManager.uid();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityContractBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        String exchangeId = getIntent().getStringExtra(Constants.EXTRA_EXCHANGE_ID);
        viewModel = new ViewModelProvider(this).get(ContractViewModel.class);

        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.learning_contract));

        binding.btnSave.setOnClickListener(v -> save());
        binding.btnAccept.setOnClickListener(v -> accept());

        observe();
        if (exchangeId != null) viewModel.load(exchangeId);
    }

    private void observe() {
        viewModel.exchange().observe(this, new Observer<Exchange>() {
            @Override
            public void onChanged(Exchange data) {
                if (data == null) return;
                exchange = data;
                if (contract == null) prefill(data);
            }
        });

        viewModel.contract().observe(this, new Observer<LearningContract>() {
            @Override
            public void onChanged(LearningContract data) {
                contract = data;
                if (data != null) render(data);
                renderAcceptance();
            }
        });

        viewModel.saveState().observe(this, new Observer<Resource<LearningContract>>() {
            @Override
            public void onChanged(Resource<LearningContract> state) {
                if (state == null) return;
                binding.btnSave.setEnabled(!state.isLoading());
                if (state.isSuccess()) {
                    toast(binding.getRoot(), "Acuerdo guardado. Falta que lo acepten ambos.");
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });

        viewModel.acceptState().observe(this, new Observer<Resource<LearningContract>>() {
            @Override
            public void onChanged(Resource<LearningContract> state) {
                if (state == null) return;
                binding.btnAccept.setEnabled(!state.isLoading());
                if (state.isSuccess() && state.getData() != null) {
                    if (state.getData().isFullyAccepted()) {
                        info("¡Acuerdo activo!",
                                "Ambos aceptaron el contrato. El intercambio pasó a "
                                        + "EN PROCESO y ya pueden empezar las sesiones.");
                    } else {
                        toast(binding.getRoot(),
                                "Aceptaste el acuerdo. Falta tu compañero.");
                    }
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });
    }

    /** Valores sugeridos cuando todavía no existe contrato. */
    private void prefill(Exchange ex) {
        if (binding.tilObjective.getEditText() != null) {
            binding.tilObjective.getEditText().setText(getString(
                    R.string.fmt_challenge_objective,
                    ex.getSkillILearn(myUid), ex.getSkillITeach(myUid)));
        }
        boolean presencial = Constants.MODALITY_PRESENCIAL.equals(ex.getModality());
        binding.chipPresencial.setChecked(presencial);
        binding.chipVirtual.setChecked(!presencial);
    }

    private void render(LearningContract c) {
        if (binding.tilObjective.getEditText() != null) {
            binding.tilObjective.getEditText().setText(c.getObjective());
        }
        if (binding.tilSessions.getEditText() != null) {
            binding.tilSessions.getEditText().setText(String.valueOf(c.getSessions()));
        }
        if (binding.tilDuration.getEditText() != null) {
            binding.tilDuration.getEditText().setText(String.valueOf(c.getSessionDuration()));
        }
        if (binding.tilGoal.getEditText() != null) {
            binding.tilGoal.getEditText().setText(c.getGoal());
        }
        if (binding.tilActivity.getEditText() != null) {
            binding.tilActivity.getEditText().setText(c.getFinalActivity());
        }
        binding.chipPresencial.setChecked(Constants.MODALITY_PRESENCIAL.equals(c.getModality()));
        binding.chipVirtual.setChecked(!Constants.MODALITY_PRESENCIAL.equals(c.getModality()));

        binding.txtContractStatus.setText(c.isFullyAccepted()
                ? "Acuerdo activo entre ambos estudiantes"
                : "Pendiente de aceptación");
    }

    private void renderAcceptance() {
        String nameA = exchange == null ? "Estudiante A" : exchange.getUserAName();
        String nameB = exchange == null ? "Estudiante B" : exchange.getUserBName();

        boolean acceptedA = contract != null && contract.isAcceptedByA();
        boolean acceptedB = contract != null && contract.isAcceptedByB();

        bindAcceptanceRow(binding.txtAcceptA, nameA, acceptedA);
        bindAcceptanceRow(binding.txtAcceptB, nameB, acceptedB);

        boolean alreadyAccepted = contract != null && contract.hasAccepted(myUid);
        binding.btnAccept.setEnabled(contract != null && !alreadyAccepted);
        binding.btnAccept.setText(alreadyAccepted ? "Ya aceptaste" : "Aceptar acuerdo");
        binding.btnSave.setEnabled(contract == null || !contract.isFullyAccepted());
    }

    private void bindAcceptanceRow(android.widget.TextView view, String name, boolean accepted) {
        view.setText(getString(accepted
                ? R.string.st_accepted_suffix : R.string.st_pending_suffix, name));
        view.setCompoundDrawablesRelativeWithIntrinsicBounds(
                accepted ? R.drawable.ic_check_circle : R.drawable.ic_clock, 0, 0, 0);
        view.setCompoundDrawableTintList(android.content.res.ColorStateList.valueOf(
                ContextCompat.getColor(this,
                        accepted ? R.color.state_accepted : R.color.state_pending)));
    }

    private void save() {
        UiUtils.hideKeyboard(binding.getRoot());
        if (exchange == null) {
            toast(binding.getRoot(), "El intercambio aún se está cargando");
            return;
        }

        String objective = Validators.text(binding.tilObjective).trim();
        String sessions = Validators.text(binding.tilSessions).trim();
        String duration = Validators.text(binding.tilDuration).trim();

        boolean ok = Validators.apply(binding.tilObjective,
                Validators.validateMinLength(objective, 10, "El objetivo"));
        ok &= Validators.apply(binding.tilSessions,
                Validators.validateIntRange(sessions, 1, 20, "Las sesiones"));
        ok &= Validators.apply(binding.tilDuration,
                Validators.validateIntRange(duration, 15, 240, "La duración"));
        if (!ok) return;

        LearningContract draft = new LearningContract();
        draft.setObjective(objective);
        draft.setSessions(Integer.parseInt(sessions));
        draft.setSessionDuration(Integer.parseInt(duration));
        draft.setModality(binding.chipPresencial.isChecked()
                ? Constants.MODALITY_PRESENCIAL : Constants.MODALITY_VIRTUAL);
        draft.setGoal(Validators.text(binding.tilGoal).trim());
        draft.setFinalActivity(Validators.text(binding.tilActivity).trim());
        if (contract != null) draft.setCreatedAt(contract.getCreatedAt());

        viewModel.save(draft);
    }

    private void accept() {
        if (contract == null) {
            toast(binding.getRoot(), "Primero guarda el acuerdo");
            return;
        }
        confirm("Aceptar acuerdo",
                "Te comprometes a cumplir el objetivo, las sesiones y la actividad final "
                        + "definidas en este contrato.",
                "Aceptar",
                () -> viewModel.accept());
    }
}
