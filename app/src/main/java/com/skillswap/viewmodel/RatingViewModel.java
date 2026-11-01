package com.skillswap.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Exchange;
import com.skillswap.model.Rating;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.repository.PassportRepository;
import com.skillswap.repository.RatingRepository;
import com.skillswap.repository.RepoCallback;
import com.skillswap.repository.UserRepository;

import java.util.ArrayList;
import java.util.List;

/** ViewModel de calificaciones e historial. */
public class RatingViewModel extends ViewModel {

    private final RatingRepository repository = RatingRepository.get();

    private final MutableLiveData<Resource<Rating>> submitState = new MutableLiveData<>();
    private final MutableLiveData<List<Rating>> received = new MutableLiveData<>(new ArrayList<>());

    public LiveData<Resource<Rating>> submitState() {
        return submitState;
    }

    public LiveData<List<Rating>> received() {
        return received;
    }

    public void submit(final Exchange exchange, Rating rating) {
        final User me = UserRepository.get().currentUserValue();
        submitState.setValue(Resource.<Rating>loading());
        repository.submit(me, exchange, rating, new RepoCallback<Rating>() {
            @Override
            public void onSuccess(Rating data) {
                PassportRepository.get().registerRating(
                        exchange.getPartnerId(FirebaseManager.uid()),
                        data.getSkillTaught(),
                        data.getOverall());
                submitState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                submitState.postValue(Resource.<Rating>error(message));
            }
        });
    }

    public void loadReceived(String uid) {
        repository.fetchReceived(uid, new RepoCallback<List<Rating>>() {
            @Override
            public void onSuccess(List<Rating> data) {
                received.postValue(data);
            }

            @Override
            public void onError(String message) {
            }
        });
    }
}
