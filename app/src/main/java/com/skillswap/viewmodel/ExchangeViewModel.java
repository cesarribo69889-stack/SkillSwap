package com.skillswap.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.google.firebase.firestore.ListenerRegistration;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Exchange;
import com.skillswap.model.LearningContract;
import com.skillswap.model.Resource;
import com.skillswap.repository.ContractRepository;
import com.skillswap.repository.ExchangeRepository;
import com.skillswap.repository.RepoCallback;

import java.util.ArrayList;
import java.util.List;

/** ViewModel de "Mis intercambios" y del detalle de un intercambio. */
public class ExchangeViewModel extends ViewModel {

    private final ExchangeRepository repository = ExchangeRepository.get();

    private final MutableLiveData<List<Exchange>> all = new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<Exchange> detail = new MutableLiveData<>();
    private final MutableLiveData<LearningContract> contract = new MutableLiveData<>();
    private final MutableLiveData<Resource<Exchange>> completeState = new MutableLiveData<>();
    private final MutableLiveData<Resource<Boolean>> actionState = new MutableLiveData<>();

    private ListenerRegistration listReg;
    private ListenerRegistration detailReg;
    private ListenerRegistration contractReg;

    public LiveData<List<Exchange>> all() {
        return all;
    }

    public LiveData<Exchange> detail() {
        return detail;
    }

    public LiveData<LearningContract> contract() {
        return contract;
    }

    public LiveData<Resource<Exchange>> completeState() {
        return completeState;
    }

    public LiveData<Resource<Boolean>> actionState() {
        return actionState;
    }

    public void start() {
        String uid = FirebaseManager.uid();
        if (uid.isEmpty() || listReg != null) return;
        listReg = repository.listenByUser(uid, new RepoCallback<List<Exchange>>() {
            @Override
            public void onSuccess(List<Exchange> data) {
                all.postValue(data);
            }

            @Override
            public void onError(String message) {
            }
        });
    }

    /** Filtra por estado: PROXIMO / EN_PROCESO / COMPLETADO. */
    public List<Exchange> filterByStatus(String status) {
        List<Exchange> out = new ArrayList<>();
        List<Exchange> source = all.getValue();
        if (source == null) return out;
        for (Exchange e : source) {
            if (status.equals(e.getStatus())) out.add(e);
        }
        return out;
    }

    public void observeDetail(String exchangeId) {
        if (detailReg != null) detailReg.remove();
        detailReg = repository.listenById(exchangeId, new RepoCallback<Exchange>() {
            @Override
            public void onSuccess(Exchange data) {
                detail.postValue(data);
            }

            @Override
            public void onError(String message) {
            }
        });

        if (contractReg != null) contractReg.remove();
        contractReg = ContractRepository.get().listen(exchangeId, new RepoCallback<LearningContract>() {
            @Override
            public void onSuccess(LearningContract data) {
                contract.postValue(data);
            }

            @Override
            public void onError(String message) {
            }
        });
    }

    public void markCompleted(Exchange exchange) {
        completeState.setValue(Resource.<Exchange>loading());
        repository.markCompleted(exchange, FirebaseManager.uid(), new RepoCallback<Exchange>() {
            @Override
            public void onSuccess(Exchange data) {
                completeState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                completeState.postValue(Resource.<Exchange>error(message));
            }
        });
    }

    public void updateProgress(Exchange exchange, int sessionsDone) {
        actionState.setValue(Resource.<Boolean>loading());
        repository.updateProgress(exchange, sessionsDone, new RepoCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                actionState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                actionState.postValue(Resource.<Boolean>error(message));
            }
        });
    }

    public void cancel(Exchange exchange) {
        actionState.setValue(Resource.<Boolean>loading());
        repository.cancel(exchange.getId(), new RepoCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                actionState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                actionState.postValue(Resource.<Boolean>error(message));
            }
        });
    }

    @Override
    protected void onCleared() {
        super.onCleared();
        if (listReg != null) listReg.remove();
        if (detailReg != null) detailReg.remove();
        if (contractReg != null) contractReg.remove();
    }
}
