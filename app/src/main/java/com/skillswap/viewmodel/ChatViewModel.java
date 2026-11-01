package com.skillswap.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.google.firebase.firestore.ListenerRegistration;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Chat;
import com.skillswap.model.ChatMessage;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.repository.ChatRepository;
import com.skillswap.repository.RepoCallback;
import com.skillswap.repository.UserRepository;

import java.util.ArrayList;
import java.util.List;

/** ViewModel de una conversacion. El chat exige un intercambio aceptado. */
public class ChatViewModel extends ViewModel {

    private final ChatRepository repository = ChatRepository.get();

    private final MutableLiveData<Chat> chat = new MutableLiveData<>();
    private final MutableLiveData<List<ChatMessage>> messages = new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<Resource<Boolean>> sendState = new MutableLiveData<>();
    private final MutableLiveData<String> error = new MutableLiveData<>();

    private ListenerRegistration messagesReg;
    private ListenerRegistration chatReg;

    public LiveData<Chat> chat() {
        return chat;
    }

    public LiveData<List<ChatMessage>> messages() {
        return messages;
    }

    public LiveData<Resource<Boolean>> sendState() {
        return sendState;
    }

    public LiveData<String> error() {
        return error;
    }

    public void open(final String chatId) {
        repository.fetchChat(chatId, new RepoCallback<Chat>() {
            @Override
            public void onSuccess(Chat data) {
                chat.postValue(data);
                repository.markRead(chatId, FirebaseManager.uid());
                listen(chatId);
            }

            @Override
            public void onError(String message) {
                error.postValue(message);
            }
        });
    }

    private void listen(String chatId) {
        if (messagesReg != null) messagesReg.remove();
        messagesReg = repository.listenMessages(chatId, new RepoCallback<List<ChatMessage>>() {
            @Override
            public void onSuccess(List<ChatMessage> data) {
                messages.postValue(data);
            }

            @Override
            public void onError(String message) {
                error.postValue(message);
            }
        });

        if (chatReg != null) chatReg.remove();
        chatReg = repository.listenChat(chatId, new RepoCallback<Chat>() {
            @Override
            public void onSuccess(Chat data) {
                chat.postValue(data);
            }

            @Override
            public void onError(String message) {
            }
        });
    }

    public void send(String text) {
        Chat current = chat.getValue();
        User me = UserRepository.get().currentUserValue();
        if (current == null) {
            error.setValue("La conversación aún no está lista");
            return;
        }
        String name = me == null ? "Estudiante" : me.getFullName();
        String photo = me == null ? "" : me.getPhotoUrl();

        sendState.setValue(Resource.<Boolean>loading());
        repository.sendMessage(current, FirebaseManager.uid(), name, photo, text,
                new RepoCallback<Boolean>() {
                    @Override
                    public void onSuccess(Boolean data) {
                        sendState.postValue(Resource.success(data));
                    }

                    @Override
                    public void onError(String message) {
                        sendState.postValue(Resource.<Boolean>error(message));
                    }
                });
    }

    public void markRead() {
        Chat current = chat.getValue();
        if (current != null) repository.markRead(current.getId(), FirebaseManager.uid());
    }

    @Override
    protected void onCleared() {
        super.onCleared();
        if (messagesReg != null) messagesReg.remove();
        if (chatReg != null) chatReg.remove();
    }
}
