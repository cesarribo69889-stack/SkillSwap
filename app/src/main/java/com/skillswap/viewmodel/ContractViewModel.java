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

/** ViewModel del Contrato de Aprendizaje (Innovacion 3). */
public class ContractViewModel extends ViewModel {

    private final ContractRepository repository = ContractRepository.get();

    private final MutableLiveData<LearningContract> contract = new MutableLiveData<>();
    private final MutableLiveData<Exchange> exchange = new MutableLiveData<>();
    private final MutableLiveData<Resource<LearningContract>> saveState = new MutableLiveData<>();
    private final MutableLiveData<Resource<LearningContract>> acceptState = new MutableLiveData<>();

    private ListenerRegistration contractReg;

    public LiveData<LearningContract> contract() {
        return contract;
    }

    public LiveData<Exchange> exchange() {
        return exchange;
    }

    public LiveData<Resource<LearningContract>> saveState() {
        return saveState;
    }

    public LiveData<Resource<LearningContract>> acceptState() {
        return acceptState;
    }

    public void load(final String exchangeId) {
        ExchangeRepository.get().fetchById(exchangeId, new RepoCallback<Exchange>() {
            @Override
            public void onSuccess(Exchange data) {
                exchange.postValue(data);
            }

            @Override
            public void onError(String message) {
            }
        });

        if (contractReg != null) contractReg.remove();
        contractReg = repository.listen(exchangeId, new RepoCallback<LearningContract>() {
            @Override
            public void onSuccess(LearningContract data) {
                contract.postValue(data);
            }

            @Override
            public void onError(String message) {
            }
        });
    }

    public void save(LearningContract draft) {
        Exchange ex = exchange.getValue();
        if (ex == null) {
            saveState.setValue(Resource.<LearningContract>error("Intercambio no disponible"));
            return;
        }
        saveState.setValue(Resource.<LearningContract>loading());
        repository.save(ex, FirebaseManager.uid(), draft, new RepoCallback<LearningContract>() {
            @Override
            public void onSuccess(LearningContract data) {
                saveState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                saveState.postValue(Resource.<LearningContract>error(message));
            }
        });
    }

    public void accept() {
        LearningContract c = contract.getValue();
        if (c == null) {
            acceptState.setValue(Resource.<LearningContract>error("Aún no hay un contrato"));
            return;
        }
        acceptState.setValue(Resource.<LearningContract>loading());
        repository.accept(c, FirebaseManager.uid(), new RepoCallback<LearningContract>() {
            @Override
            public void onSuccess(LearningContract data) {
                acceptState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                acceptState.postValue(Resource.<LearningContract>error(message));
            }
        });
    }

    @Override
    protected void onCleared() {
        super.onCleared();
        if (contractReg != null) contractReg.remove();
    }
}
