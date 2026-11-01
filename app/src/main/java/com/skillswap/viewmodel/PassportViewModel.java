package com.skillswap.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.google.firebase.firestore.ListenerRegistration;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Badge;
import com.skillswap.model.LearningEvidence;
import com.skillswap.model.PassportEntry;
import com.skillswap.model.PointEntry;
import com.skillswap.model.SkillPointsAccount;
import com.skillswap.repository.EvidenceRepository;
import com.skillswap.repository.GamificationRepository;
import com.skillswap.repository.PassportRepository;
import com.skillswap.repository.RepoCallback;

import java.util.ArrayList;
import java.util.List;

/** ViewModel del Pasaporte de Habilidades, SkillPoints e insignias. */
public class PassportViewModel extends ViewModel {

    private final MutableLiveData<List<PassportEntry>> entries = new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<List<Badge>> badges = new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<SkillPointsAccount> account = new MutableLiveData<>();
    private final MutableLiveData<List<PointEntry>> history = new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<List<LearningEvidence>> evidences = new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<Boolean> loading = new MutableLiveData<>(true);

    private ListenerRegistration passportReg;
    private ListenerRegistration badgesReg;
    private ListenerRegistration accountReg;

    public LiveData<List<PassportEntry>> entries() {
        return entries;
    }

    public LiveData<List<Badge>> badges() {
        return badges;
    }

    public LiveData<SkillPointsAccount> account() {
        return account;
    }

    public LiveData<List<PointEntry>> history() {
        return history;
    }

    public LiveData<List<LearningEvidence>> evidences() {
        return evidences;
    }

    public LiveData<Boolean> loading() {
        return loading;
    }

    public void start(String uid) {
        if (uid == null || uid.isEmpty()) uid = FirebaseManager.uid();
        if (uid.isEmpty()) return;

        if (passportReg == null) {
            passportReg = PassportRepository.get().listen(uid,
                    new RepoCallback<List<PassportEntry>>() {
                        @Override
                        public void onSuccess(List<PassportEntry> data) {
                            entries.postValue(data);
                            loading.postValue(false);
                        }

                        @Override
                        public void onError(String message) {
                            loading.postValue(false);
                        }
                    });
        }
        if (badgesReg == null) {
            badgesReg = GamificationRepository.get().listenBadges(uid, new RepoCallback<List<Badge>>() {
                @Override
                public void onSuccess(List<Badge> data) {
                    badges.postValue(data);
                }

                @Override
                public void onError(String message) {
                }
            });
        }
        if (accountReg == null) {
            accountReg = GamificationRepository.get().listenAccount(uid,
                    new RepoCallback<SkillPointsAccount>() {
                        @Override
                        public void onSuccess(SkillPointsAccount data) {
                            account.postValue(data);
                        }

                        @Override
                        public void onError(String message) {
                        }
                    });
        }

        GamificationRepository.get().fetchHistory(uid, new RepoCallback<List<PointEntry>>() {
            @Override
            public void onSuccess(List<PointEntry> data) {
                history.postValue(data);
            }

            @Override
            public void onError(String message) {
            }
        });

        EvidenceRepository.get().fetchByUser(uid, new RepoCallback<List<LearningEvidence>>() {
            @Override
            public void onSuccess(List<LearningEvidence> data) {
                evidences.postValue(data);
            }

            @Override
            public void onError(String message) {
            }
        });
    }

    @Override
    protected void onCleared() {
        super.onCleared();
        if (passportReg != null) passportReg.remove();
        if (badgesReg != null) badgesReg.remove();
        if (accountReg != null) accountReg.remove();
    }
}
