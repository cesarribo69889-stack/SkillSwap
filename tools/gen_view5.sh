#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
mkdir -p "$J/view/exchange" "$J/view/chat"

# ============================================================ ExchangesFragment
cat > "$J/view/exchange/ExchangesFragment.java" <<'EOF'
package com.skillswap.view.exchange;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.google.android.material.tabs.TabLayout;
import com.skillswap.R;
import com.skillswap.adapter.ExchangeAdapter;
import com.skillswap.databinding.FragmentExchangesBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Exchange;
import com.skillswap.utils.Constants;
import com.skillswap.utils.UiUtils;
import com.skillswap.view.chat.ChatActivity;
import com.skillswap.viewmodel.ExchangeViewModel;

import java.util.List;

/** Mis intercambios: proximos, en proceso y completados. */
public class ExchangesFragment extends Fragment {

    private FragmentExchangesBinding binding;
    private ExchangeViewModel viewModel;
    private ExchangeAdapter adapter;
    private int tabIndex = 0;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        binding = FragmentExchangesBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        viewModel = new ViewModelProvider(this).get(ExchangeViewModel.class);

        adapter = new ExchangeAdapter(FirebaseManager.uid(),
                new ExchangeAdapter.OnExchangeAction() {
                    @Override
                    public void onOpenChat(Exchange exchange) {
                        Intent intent = new Intent(requireContext(), ChatActivity.class);
                        intent.putExtra(Constants.EXTRA_CHAT_ID,
                                exchange.getChatId().isEmpty()
                                        ? exchange.getId() : exchange.getChatId());
                        startActivity(intent);
                    }

                    @Override
                    public void onOpenDetail(Exchange exchange) {
                        Intent intent = new Intent(requireContext(), ExchangeDetailActivity.class);
                        intent.putExtra(Constants.EXTRA_EXCHANGE_ID, exchange.getId());
                        startActivity(intent);
                    }
                });
        binding.rvExchanges.setLayoutManager(new LinearLayoutManager(requireContext()));
        binding.rvExchanges.setAdapter(adapter);

        binding.btnRequests.setOnClickListener(v ->
                startActivity(new Intent(requireContext(), RequestsActivity.class)));

        binding.swipeRefresh.setOnRefreshListener(() -> {
            viewModel.start();
            binding.swipeRefresh.setRefreshing(false);
        });

        binding.tabs.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
            @Override
            public void onTabSelected(TabLayout.Tab tab) {
                tabIndex = tab.getPosition();
                render();
            }

            @Override
            public void onTabUnselected(TabLayout.Tab tab) {
            }

            @Override
            public void onTabReselected(TabLayout.Tab tab) {
            }
        });

        viewModel.all().observe(getViewLifecycleOwner(), new Observer<List<Exchange>>() {
            @Override
            public void onChanged(List<Exchange> exchanges) {
                render();
            }
        });

        viewModel.start();
    }

    private void render() {
        if (binding == null) return;
        String status;
        switch (tabIndex) {
            case 1: status = Exchange.STATUS_IN_PROGRESS; break;
            case 2: status = Exchange.STATUS_COMPLETED; break;
            default: status = Exchange.STATUS_UPCOMING; break;
        }
        List<Exchange> filtered = viewModel.filterByStatus(status);
        adapter.submit(filtered);

        boolean empty = filtered.isEmpty();
        UiUtils.visible(binding.empty.getRoot(), empty);
        UiUtils.visible(binding.swipeRefresh, !empty);
        binding.empty.imgEmpty.setImageResource(R.drawable.ic_swap);
        binding.empty.txtEmptyTitle.setText("Nada por aquí");
        binding.empty.txtEmptyDesc.setText(tabIndex == 2
                ? "Cuando termines un intercambio aparecerá en esta lista."
                : "Envía una solicitud desde Explorar para crear tu primer intercambio.");
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
EOF

# ============================================================ RequestsActivity
cat > "$J/view/exchange/RequestsActivity.java" <<'EOF'
package com.skillswap.view.exchange;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.google.android.material.tabs.TabLayout;
import com.skillswap.R;
import com.skillswap.adapter.RequestAdapter;
import com.skillswap.databinding.ActivityRequestsBinding;
import com.skillswap.model.Exchange;
import com.skillswap.model.ExchangeRequest;
import com.skillswap.model.Resource;
import com.skillswap.utils.Constants;
import com.skillswap.utils.UiUtils;
import com.skillswap.view.BaseActivity;
import com.skillswap.view.chat.ChatActivity;
import com.skillswap.view.profile.UserProfileActivity;
import com.skillswap.viewmodel.RequestsViewModel;

import java.util.ArrayList;
import java.util.List;

/** Solicitudes recibidas y enviadas. */
public class RequestsActivity extends BaseActivity {

    private ActivityRequestsBinding binding;
    private RequestsViewModel viewModel;
    private RequestAdapter adapter;
    private boolean receivedTab = true;

    private List<ExchangeRequest> received = new ArrayList<>();
    private List<ExchangeRequest> sent = new ArrayList<>();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityRequestsBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        viewModel = new ViewModelProvider(this).get(RequestsViewModel.class);
        setupToolbar(binding.toolbarInc.toolbar, "Solicitudes");

        adapter = new RequestAdapter(new RequestAdapter.OnRequestAction() {
            @Override
            public void onAccept(final ExchangeRequest request) {
                confirm("Aceptar intercambio",
                        "Se creará el intercambio con " + request.getFromUserName()
                                + " y se habilitará el chat.",
                        "Aceptar",
                        () -> viewModel.accept(request));
            }

            @Override
            public void onReject(final ExchangeRequest request) {
                confirm("Rechazar solicitud",
                        "¿Seguro que no quieres realizar este intercambio?",
                        "Rechazar",
                        () -> viewModel.reject(request));
            }

            @Override
            public void onCancel(final ExchangeRequest request) {
                confirm("Cancelar solicitud",
                        "La retiraremos del buzón del otro estudiante.",
                        "Cancelar solicitud",
                        () -> viewModel.cancel(request));
            }

            @Override
            public void onOpenProfile(ExchangeRequest request) {
                Intent intent = new Intent(RequestsActivity.this, UserProfileActivity.class);
                intent.putExtra(Constants.EXTRA_USER_ID, receivedTab
                        ? request.getFromUserId() : request.getToUserId());
                startActivity(intent);
            }
        });
        binding.rvRequests.setLayoutManager(new LinearLayoutManager(this));
        binding.rvRequests.setAdapter(adapter);

        binding.tabs.addOnTabSelectedListener(new TabLayout.OnTabSelectedListener() {
            @Override
            public void onTabSelected(TabLayout.Tab tab) {
                receivedTab = tab.getPosition() == 0;
                render();
            }

            @Override
            public void onTabUnselected(TabLayout.Tab tab) {
            }

            @Override
            public void onTabReselected(TabLayout.Tab tab) {
            }
        });

        observe();
        viewModel.start();
    }

    private void observe() {
        viewModel.received().observe(this, new Observer<List<ExchangeRequest>>() {
            @Override
            public void onChanged(List<ExchangeRequest> list) {
                received = list;
                render();
            }
        });
        viewModel.sent().observe(this, new Observer<List<ExchangeRequest>>() {
            @Override
            public void onChanged(List<ExchangeRequest> list) {
                sent = list;
                render();
            }
        });

        viewModel.acceptState().observe(this, new Observer<Resource<Exchange>>() {
            @Override
            public void onChanged(Resource<Exchange> state) {
                if (state == null) return;
                if (state.isSuccess() && state.getData() != null) {
                    Exchange ex = state.getData();
                    toast(binding.getRoot(), "¡Intercambio creado! Ya pueden conversar.");
                    Intent intent = new Intent(RequestsActivity.this, ChatActivity.class);
                    intent.putExtra(Constants.EXTRA_CHAT_ID,
                            ex.getChatId().isEmpty() ? ex.getId() : ex.getChatId());
                    startActivity(intent);
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
        List<ExchangeRequest> data = receivedTab ? received : sent;
        adapter.setReceivedMode(receivedTab);
        adapter.submit(data);

        boolean empty = data == null || data.isEmpty();
        UiUtils.visible(binding.empty.getRoot(), empty);
        UiUtils.visible(binding.rvRequests, !empty);
        binding.empty.imgEmpty.setImageResource(R.drawable.ic_inbox);
        binding.empty.txtEmptyTitle.setText(receivedTab
                ? "Sin solicitudes recibidas" : "Sin solicitudes enviadas");
        binding.empty.txtEmptyDesc.setText(receivedTab
                ? "Cuando alguien quiera intercambiar contigo lo verás aquí."
                : "Explora estudiantes y propón tu primer intercambio.");
    }
}
EOF

# ============================================================ SendRequestActivity
cat > "$J/view/exchange/SendRequestActivity.java" <<'EOF'
package com.skillswap.view.exchange;

import android.os.Bundle;
import android.widget.ArrayAdapter;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.google.android.material.chip.Chip;
import com.google.android.material.textfield.MaterialAutoCompleteTextView;
import com.skillswap.R;
import com.skillswap.databinding.ActivitySendRequestBinding;
import com.skillswap.model.ExchangeRequest;
import com.skillswap.model.MatchResult;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.model.UserSkill;
import com.skillswap.repository.UserRepository;
import com.skillswap.utils.ChipFactory;
import com.skillswap.utils.Constants;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.SkillMatchEngine;
import com.skillswap.utils.UiUtils;
import com.skillswap.utils.Validators;
import com.skillswap.view.BaseActivity;
import com.skillswap.viewmodel.ProfileViewModel;
import com.skillswap.viewmodel.RequestsViewModel;

import java.util.Arrays;
import java.util.List;
import java.util.Locale;

/** Formulario de solicitud de intercambio. */
public class SendRequestActivity extends BaseActivity {

    private ActivitySendRequestBinding binding;
    private RequestsViewModel requestsViewModel;
    private ProfileViewModel profileViewModel;

    private User target;
    private int matchScore;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivitySendRequestBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        String userId = getIntent().getStringExtra(Constants.EXTRA_USER_ID);
        requestsViewModel = new ViewModelProvider(this).get(RequestsViewModel.class);
        profileViewModel = new ViewModelProvider(this).get(ProfileViewModel.class);

        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.send_request));
        setupSchedules();

        binding.btnSend.setOnClickListener(v -> send());

        profileViewModel.profileState().observe(this, new Observer<Resource<User>>() {
            @Override
            public void onChanged(Resource<User> state) {
                if (state == null) return;
                if (state.isSuccess()) {
                    target = state.getData();
                    render();
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });

        requestsViewModel.sendState().observe(this, new Observer<Resource<ExchangeRequest>>() {
            @Override
            public void onChanged(Resource<ExchangeRequest> state) {
                if (state == null) return;
                binding.btnSend.setEnabled(!state.isLoading());
                if (state.isSuccess()) {
                    info("¡Solicitud enviada!",
                            "Te avisaremos cuando " + target.getShortName() + " responda.");
                    binding.btnSend.postDelayed(SendRequestActivity.this::finish, 900);
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });

        profileViewModel.loadProfile(userId);
    }

    private void setupSchedules() {
        List<String> slots = Arrays.asList(getResources().getStringArray(R.array.availability_slots));
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this,
                android.R.layout.simple_list_item_1, slots);
        if (binding.tilSchedule.getEditText() instanceof MaterialAutoCompleteTextView) {
            ((MaterialAutoCompleteTextView) binding.tilSchedule.getEditText()).setAdapter(adapter);
        }
    }

    private void render() {
        if (target == null) return;

        User me = UserRepository.get().currentUserValue();
        MatchResult match = SkillMatchEngine.calculate(me, target);
        matchScore = match.getScore();

        binding.txtName.setText(target.getFullName());
        binding.txtCareer.setText(target.getAcademicLine());
        binding.txtScore.setText(String.format(Locale.getDefault(), "%d %%", matchScore));
        ImageLoader.avatar(binding.imgAvatar, target.getPhotoUrl());

        // Habilidades que el otro ensena (lo que yo puedo aprender).
        binding.chipsWanted.removeAllViews();
        for (UserSkill s : target.getTeachSkills()) {
            Chip chip = ChipFactory.choiceChip(this, s.getName() + " · " + s.getLevel(), false);
            chip.setTag(s.getName());
            binding.chipsWanted.addView(chip);
        }
        preselect(binding.chipsWanted, match.getTheyTeachYouWant());

        // Habilidades que yo ensenio.
        binding.chipsOffered.removeAllViews();
        if (me != null) {
            for (UserSkill s : me.getTeachSkills()) {
                Chip chip = ChipFactory.choiceChip(this, s.getName() + " · " + s.getLevel(), false);
                chip.setTag(s.getName());
                binding.chipsOffered.addView(chip);
            }
            preselect(binding.chipsOffered, match.getYouTeachTheyWant());
        }

        boolean presencial = Constants.MODALITY_PRESENCIAL.equals(target.getModality());
        binding.chipPresencial.setChecked(presencial);
        binding.chipVirtual.setChecked(!presencial);

        if (!target.getAvailability().isEmpty()
                && binding.tilSchedule.getEditText() instanceof MaterialAutoCompleteTextView) {
            ((MaterialAutoCompleteTextView) binding.tilSchedule.getEditText())
                    .setText(target.getAvailability().get(0), false);
        }
    }

    private void preselect(com.google.android.material.chip.ChipGroup group, List<String> values) {
        if (values == null || values.isEmpty()) return;
        for (int i = 0; i < group.getChildCount(); i++) {
            Chip chip = (Chip) group.getChildAt(i);
            if (values.contains(String.valueOf(chip.getTag()))) {
                chip.setChecked(true);
                return;
            }
        }
    }

    private void send() {
        UiUtils.hideKeyboard(binding.getRoot());
        if (target == null) return;

        String wanted = selected(binding.chipsWanted);
        String offered = selected(binding.chipsOffered);

        if (wanted == null) {
            toast(binding.getRoot(), "Elige qué quieres aprender");
            return;
        }
        if (offered == null) {
            toast(binding.getRoot(), "Elige qué puedes enseñar");
            return;
        }

        String modality = binding.chipPresencial.isChecked()
                ? Constants.MODALITY_PRESENCIAL : Constants.MODALITY_VIRTUAL;
        String schedule = Validators.text(binding.tilSchedule).trim();
        String message = Validators.text(binding.tilMessage).trim();

        if (schedule.isEmpty()) {
            toast(binding.getRoot(), "Propón un horario");
            return;
        }

        requestsViewModel.sendRequest(target, wanted, offered, message, modality,
                schedule, matchScore);
    }

    private String selected(com.google.android.material.chip.ChipGroup group) {
        for (int i = 0; i < group.getChildCount(); i++) {
            Chip chip = (Chip) group.getChildAt(i);
            if (chip.isChecked()) return String.valueOf(chip.getTag());
        }
        return null;
    }
}
EOF

echo "Vistas 5 (intercambios/solicitudes) generadas."
