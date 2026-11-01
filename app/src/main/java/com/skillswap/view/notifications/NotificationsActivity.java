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
                binding.empty.txtEmptyTitle.setText(R.string.empty_title_notifications);
                binding.empty.txtEmptyDesc.setText(R.string.empty_desc_notifications);
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
