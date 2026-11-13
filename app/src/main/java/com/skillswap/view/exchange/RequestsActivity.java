package com.skillswap.view.exchange;

import android.content.Intent;
import android.os.Bundle;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
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

    /** RC3: solicitud a la espera de que se firme la aceptacion. */
    private ExchangeRequest pendiente;

    /**
     * El intercambio solo se acepta si la firma quedo registrada. Si el
     * estudiante vuelve atras sin firmar, no pasa nada.
     */
    private final ActivityResultLauncher<Intent> firmaLauncher =
            registerForActivityResult(new ActivityResultContracts.StartActivityForResult(),
                    result -> {
                        if (result.getResultCode() != RESULT_OK || pendiente == null) {
                            pendiente = null;
                            return;
                        }
                        viewModel.accept(pendiente);
                        pendiente = null;
                    });

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
                // RC3: antes de aceptar hay que firmar la constancia.
                pendiente = request;
                Intent intent = new Intent(RequestsActivity.this, SignatureActivity.class);
                intent.putExtra(Constants.EXTRA_REQUEST_ID, request.getId());
                intent.putExtra(SignatureActivity.EXTRA_RESUMEN,
                        getString(R.string.fmt_signature_summary,
                                request.getSkillWanted(), request.getSkillOffered(),
                                request.getFromUserName(), request.getModality()));
                firmaLauncher.launch(intent);
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
