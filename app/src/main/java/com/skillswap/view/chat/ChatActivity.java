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
