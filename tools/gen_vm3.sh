#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
V="$J/viewmodel"
mkdir -p "$V"

# ============================================================ RatingViewModel
cat > "$V/RatingViewModel.java" <<'EOF'
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
EOF

# ============================================================ NotificationsViewModel
cat > "$V/NotificationsViewModel.java" <<'EOF'
package com.skillswap.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.google.firebase.firestore.ListenerRegistration;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.AppNotification;
import com.skillswap.repository.NotificationRepository;
import com.skillswap.repository.RepoCallback;

import java.util.ArrayList;
import java.util.List;

/** ViewModel del centro interno de notificaciones. */
public class NotificationsViewModel extends ViewModel {

    private final NotificationRepository repository = NotificationRepository.get();

    private final MutableLiveData<List<AppNotification>> notifications =
            new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<Integer> unread = new MutableLiveData<>(0);
    private final MutableLiveData<Boolean> loading = new MutableLiveData<>(true);

    private ListenerRegistration reg;

    public LiveData<List<AppNotification>> notifications() {
        return notifications;
    }

    public LiveData<Integer> unread() {
        return unread;
    }

    public LiveData<Boolean> loading() {
        return loading;
    }

    public void start() {
        String uid = FirebaseManager.uid();
        if (uid.isEmpty() || reg != null) return;
        reg = repository.listen(uid, new RepoCallback<List<AppNotification>>() {
            @Override
            public void onSuccess(List<AppNotification> data) {
                notifications.postValue(data);
                int count = 0;
                for (AppNotification n : data) if (!n.isRead()) count++;
                unread.postValue(count);
                loading.postValue(false);
            }

            @Override
            public void onError(String message) {
                loading.postValue(false);
            }
        });
    }

    public void markRead(AppNotification notification) {
        repository.markRead(notification.getId());
    }

    public void markAllRead() {
        repository.markAllRead(notifications.getValue());
    }

    @Override
    protected void onCleared() {
        super.onCleared();
        if (reg != null) reg.remove();
    }
}
EOF

# ============================================================ PassportViewModel
cat > "$V/PassportViewModel.java" <<'EOF'
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
EOF

# ============================================================ ContractViewModel
cat > "$V/ContractViewModel.java" <<'EOF'
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
EOF

# ============================================================ ChallengesViewModel
cat > "$V/ChallengesViewModel.java" <<'EOF'
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
EOF

# ============================================================ EvidenceViewModel
cat > "$V/EvidenceViewModel.java" <<'EOF'
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

    public void submit(LearningEvidence evidence, Uri fileUri) {
        Exchange ex = exchange.getValue();
        if (ex == null) {
            submitState.setValue(Resource.<LearningEvidence>error("Intercambio no disponible"));
            return;
        }
        submitState.setValue(Resource.<LearningEvidence>loading());
        EvidenceRepository.get().submit(ex, FirebaseManager.uid(), evidence, fileUri,
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
EOF

echo "ViewModels (ratings/notif/pasaporte/contratos/retos/evidencia) generados."
