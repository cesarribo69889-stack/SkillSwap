#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
mkdir -p "$J/view/ratings" "$J/view/notifications" "$J/view/contracts"

# ============================================================ RateExchangeActivity
cat > "$J/view/ratings/RateExchangeActivity.java" <<'EOF'
package com.skillswap.view.ratings;

import android.os.Bundle;
import android.widget.RatingBar;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.skillswap.R;
import com.skillswap.databinding.ActivityRateExchangeBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Exchange;
import com.skillswap.model.Rating;
import com.skillswap.model.Resource;
import com.skillswap.utils.Constants;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;
import com.skillswap.utils.Validators;
import com.skillswap.view.BaseActivity;
import com.skillswap.viewmodel.ExchangeViewModel;
import com.skillswap.viewmodel.RatingViewModel;

/** Calificacion de un intercambio completado. */
public class RateExchangeActivity extends BaseActivity {

    private ActivityRateExchangeBinding binding;
    private RatingViewModel ratingViewModel;
    private ExchangeViewModel exchangeViewModel;
    private Exchange exchange;
    private final String myUid = FirebaseManager.uid();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityRateExchangeBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        String exchangeId = getIntent().getStringExtra(Constants.EXTRA_EXCHANGE_ID);
        ratingViewModel = new ViewModelProvider(this).get(RatingViewModel.class);
        exchangeViewModel = new ViewModelProvider(this).get(ExchangeViewModel.class);

        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.rate_exchange));

        binding.rowPunctuality.txtCriteria.setText(R.string.rate_punctuality);
        binding.rowCommunication.txtCriteria.setText(R.string.rate_communication);
        binding.rowTeaching.txtCriteria.setText(R.string.rate_teaching);

        binding.ratingGeneral.setOnRatingBarChangeListener(
                new RatingBar.OnRatingBarChangeListener() {
                    @Override
                    public void onRatingChanged(RatingBar bar, float rating, boolean fromUser) {
                        binding.txtRatingLabel.setText(labelFor(rating));
                    }
                });

        binding.btnSubmit.setOnClickListener(v -> submit());

        exchangeViewModel.detail().observe(this, new Observer<Exchange>() {
            @Override
            public void onChanged(Exchange data) {
                if (data == null) return;
                exchange = data;
                render();
            }
        });

        ratingViewModel.submitState().observe(this, new Observer<Resource<Rating>>() {
            @Override
            public void onChanged(Resource<Rating> state) {
                if (state == null) return;
                binding.btnSubmit.setEnabled(!state.isLoading());
                if (state.isSuccess()) {
                    info("¡Gracias por calificar!",
                            "Tu opinión actualiza la reputación de tu compañero "
                                    + "y su Pasaporte de Habilidades.");
                    binding.btnSubmit.postDelayed(RateExchangeActivity.this::finish, 1100);
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });

        if (exchangeId != null) exchangeViewModel.observeDetail(exchangeId);
    }

    private void render() {
        binding.txtName.setText(exchange.getPartnerName(myUid));
        binding.txtSkill.setText("Te enseñó " + exchange.getSkillILearn(myUid));
        ImageLoader.avatar(binding.imgAvatar, exchange.getPartnerPhoto(myUid));

        if (exchange.hasRated(myUid)) {
            binding.btnSubmit.setEnabled(false);
            binding.btnSubmit.setText("Ya calificaste este intercambio");
        }
    }

    private String labelFor(float rating) {
        int stars = Math.round(rating);
        switch (stars) {
            case 1: return "Muy mala experiencia";
            case 2: return "Podría mejorar";
            case 3: return "Aceptable";
            case 4: return "Muy buena";
            case 5: return "¡Excelente!";
            default: return "Toca las estrellas para calificar";
        }
    }

    private void submit() {
        UiUtils.hideKeyboard(binding.getRoot());
        if (exchange == null) {
            toast(binding.getRoot(), "El intercambio aún se está cargando");
            return;
        }
        if (binding.ratingGeneral.getRating() <= 0) {
            toast(binding.getRoot(), "Selecciona al menos una estrella");
            return;
        }

        Rating rating = new Rating();
        rating.setStars(binding.ratingGeneral.getRating());
        rating.setPunctuality(binding.rowPunctuality.ratingCriteria.getRating());
        rating.setCommunication(binding.rowCommunication.ratingCriteria.getRating());
        rating.setTeaching(binding.rowTeaching.ratingCriteria.getRating());
        rating.setComment(Validators.text(binding.tilComment).trim());

        // Si no calificó los criterios, se usa la puntuación general.
        if (rating.getPunctuality() <= 0) rating.setPunctuality(rating.getStars());
        if (rating.getCommunication() <= 0) rating.setCommunication(rating.getStars());
        if (rating.getTeaching() <= 0) rating.setTeaching(rating.getStars());

        ratingViewModel.submit(exchange, rating);
    }
}
EOF

# ============================================================ HistoryActivity
cat > "$J/view/ratings/HistoryActivity.java" <<'EOF'
package com.skillswap.view.ratings;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.skillswap.R;
import com.skillswap.adapter.HistoryAdapter;
import com.skillswap.databinding.ActivityHistoryBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Exchange;
import com.skillswap.utils.Constants;
import com.skillswap.utils.UiUtils;
import com.skillswap.view.BaseActivity;
import com.skillswap.view.exchange.ExchangeDetailActivity;
import com.skillswap.viewmodel.ExchangeViewModel;

import java.util.List;

/** Historial de intercambios completados. */
public class HistoryActivity extends BaseActivity {

    private ActivityHistoryBinding binding;
    private ExchangeViewModel viewModel;
    private HistoryAdapter adapter;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityHistoryBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        viewModel = new ViewModelProvider(this).get(ExchangeViewModel.class);
        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.history));

        adapter = new HistoryAdapter(FirebaseManager.uid(), new HistoryAdapter.OnHistoryAction() {
            @Override
            public void onRate(Exchange exchange) {
                Intent intent = new Intent(HistoryActivity.this, RateExchangeActivity.class);
                intent.putExtra(Constants.EXTRA_EXCHANGE_ID, exchange.getId());
                startActivity(intent);
            }

            @Override
            public void onOpen(Exchange exchange) {
                Intent intent = new Intent(HistoryActivity.this, ExchangeDetailActivity.class);
                intent.putExtra(Constants.EXTRA_EXCHANGE_ID, exchange.getId());
                startActivity(intent);
            }
        });
        binding.rvHistory.setLayoutManager(new LinearLayoutManager(this));
        binding.rvHistory.setAdapter(adapter);

        viewModel.all().observe(this, new Observer<List<Exchange>>() {
            @Override
            public void onChanged(List<Exchange> exchanges) {
                List<Exchange> completed = viewModel.filterByStatus(Exchange.STATUS_COMPLETED);
                adapter.submit(completed);

                boolean empty = completed.isEmpty();
                UiUtils.visible(binding.empty.getRoot(), empty);
                UiUtils.visible(binding.rvHistory, !empty);
                binding.empty.imgEmpty.setImageResource(R.drawable.ic_history);
                binding.empty.txtEmptyTitle.setText("Historial vacío");
                binding.empty.txtEmptyDesc.setText(
                        "Aquí aparecerán los intercambios que completes, "
                                + "con lo que enseñaste y lo que aprendiste.");
            }
        });

        viewModel.start();
    }
}
EOF

# ============================================================ NotificationsActivity
cat > "$J/view/notifications/NotificationsActivity.java" <<'EOF'
package com.skillswap.view.notifications;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.skillswap.R;
import com.skillswap.adapter.NotificationAdapter;
import com.skillswap.databinding.ActivityNotificationsBinding;
import com.skillswap.model.AppNotification;
import com.skillswap.utils.Constants;
import com.skillswap.utils.UiUtils;
import com.skillswap.view.BaseActivity;
import com.skillswap.view.MainActivity;
import com.skillswap.view.challenges.ChallengeDetailActivity;
import com.skillswap.view.chat.ChatActivity;
import com.skillswap.view.exchange.ExchangeDetailActivity;
import com.skillswap.view.exchange.RequestsActivity;
import com.skillswap.viewmodel.NotificationsViewModel;

import java.util.List;

/** Centro interno de notificaciones. */
public class NotificationsActivity extends BaseActivity {

    private ActivityNotificationsBinding binding;
    private NotificationsViewModel viewModel;
    private NotificationAdapter adapter;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityNotificationsBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        viewModel = new ViewModelProvider(this).get(NotificationsViewModel.class);
        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.notifications));

        adapter = new NotificationAdapter(notification -> {
            viewModel.markRead(notification);
            open(notification);
        });
        binding.rvNotifications.setLayoutManager(new LinearLayoutManager(this));
        binding.rvNotifications.setAdapter(adapter);

        binding.btnMarkAll.setOnClickListener(v -> viewModel.markAllRead());

        viewModel.notifications().observe(this, new Observer<List<AppNotification>>() {
            @Override
            public void onChanged(List<AppNotification> list) {
                adapter.submit(list);
                boolean empty = list == null || list.isEmpty();
                UiUtils.visible(binding.empty.getRoot(), empty);
                UiUtils.visible(binding.rvNotifications, !empty);
                UiUtils.visible(binding.btnMarkAll, !empty);
                binding.empty.imgEmpty.setImageResource(R.drawable.ic_notifications);
                binding.empty.txtEmptyTitle.setText("Todo tranquilo");
                binding.empty.txtEmptyDesc.setText(
                        "Aquí verás solicitudes, mensajes, matches e insignias.");
            }
        });

        viewModel.start();
    }

    private void open(AppNotification notification) {
        String type = notification.getType() == null ? "" : notification.getType();
        String ref = notification.getReferenceId();
        Intent intent;

        switch (type) {
            case AppNotification.TYPE_NEW_MESSAGE:
                intent = new Intent(this, ChatActivity.class);
                intent.putExtra(Constants.EXTRA_CHAT_ID, ref);
                break;
            case AppNotification.TYPE_NEW_REQUEST:
            case AppNotification.TYPE_REQUEST_REJECTED:
                intent = new Intent(this, RequestsActivity.class);
                break;
            case AppNotification.TYPE_REQUEST_ACCEPTED:
            case AppNotification.TYPE_EXCHANGE_COMPLETED:
            case AppNotification.TYPE_NEW_RATING:
                intent = new Intent(this, ExchangeDetailActivity.class);
                intent.putExtra(Constants.EXTRA_EXCHANGE_ID, ref);
                break;
            case AppNotification.TYPE_CHALLENGE:
                intent = new Intent(this, ChallengeDetailActivity.class);
                intent.putExtra(Constants.EXTRA_CHALLENGE_ID, ref);
                break;
            case AppNotification.TYPE_NEW_MATCH:
                intent = new Intent(this, MainActivity.class);
                intent.putExtra(Constants.EXTRA_OPEN_SECTION, "explore");
                break;
            default:
                return;
        }
        startActivity(intent);
    }
}
EOF

# ============================================================ ContractActivity
cat > "$J/view/contracts/ContractActivity.java" <<'EOF'
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
            binding.tilObjective.getEditText().setText(
                    "Aprender " + ex.getSkillILearn(myUid) + " y enseñar "
                            + ex.getSkillITeach(myUid));
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
        view.setText(name + (accepted ? " · aceptó" : " · pendiente"));
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
EOF

echo "Vistas 7 (calificaciones/historial/notificaciones/contrato) generadas."
