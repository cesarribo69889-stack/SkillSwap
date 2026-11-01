package com.skillswap.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.google.firebase.firestore.ListenerRegistration;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Chat;
import com.skillswap.repository.ChatRepository;
import com.skillswap.repository.RepoCallback;

import java.util.ArrayList;
import java.util.List;

/** ViewModel de la lista de conversaciones. */
public class ChatListViewModel extends ViewModel {

    private final MutableLiveData<List<Chat>> chats = new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<Boolean> loading = new MutableLiveData<>(true);
    private ListenerRegistration reg;

    public LiveData<List<Chat>> chats() {
        return chats;
    }

    public LiveData<Boolean> loading() {
        return loading;
    }

    public void start() {
        String uid = FirebaseManager.uid();
        if (uid.isEmpty() || reg != null) return;
        reg = ChatRepository.get().listenChats(uid, new RepoCallback<List<Chat>>() {
            @Override
            public void onSuccess(List<Chat> data) {
                chats.postValue(data);
                loading.postValue(false);
            }

            @Override
            public void onError(String message) {
                loading.postValue(false);
            }
        });
    }

    @Override
    protected void onCleared() {
        super.onCleared();
        if (reg != null) reg.remove();
    }
}
