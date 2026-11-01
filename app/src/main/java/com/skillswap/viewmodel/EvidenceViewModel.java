package com.skillswap.viewmodel;

import android.net.Uri;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Exchange;
import com.skillswap.model.LearningEvidence;
import com.skillswap.model.Resource;
import com.skillswap.repository.EvidenceRepository;
import com.skillswap.repository.ExchangeRepository;
import com.skillswap.repository.RepoCallback;

/** ViewModel de la validacion practica del aprendizaje (Innovacion 6). */
public class EvidenceViewModel extends ViewModel {

    private final MutableLiveData<Exchange> exchange = new MutableLiveData<>();
    private final MutableLiveData<Resource<LearningEvidence>> submitState = new MutableLiveData<>();

    public LiveData<Exchange> exchange() {
        return exchange;
    }

    public LiveData<Resource<LearningEvidence>> submitState() {
        return submitState;
    }

    public void load(String exchangeId) {
        ExchangeRepository.get().fetchById(exchangeId, new RepoCallback<Exchange>() {
            @Override
            public void onSuccess(Exchange data) {
                exchange.postValue(data);
            }

            @Override
            public void onError(String message) {
            }
        });
    }

    public void submit(android.content.Context context, LearningEvidence evidence, Uri fileUri) {
        Exchange ex = exchange.getValue();
        if (ex == null) {
            submitState.setValue(Resource.<LearningEvidence>error("Intercambio no disponible"));
            return;
        }
        submitState.setValue(Resource.<LearningEvidence>loading());
        EvidenceRepository.get().submit(context, ex, FirebaseManager.uid(), evidence, fileUri,
                new RepoCallback<LearningEvidence>() {
                    @Override
                    public void onSuccess(LearningEvidence data) {
                        submitState.postValue(Resource.success(data));
                    }

                    @Override
                    public void onError(String message) {
                        submitState.postValue(Resource.<LearningEvidence>error(message));
                    }
                });
    }
}
