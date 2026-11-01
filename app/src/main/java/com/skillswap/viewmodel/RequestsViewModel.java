package com.skillswap.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.google.firebase.firestore.ListenerRegistration;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Exchange;
import com.skillswap.model.ExchangeRequest;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.repository.ExchangeRequestRepository;
import com.skillswap.repository.RepoCallback;
import com.skillswap.repository.UserRepository;

import java.util.ArrayList;
import java.util.List;

/** ViewModel de solicitudes recibidas / enviadas. */
public class RequestsViewModel extends ViewModel {

    private final ExchangeRequestRepository repository = ExchangeRequestRepository.get();

    private final MutableLiveData<List<ExchangeRequest>> received = new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<List<ExchangeRequest>> sent = new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<Resource<ExchangeRequest>> sendState = new MutableLiveData<>();
    private final MutableLiveData<Resource<Exchange>> acceptState = new MutableLiveData<>();
    private final MutableLiveData<Resource<Boolean>> actionState = new MutableLiveData<>();

    private ListenerRegistration receivedReg;
    private ListenerRegistration sentReg;

    public LiveData<List<ExchangeRequest>> received() {
        return received;
    }

    public LiveData<List<ExchangeRequest>> sent() {
        return sent;
    }

    public LiveData<Resource<ExchangeRequest>> sendState() {
        return sendState;
    }

    public LiveData<Resource<Exchange>> acceptState() {
        return acceptState;
    }

    public LiveData<Resource<Boolean>> actionState() {
        return actionState;
    }

    public void start() {
        String uid = FirebaseManager.uid();
        if (uid.isEmpty()) return;

        if (receivedReg == null) {
            receivedReg = repository.listenReceived(uid, new RepoCallback<List<ExchangeRequest>>() {
                @Override
                public void onSuccess(List<ExchangeRequest> data) {
                    received.postValue(data);
                }

                @Override
                public void onError(String message) {
                }
            });
        }
        if (sentReg == null) {
            sentReg = repository.listenSent(uid, new RepoCallback<List<ExchangeRequest>>() {
                @Override
                public void onSuccess(List<ExchangeRequest> data) {
                    sent.postValue(data);
                }

                @Override
                public void onError(String message) {
                }
            });
        }
    }

    public void sendRequest(User target, String skillWanted, String skillOffered,
                            String message, String modality, String schedule, int matchScore) {
        User me = UserRepository.get().currentUserValue();
        sendState.setValue(Resource.<ExchangeRequest>loading());
        repository.send(me, target, skillWanted, skillOffered, message, modality, schedule,
                matchScore, new RepoCallback<ExchangeRequest>() {
                    @Override
                    public void onSuccess(ExchangeRequest data) {
                        sendState.postValue(Resource.success(data));
                    }

                    @Override
                    public void onError(String msg) {
                        sendState.postValue(Resource.<ExchangeRequest>error(msg));
                    }
                });
    }

    public void accept(ExchangeRequest request) {
        acceptState.setValue(Resource.<Exchange>loading());
        repository.accept(request, new RepoCallback<Exchange>() {
            @Override
            public void onSuccess(Exchange data) {
                acceptState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                acceptState.postValue(Resource.<Exchange>error(message));
            }
        });
    }

    public void reject(ExchangeRequest request) {
        actionState.setValue(Resource.<Boolean>loading());
        repository.reject(request, wrap());
    }

    public void cancel(ExchangeRequest request) {
        actionState.setValue(Resource.<Boolean>loading());
        repository.cancel(request, wrap());
    }

    private RepoCallback<Boolean> wrap() {
        return new RepoCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                actionState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                actionState.postValue(Resource.<Boolean>error(message));
            }
        };
    }

    @Override
    protected void onCleared() {
        super.onCleared();
        if (receivedReg != null) receivedReg.remove();
        if (sentReg != null) sentReg.remove();
    }
}
