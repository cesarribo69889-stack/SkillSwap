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
                binding.empty.txtEmptyTitle.setText(R.string.empty_title_chats);
                binding.empty.txtEmptyDesc.setText(R.string.empty_desc_chats);
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
