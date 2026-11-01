package com.skillswap.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.repository.AuthRepository;
import com.skillswap.repository.RepoCallback;
import com.skillswap.repository.UserRepository;

/** ViewModel de registro, inicio de sesion y recuperacion de contrasena. */
public class AuthViewModel extends ViewModel {

    private final AuthRepository authRepository = AuthRepository.get();
    private final MutableLiveData<Resource<User>> authState = new MutableLiveData<>();
    private final MutableLiveData<Resource<Boolean>> resetState = new MutableLiveData<>();

    public LiveData<Resource<User>> authState() {
        return authState;
    }

    public LiveData<Resource<Boolean>> resetState() {
        return resetState;
    }

    public boolean isLogged() {
        return authRepository.isLogged();
    }

    public void register(String firstName, String lastName, String email, String password) {
        authState.setValue(Resource.<User>loading());
        authRepository.register(firstName, lastName, email, password, new RepoCallback<User>() {
            @Override
            public void onSuccess(User data) {
                UserRepository.get().listenCurrentUser();
                authState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                authState.postValue(Resource.<User>error(message));
            }
        });
    }

    public void login(String email, String password) {
        authState.setValue(Resource.<User>loading());
        authRepository.login(email, password, new RepoCallback<User>() {
            @Override
            public void onSuccess(User data) {
                UserRepository.get().listenCurrentUser();
                authState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                authState.postValue(Resource.<User>error(message));
            }
        });
    }

    public void resetPassword(String email) {
        resetState.setValue(Resource.<Boolean>loading());
        authRepository.resetPassword(email, new RepoCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                resetState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                resetState.postValue(Resource.<Boolean>error(message));
            }
        });
    }

    public void logout() {
        authRepository.logout();
    }
}
