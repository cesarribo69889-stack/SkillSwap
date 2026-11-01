package com.skillswap.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.google.firebase.firestore.ListenerRegistration;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.AppNotification;
import com.skillswap.model.Challenge;
import com.skillswap.model.Exchange;
import com.skillswap.model.MatchResult;
import com.skillswap.model.User;
import com.skillswap.repository.ChallengeRepository;
import com.skillswap.repository.ExchangeRepository;
import com.skillswap.repository.MatchRepository;
import com.skillswap.repository.NotificationRepository;
import com.skillswap.repository.RepoCallback;
import com.skillswap.repository.UserRepository;

import java.util.ArrayList;
import java.util.List;

/** ViewModel de la pantalla Inicio. */
public class HomeViewModel extends ViewModel {

    private final MutableLiveData<List<MatchResult>> topMatches = new MutableLiveData<>();
    private final MutableLiveData<List<Exchange>> activeExchanges = new MutableLiveData<>();
    private final MutableLiveData<List<Challenge>> challenges = new MutableLiveData<>();
    private final MutableLiveData<Integer> unreadNotifications = new MutableLiveData<>(0);
    private final MutableLiveData<Boolean> loading = new MutableLiveData<>(false);

    private ListenerRegistration exchangesReg;
    private ListenerRegistration challengesReg;
    private ListenerRegistration notificationsReg;

    public LiveData<User> currentUser() {
        return UserRepository.get().currentUser();
    }

    public LiveData<List<MatchResult>> topMatches() {
        return topMatches;
    }

    public LiveData<List<Exchange>> activeExchanges() {
        return activeExchanges;
    }

    public LiveData<List<Challenge>> challenges() {
        return challenges;
    }

    public LiveData<Integer> unreadNotifications() {
        return unreadNotifications;
    }

    public LiveData<Boolean> loading() {
        return loading;
    }

    public void start() {
        String uid = FirebaseManager.uid();
        if (uid.isEmpty()) return;

        UserRepository.get().listenCurrentUser();
        loadMatches();

        if (exchangesReg == null) {
            exchangesReg = ExchangeRepository.get().listenByUser(uid,
                    new RepoCallback<List<Exchange>>() {
                        @Override
                        public void onSuccess(List<Exchange> data) {
                            List<Exchange> active = new ArrayList<>();
                            for (Exchange e : data) {
                                if (Exchange.STATUS_UPCOMING.equals(e.getStatus())
                                        || Exchange.STATUS_IN_PROGRESS.equals(e.getStatus())) {
                                    active.add(e);
                                }
                            }
                            activeExchanges.postValue(active);
                        }

                        @Override
                        public void onError(String message) {
                        }
                    });
        }

        if (challengesReg == null) {
            challengesReg = ChallengeRepository.get().listenAll(new RepoCallback<List<Challenge>>() {
                @Override
                public void onSuccess(List<Challenge> data) {
                    List<Challenge> open = new ArrayList<>();
                    for (Challenge c : data) {
                        if (!Challenge.STATUS_FINISHED.equals(c.getStatus())) open.add(c);
                    }
                    challenges.postValue(open);
                }

                @Override
                public void onError(String message) {
                }
            });
        }

        if (notificationsReg == null) {
            notificationsReg = NotificationRepository.get().listen(uid,
                    new RepoCallback<List<AppNotification>>() {
                        @Override
                        public void onSuccess(List<AppNotification> data) {
                            int unread = 0;
                            for (AppNotification n : data) if (!n.isRead()) unread++;
                            unreadNotifications.postValue(unread);
                        }

                        @Override
                        public void onError(String message) {
                        }
                    });
        }
    }

    public void loadMatches() {
        User me = UserRepository.get().currentUserValue();
        if (me == null) return;
        loading.postValue(true);
        MatchRepository.get().findMatches(me, new RepoCallback<List<MatchResult>>() {
            @Override
            public void onSuccess(List<MatchResult> data) {
                List<MatchResult> top = data.size() > 6 ? new ArrayList<>(data.subList(0, 6)) : data;
                for (MatchResult m : top) MatchRepository.get().saveMatch(m);
                topMatches.postValue(top);
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
        if (exchangesReg != null) exchangesReg.remove();
        if (challengesReg != null) challengesReg.remove();
        if (notificationsReg != null) notificationsReg.remove();
    }
}
