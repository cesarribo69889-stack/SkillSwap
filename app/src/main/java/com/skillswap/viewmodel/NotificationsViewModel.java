package com.skillswap.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.google.firebase.firestore.ListenerRegistration;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.AppNotification;
import com.skillswap.repository.NotificationRepository;
import com.skillswap.repository.RepoCallback;

import java.util.ArrayList;
import java.util.List;

/** ViewModel del centro interno de notificaciones. */
public class NotificationsViewModel extends ViewModel {

    private final NotificationRepository repository = NotificationRepository.get();

    private final MutableLiveData<List<AppNotification>> notifications =
            new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<Integer> unread = new MutableLiveData<>(0);
    private final MutableLiveData<Boolean> loading = new MutableLiveData<>(true);

    private ListenerRegistration reg;

    public LiveData<List<AppNotification>> notifications() {
        return notifications;
    }

    public LiveData<Integer> unread() {
        return unread;
    }

    public LiveData<Boolean> loading() {
        return loading;
    }

    public void start() {
        String uid = FirebaseManager.uid();
        if (uid.isEmpty() || reg != null) return;
        reg = repository.listen(uid, new RepoCallback<List<AppNotification>>() {
            @Override
            public void onSuccess(List<AppNotification> data) {
                notifications.postValue(data);
                int count = 0;
                for (AppNotification n : data) if (!n.isRead()) count++;
                unread.postValue(count);
                loading.postValue(false);
            }

            @Override
            public void onError(String message) {
                loading.postValue(false);
            }
        });
    }

    public void markRead(AppNotification notification) {
        repository.markRead(notification.getId());
    }

    public void markAllRead() {
        repository.markAllRead(notifications.getValue());
    }

    @Override
    protected void onCleared() {
        super.onCleared();
        if (reg != null) reg.remove();
    }
}
