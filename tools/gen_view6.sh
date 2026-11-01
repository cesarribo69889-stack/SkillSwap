#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
mkdir -p "$J/view/exchange" "$J/view/chat"

# ============================================================ ExchangeDetailActivity
cat > "$J/view/exchange/ExchangeDetailActivity.java" <<'EOF'
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
        binding.txtModality.setText("Modalidad: " + exchange.getModality());
        binding.txtSchedule.setText(exchange.getSchedule().isEmpty()
                ? "Horario por coordinar" : exchange.getSchedule());
        binding.txtDate.setText("Inicio: " + DateUtils.formatDate(exchange.getStartDate()));

        binding.progressBar.setProgress(exchange.getProgress());
        binding.txtProgressValue.setText(exchange.getProgress() + " %");
        binding.txtSessions.setText(exchange.getSessionsTotal() > 0
                ? "Sesión " + exchange.getSessionsDone() + " de " + exchange.getSessionsTotal()
                : "Aún no acordaron la cantidad de sesiones");

        ImageLoader.avatar(binding.imgAvatar, exchange.getPartnerPhoto(myUid));

        boolean completed = Exchange.STATUS_COMPLETED.equals(exchange.getStatus());
        UiUtils.visible(binding.btnSession, !completed);

        if (completed) {
            binding.btnPrimary.setText(exchange.hasRated(myUid)
                    ? "Ya calificado" : getString(R.string.rate_exchange));
            binding.btnPrimary.setEnabled(!exchange.hasRated(myUid));
        } else if (exchange.hasCompleted(myUid)) {
            binding.btnPrimary.setText("Esperando confirmación");
        } else {
            binding.btnPrimary.setText(R.string.mark_completed);
            binding.btnPrimary.setEnabled(true);
        }
    }

    private void renderContract() {
        if (contract == null) {
            binding.txtContractStatus.setText("Aún no definido · toca para crearlo");
            return;
        }
        if (contract.isFullyAccepted()) {
            binding.txtContractStatus.setText("Acuerdo activo · "
                    + contract.getSessions() + " sesiones de "
                    + contract.getSessionDuration() + " min");
        } else if (contract.hasAccepted(myUid)) {
            binding.txtContractStatus.setText("Esperando la aceptación de tu compañero");
        } else {
            binding.txtContractStatus.setText("Pendiente de tu aceptación");
        }
    }
}
EOF

# ============================================================ EvidenceActivity
cat > "$J/view/exchange/EvidenceActivity.java" <<'EOF'
package com.skillswap.view.exchange;

import android.net.Uri;
import android.os.Bundle;

import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.skillswap.R;
import com.skillswap.databinding.ActivityEvidenceBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Exchange;
import com.skillswap.model.LearningEvidence;
import com.skillswap.model.Resource;
import com.skillswap.utils.Constants;
import com.skillswap.utils.UiUtils;
import com.skillswap.utils.Validators;
import com.skillswap.view.BaseActivity;
import com.skillswap.viewmodel.EvidenceViewModel;

/**
 * INNOVACION 6 - Validacion practica del aprendizaje.
 * Autoevaluacion entre pares, no es una certificacion academica.
 */
public class EvidenceActivity extends BaseActivity {

    private ActivityEvidenceBinding binding;
    private EvidenceViewModel viewModel;
    private Exchange exchange;
    private Uri fileUri;

    private final ActivityResultLauncher<String> pickImage =
            registerForActivityResult(new ActivityResultContracts.GetContent(),
                    new ActivityResultCallback<Uri>() {
                        @Override
                        public void onActivityResult(Uri uri) {
                            if (uri == null) return;
                            fileUri = uri;
                            binding.imgPreview.setImageURI(uri);
                            UiUtils.visible(binding.imgPreview, true);
                        }
                    });

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityEvidenceBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        String exchangeId = getIntent().getStringExtra(Constants.EXTRA_EXCHANGE_ID);
        viewModel = new ViewModelProvider(this).get(EvidenceViewModel.class);

        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.learning_evidence));

        binding.btnAttach.setOnClickListener(v -> pickImage.launch("image/*"));
        binding.btnSubmit.setOnClickListener(v -> submit());

        viewModel.exchange().observe(this, new Observer<Exchange>() {
            @Override
            public void onChanged(Exchange data) {
                if (data == null) return;
                exchange = data;
                binding.txtSkill.setText(data.getSkillILearn(FirebaseManager.uid()));
            }
        });

        viewModel.submitState().observe(this, new Observer<Resource<LearningEvidence>>() {
            @Override
            public void onChanged(Resource<LearningEvidence> state) {
                if (state == null) return;
                binding.btnSubmit.setEnabled(!state.isLoading());
                if (state.isSuccess()) {
                    info("Actividad registrada",
                            "Sumaste " + Constants.POINTS_EVIDENCE_REGISTERED
                                    + " SkillPoints. Recuerda que este registro es una "
                                    + "autoevaluación entre pares, no una certificación académica.");
                    binding.btnSubmit.postDelayed(EvidenceActivity.this::finish, 1200);
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });

        if (exchangeId != null) viewModel.load(exchangeId);
    }

    private void submit() {
        UiUtils.hideKeyboard(binding.getRoot());
        if (exchange == null) {
            toast(binding.getRoot(), "El intercambio aún se está cargando");
            return;
        }

        String activity = Validators.text(binding.tilActivity).trim();
        if (!Validators.apply(binding.tilActivity,
                Validators.validateMinLength(activity, 5, "La actividad"))) return;

        LearningEvidence evidence = new LearningEvidence();
        evidence.setActivity(activity);
        evidence.setNotes(Validators.text(binding.tilNotes).trim());
        evidence.setObjectiveAchieved(binding.switchAchieved.isChecked());
        evidence.setSelfAssessment((int) binding.ratingSelf.getRating());

        viewModel.submit(evidence, fileUri);
    }
}
EOF

# ============================================================ ChatsFragment
cat > "$J/view/chat/ChatsFragment.java" <<'EOF'
package com.skillswap.view.chat;

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

import com.skillswap.R;
import com.skillswap.adapter.ChatAdapter;
import com.skillswap.databinding.FragmentChatsBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Chat;
import com.skillswap.utils.Constants;
import com.skillswap.utils.UiUtils;
import com.skillswap.viewmodel.ChatListViewModel;

import java.util.List;

/** Lista de conversaciones activas. */
public class ChatsFragment extends Fragment {

    private FragmentChatsBinding binding;
    private ChatListViewModel viewModel;
    private ChatAdapter adapter;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        binding = FragmentChatsBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        viewModel = new ViewModelProvider(this).get(ChatListViewModel.class);

        adapter = new ChatAdapter(FirebaseManager.uid(), chat -> {
            Intent intent = new Intent(requireContext(), ChatActivity.class);
            intent.putExtra(Constants.EXTRA_CHAT_ID, chat.getId());
            startActivity(intent);
        });
        binding.rvChats.setLayoutManager(new LinearLayoutManager(requireContext()));
        binding.rvChats.setAdapter(adapter);

        binding.swipeRefresh.setOnRefreshListener(() -> {
            viewModel.start();
            binding.swipeRefresh.setRefreshing(false);
        });

        viewModel.chats().observe(getViewLifecycleOwner(), new Observer<List<Chat>>() {
            @Override
            public void onChanged(List<Chat> chats) {
                adapter.submit(chats);
                boolean empty = chats == null || chats.isEmpty();
                UiUtils.visible(binding.empty.getRoot(), empty);
                UiUtils.visible(binding.swipeRefresh, !empty);
                binding.empty.imgEmpty.setImageResource(R.drawable.ic_chat);
                binding.empty.txtEmptyTitle.setText("Sin conversaciones");
                binding.empty.txtEmptyDesc.setText(
                        "El chat se habilita automáticamente cuando alguien acepta "
                                + "una solicitud de intercambio.");
            }
        });

        viewModel.start();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
EOF

# ============================================================ ChatActivity
cat > "$J/view/chat/ChatActivity.java" <<'EOF'
package com.skillswap.view.chat;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.skillswap.adapter.MessageAdapter;
import com.skillswap.databinding.ActivityChatBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Chat;
import com.skillswap.model.ChatMessage;
import com.skillswap.model.Resource;
import com.skillswap.utils.Constants;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;
import com.skillswap.view.BaseActivity;
import com.skillswap.view.exchange.ExchangeDetailActivity;
import com.skillswap.viewmodel.ChatViewModel;

import java.util.List;

/**
 * Conversacion en tiempo real con Cloud Firestore.
 * Solo existe cuando hay un intercambio aceptado.
 */
public class ChatActivity extends BaseActivity {

    private ActivityChatBinding binding;
    private ChatViewModel viewModel;
    private MessageAdapter adapter;
    private String chatId;
    private final String myUid = FirebaseManager.uid();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityChatBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        chatId = getIntent().getStringExtra(Constants.EXTRA_CHAT_ID);
        viewModel = new ViewModelProvider(this).get(ChatViewModel.class);

        adapter = new MessageAdapter(myUid);
        LinearLayoutManager layoutManager = new LinearLayoutManager(this);
        layoutManager.setStackFromEnd(true);
        binding.rvMessages.setLayoutManager(layoutManager);
        binding.rvMessages.setAdapter(adapter);

        binding.btnBack.setOnClickListener(v -> finish());
        binding.btnSend.setOnClickListener(v -> send());
        binding.btnExchange.setOnClickListener(v -> {
            Chat chat = viewModel.chat().getValue();
            if (chat == null) return;
            Intent intent = new Intent(this, ExchangeDetailActivity.class);
            intent.putExtra(Constants.EXTRA_EXCHANGE_ID, chat.getExchangeId());
            startActivity(intent);
        });

        observe();

        if (chatId == null || chatId.isEmpty()) {
            toast(binding.getRoot(), "Conversación no disponible");
            finish();
            return;
        }
        viewModel.open(chatId);
    }

    private void observe() {
        viewModel.chat().observe(this, new Observer<Chat>() {
            @Override
            public void onChanged(Chat chat) {
                if (chat == null) return;
                binding.txtName.setText(chat.getPartnerName(myUid));
                binding.txtSubtitle.setText(chat.isEnabled()
                        ? "Intercambio activo" : "Chat deshabilitado");
                ImageLoader.avatar(binding.imgAvatar, chat.getPartnerPhoto(myUid));
                binding.btnSend.setEnabled(chat.isEnabled());
            }
        });

        viewModel.messages().observe(this, new Observer<List<ChatMessage>>() {
            @Override
            public void onChanged(List<ChatMessage> messages) {
                adapter.submit(messages);
                boolean empty = messages == null || messages.isEmpty();
                UiUtils.visible(binding.txtEmpty, empty);
                if (!empty) {
                    binding.rvMessages.scrollToPosition(adapter.lastIndex());
                    viewModel.markRead();
                }
            }
        });

        viewModel.sendState().observe(this, new Observer<Resource<Boolean>>() {
            @Override
            public void onChanged(Resource<Boolean> state) {
                if (state == null) return;
                binding.btnSend.setEnabled(!state.isLoading());
                if (state.isSuccess() && binding.tilMessage.getEditText() != null) {
                    binding.tilMessage.getEditText().setText("");
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });

        viewModel.error().observe(this, new Observer<String>() {
            @Override
            public void onChanged(String message) {
                if (message != null) toast(binding.getRoot(), message);
            }
        });
    }

    private void send() {
        if (binding.tilMessage.getEditText() == null) return;
        String text = binding.tilMessage.getEditText().getText().toString();
        if (text.trim().isEmpty()) return;
        viewModel.send(text);
    }

    @Override
    protected void onResume() {
        super.onResume();
        viewModel.markRead();
    }
}
EOF

echo "Vistas 6 (detalle/evidencia/chat) generadas."
