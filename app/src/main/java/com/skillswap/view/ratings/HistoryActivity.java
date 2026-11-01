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
                binding.empty.txtEmptyTitle.setText(R.string.empty_title_history);
                binding.empty.txtEmptyDesc.setText(R.string.empty_desc_history);
            }
        });

        viewModel.start();
    }
}
