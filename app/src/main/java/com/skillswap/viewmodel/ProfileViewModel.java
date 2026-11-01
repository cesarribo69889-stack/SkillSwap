package com.skillswap.viewmodel;

import android.net.Uri;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.skillswap.model.Rating;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.repository.RatingRepository;
import com.skillswap.repository.RepoCallback;
import com.skillswap.repository.UserRepository;

import java.util.List;

/** ViewModel del perfil propio y del perfil de otros estudiantes. */
public class ProfileViewModel extends ViewModel {

    private final UserRepository userRepository = UserRepository.get();

    private final MutableLiveData<Resource<User>> profileState = new MutableLiveData<>();
    private final MutableLiveData<Resource<User>> saveState = new MutableLiveData<>();
    private final MutableLiveData<Resource<String>> photoState = new MutableLiveData<>();
    private final MutableLiveData<List<Rating>> ratings = new MutableLiveData<>();

    public LiveData<User> currentUser() {
        return userRepository.currentUser();
    }

    public LiveData<Resource<User>> profileState() {
        return profileState;
    }

    public LiveData<Resource<User>> saveState() {
        return saveState;
    }

    public LiveData<Resource<String>> photoState() {
        return photoState;
    }

    public LiveData<List<Rating>> ratings() {
        return ratings;
    }

    public void listenCurrentUser() {
        userRepository.listenCurrentUser();
    }

    public void loadProfile(String uid) {
        profileState.setValue(Resource.<User>loading());
        userRepository.fetchUser(uid, new RepoCallback<User>() {
            @Override
            public void onSuccess(User data) {
                profileState.postValue(Resource.success(data));
                loadRatings(data.getUid());
            }

            @Override
            public void onError(String message) {
                profileState.postValue(Resource.<User>error(message));
            }
        });
    }

    public void loadRatings(String uid) {
        RatingRepository.get().fetchReceived(uid, new RepoCallback<List<Rating>>() {
            @Override
            public void onSuccess(List<Rating> data) {
                ratings.postValue(data);
            }

            @Override
            public void onError(String message) {
            }
        });
    }

    public void saveProfile(User user) {
        saveState.setValue(Resource.<User>loading());
        userRepository.updateProfile(user, new RepoCallback<User>() {
            @Override
            public void onSuccess(User data) {
                saveState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                saveState.postValue(Resource.<User>error(message));
            }
        });
    }

    public void uploadPhoto(android.content.Context context, String uid, Uri uri) {
        photoState.setValue(Resource.<String>loading());
        userRepository.uploadPhoto(context, uid, uri, new RepoCallback<String>() {
            @Override
            public void onSuccess(String data) {
                photoState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                photoState.postValue(Resource.<String>error(message));
            }
        });
    }
}
