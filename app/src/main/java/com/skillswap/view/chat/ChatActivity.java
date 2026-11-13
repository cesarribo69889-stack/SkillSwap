package com.skillswap.view.chat;

import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.widget.EditText;
import android.widget.PopupMenu;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.skillswap.R;
import com.skillswap.adapter.MessageAdapter;
import com.skillswap.databinding.ActivityChatBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Chat;
import com.skillswap.model.ChatMessage;
import com.skillswap.model.Resource;
import com.skillswap.repository.RepoCallback;
import com.skillswap.repository.SafetyRepository;
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

    /** false mientras el chat este bloqueado o deshabilitado. */
    private boolean puedeEscribir = true;

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
        binding.btnMore.setOnClickListener(v -> mostrarOpciones());
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

                // Bloqueado: nadie escribe (lo impone tambien la regla de
                // seguridad). Se distingue quien bloqueo para no culpar a nadie.
                puedeEscribir = chat.isEnabled() && !chat.isBlocked();
                String subtitulo;
                if (chat.isBlocked()) {
                    subtitulo = getString(R.string.chat_blocked_banner);
                } else {
                    subtitulo = chat.isEnabled() ? "Intercambio activo" : "Chat deshabilitado";
                }
                binding.txtSubtitle.setText(subtitulo);
                ImageLoader.avatar(binding.imgAvatar, chat.getPartnerPhoto(myUid));
                binding.btnSend.setEnabled(puedeEscribir);
                if (binding.tilMessage.getEditText() != null) {
                    binding.tilMessage.getEditText().setEnabled(puedeEscribir);
                    binding.tilMessage.setHint(chat.isBlocked() && !chat.isBlockedByMe(myUid)
                            ? getString(R.string.chat_blocked_by_other) : null);
                }
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
                binding.btnSend.setEnabled(!state.isLoading() && puedeEscribir);
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

    // ------------------------------------------------------------------ seguridad

    private void mostrarOpciones() {
        final Chat chat = viewModel.chat().getValue();
        if (chat == null) return;
        final String partnerId = chat.getPartnerId(myUid);
        final String partnerName = chat.getPartnerName(myUid);

        PopupMenu menu = new PopupMenu(this, binding.btnMore);
        menu.getMenu().add(Menu.NONE, 1, 1, R.string.chat_report);
        if (!chat.isBlocked()) {
            menu.getMenu().add(Menu.NONE, 2, 2, R.string.chat_block);
        } else if (chat.isBlockedByMe(myUid)) {
            menu.getMenu().add(Menu.NONE, 3, 3, R.string.chat_unblock);
        }
        menu.setOnMenuItemClickListener(item -> {
            switch (item.getItemId()) {
                case 1: elegirMotivo(partnerId, partnerName); return true;
                case 2: confirmarBloqueo(partnerId, partnerName); return true;
                case 3: desbloquear(partnerId); return true;
                default: return false;
            }
        });
        menu.show();
    }

    /** Paso 1 del reporte: el motivo. */
    private void elegirMotivo(final String partnerId, final String partnerName) {
        final int[] elegido = {-1};
        new MaterialAlertDialogBuilder(this)
                .setTitle(getString(R.string.report_title, partnerName))
                .setSingleChoiceItems(SafetyRepository.MOTIVOS, -1,
                        (dialog, which) -> elegido[0] = which)
                .setNegativeButton(R.string.cancel, null)
                .setPositiveButton(R.string.report_next, (dialog, which) -> {
                    if (elegido[0] < 0) {
                        toast(binding.getRoot(), getString(R.string.report_pick_reason));
                        return;
                    }
                    pedirDetalle(partnerId, partnerName, SafetyRepository.MOTIVOS[elegido[0]]);
                })
                .show();
    }

    /** Paso 2 del reporte: detalle opcional y envio. */
    private void pedirDetalle(final String partnerId, final String partnerName,
                              final String motivo) {
        final EditText input = new EditText(this);
        input.setHint(R.string.report_details_hint);
        input.setMaxLines(4);
        int pad = (int) (20 * getResources().getDisplayMetrics().density);
        android.widget.FrameLayout holder = new android.widget.FrameLayout(this);
        holder.setPadding(pad, pad / 2, pad, 0);
        holder.addView(input);

        new MaterialAlertDialogBuilder(this)
                .setTitle(motivo)
                .setView(holder)
                .setNegativeButton(R.string.cancel, null)
                .setPositiveButton(R.string.report_send, (dialog, which) ->
                        SafetyRepository.get().report(chatId, partnerId, motivo,
                                input.getText().toString(), new RepoCallback<Boolean>() {
                                    @Override
                                    public void onSuccess(Boolean data) {
                                        toast(binding.getRoot(), getString(R.string.report_sent));
                                    }

                                    @Override
                                    public void onError(String message) {
                                        toast(binding.getRoot(), message);
                                    }
                                }))
                .show();
    }

    private void confirmarBloqueo(final String partnerId, final String partnerName) {
        new MaterialAlertDialogBuilder(this)
                .setTitle(getString(R.string.block_title, partnerName))
                .setMessage(R.string.block_message)
                .setNegativeButton(R.string.cancel, null)
                .setPositiveButton(R.string.chat_block, (dialog, which) ->
                        SafetyRepository.get().block(chatId, partnerId,
                                resultadoBloqueo(R.string.block_done)))
                .show();
    }

    private void desbloquear(String partnerId) {
        SafetyRepository.get().unblock(chatId, partnerId,
                resultadoBloqueo(R.string.unblock_done));
    }

    private RepoCallback<Boolean> resultadoBloqueo(final int mensaje) {
        return new RepoCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                toast(binding.getRoot(), getString(mensaje));
            }

            @Override
            public void onError(String message) {
                toast(binding.getRoot(), message);
            }
        };
    }

    @Override
    protected void onResume() {
        super.onResume();
        viewModel.markRead();
    }
}
