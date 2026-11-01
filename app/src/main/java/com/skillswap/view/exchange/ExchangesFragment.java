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
        binding.empty.txtEmptyTitle.setText(R.string.empty_title_exchanges);
        binding.empty.txtEmptyDesc.setText(tabIndex == 2
                ? R.string.empty_desc_exchanges_done
                : R.string.empty_desc_exchanges_pending);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
