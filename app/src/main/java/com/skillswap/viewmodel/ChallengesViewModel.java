package com.skillswap.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.google.firebase.firestore.ListenerRegistration;
import com.skillswap.model.Challenge;
import com.skillswap.model.ChallengeParticipant;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.repository.ChallengeRepository;
import com.skillswap.repository.RepoCallback;
import com.skillswap.repository.UserRepository;

import java.util.ArrayList;
import java.util.List;

/** ViewModel de Skill Challenges (Innovacion 5). */
public class ChallengesViewModel extends ViewModel {

    private final ChallengeRepository repository = ChallengeRepository.get();

    private final MutableLiveData<List<Challenge>> challenges = new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<Challenge> detail = new MutableLiveData<>();
    private final MutableLiveData<List<ChallengeParticipant>> participants =
            new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<Resource<Challenge>> createState = new MutableLiveData<>();
    private final MutableLiveData<Resource<Boolean>> joinState = new MutableLiveData<>();
    private final MutableLiveData<Boolean> loading = new MutableLiveData<>(true);

    private ListenerRegistration listReg;
    private ListenerRegistration detailReg;
    private ListenerRegistration participantsReg;

    public LiveData<List<Challenge>> challenges() {
        return challenges;
    }

    public LiveData<Challenge> detail() {
        return detail;
    }

    public LiveData<List<ChallengeParticipant>> participants() {
        return participants;
    }

    public LiveData<Resource<Challenge>> createState() {
        return createState;
    }

    public LiveData<Resource<Boolean>> joinState() {
        return joinState;
    }

    public LiveData<Boolean> loading() {
        return loading;
    }

    public void start() {
        if (listReg != null) return;
        listReg = repository.listenAll(new RepoCallback<List<Challenge>>() {
            @Override
            public void onSuccess(List<Challenge> data) {
                challenges.postValue(data);
                loading.postValue(false);
            }

            @Override
            public void onError(String message) {
                loading.postValue(false);
            }
        });
    }

    public void observeDetail(String challengeId) {
        if (detailReg != null) detailReg.remove();
        detailReg = repository.listenById(challengeId, new RepoCallback<Challenge>() {
            @Override
            public void onSuccess(Challenge data) {
                detail.postValue(data);
            }

            @Override
            public void onError(String message) {
            }
        });

        if (participantsReg != null) participantsReg.remove();
        participantsReg = repository.listenParticipants(challengeId,
                new RepoCallback<List<ChallengeParticipant>>() {
                    @Override
                    public void onSuccess(List<ChallengeParticipant> data) {
                        participants.postValue(data);
                    }

                    @Override
                    public void onError(String message) {
                    }
                });
    }

    public void create(Challenge challenge) {
        User me = UserRepository.get().currentUserValue();
        createState.setValue(Resource.<Challenge>loading());
        repository.create(me, challenge, new RepoCallback<Challenge>() {
            @Override
            public void onSuccess(Challenge data) {
                createState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                createState.postValue(Resource.<Challenge>error(message));
            }
        });
    }

    public void requestJoin(Challenge challenge, String skill, String message) {
        User me = UserRepository.get().currentUserValue();
        joinState.setValue(Resource.<Boolean>loading());
        repository.requestJoin(challenge, me, skill, message, new RepoCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                joinState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String msg) {
                joinState.postValue(Resource.<Boolean>error(msg));
            }
        });
    }

    public void respond(Challenge challenge, ChallengeParticipant participant, boolean accept) {
        joinState.setValue(Resource.<Boolean>loading());
        repository.respond(challenge, participant, accept, new RepoCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                joinState.postValue(Resource.success(data));
            }

            @Override
            public void onError(String msg) {
                joinState.postValue(Resource.<Boolean>error(msg));
            }
        });
    }

    public void updateProgress(String challengeId, int progress) {
        repository.updateProgress(challengeId, progress, new RepoCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
            }

            @Override
            public void onError(String message) {
            }
        });
    }

    @Override
    protected void onCleared() {
        super.onCleared();
        if (listReg != null) listReg.remove();
        if (detailReg != null) detailReg.remove();
        if (participantsReg != null) participantsReg.remove();
    }
}
