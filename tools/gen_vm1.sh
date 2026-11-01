#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
V="$J/viewmodel"
mkdir -p "$V"

# ============================================================ AuthViewModel
cat > "$V/AuthViewModel.java" <<'EOF'
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
EOF

# ============================================================ ProfileViewModel
cat > "$V/ProfileViewModel.java" <<'EOF'
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

    public void uploadPhoto(String uid, Uri uri) {
        photoState.setValue(Resource.<String>loading());
        userRepository.uploadPhoto(uid, uri, new RepoCallback<String>() {
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
EOF

# ============================================================ SkillsViewModel
cat > "$V/SkillsViewModel.java" <<'EOF'
package com.skillswap.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.skillswap.model.Resource;
import com.skillswap.model.Skill;
import com.skillswap.model.User;
import com.skillswap.model.UserSkill;
import com.skillswap.repository.RepoCallback;
import com.skillswap.repository.SkillRepository;
import com.skillswap.repository.UserRepository;
import com.skillswap.utils.SkillCatalog;

import java.util.List;

/** ViewModel de gestion de habilidades (agregar / editar / eliminar). */
public class SkillsViewModel extends ViewModel {

    private final SkillRepository skillRepository = SkillRepository.get();

    private final MutableLiveData<List<Skill>> catalog = new MutableLiveData<>();
    private final MutableLiveData<Resource<Boolean>> operation = new MutableLiveData<>();

    public LiveData<User> currentUser() {
        return UserRepository.get().currentUser();
    }

    public LiveData<List<Skill>> catalog() {
        return catalog;
    }

    public LiveData<Resource<Boolean>> operation() {
        return operation;
    }

    public void loadCatalog() {
        catalog.setValue(SkillCatalog.getAllSkills());
        skillRepository.fetchCatalog(new RepoCallback<List<Skill>>() {
            @Override
            public void onSuccess(List<Skill> data) {
                catalog.postValue(data);
            }

            @Override
            public void onError(String message) {
            }
        });
    }

    public void addSkill(User user, UserSkill skill) {
        operation.setValue(Resource.<Boolean>loading());
        skillRepository.addSkill(user, skill, wrap());
    }

    public void updateSkill(User user, UserSkill skill) {
        operation.setValue(Resource.<Boolean>loading());
        skillRepository.updateSkill(user, skill, wrap());
    }

    public void removeSkill(User user, UserSkill skill) {
        operation.setValue(Resource.<Boolean>loading());
        skillRepository.removeSkill(user, skill, wrap());
    }

    private RepoCallback<Boolean> wrap() {
        return new RepoCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean data) {
                operation.postValue(Resource.success(data));
            }

            @Override
            public void onError(String message) {
                operation.postValue(Resource.<Boolean>error(message));
            }
        };
    }
}
EOF

# ============================================================ ExploreViewModel
cat > "$V/ExploreViewModel.java" <<'EOF'
package com.skillswap.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.skillswap.model.ExploreFilter;
import com.skillswap.model.MatchResult;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.repository.MatchRepository;
import com.skillswap.repository.RepoCallback;
import com.skillswap.repository.UserRepository;

import java.util.ArrayList;
import java.util.List;

/** ViewModel de la pantalla Explorar (SkillMatch + filtros). */
public class ExploreViewModel extends ViewModel {

    private final MatchRepository matchRepository = MatchRepository.get();

    private final MutableLiveData<Resource<List<MatchResult>>> results = new MutableLiveData<>();
    private final MutableLiveData<ExploreFilter> filter = new MutableLiveData<>(new ExploreFilter());
    private List<MatchResult> allMatches = new ArrayList<>();

    public LiveData<Resource<List<MatchResult>>> results() {
        return results;
    }

    public LiveData<ExploreFilter> filter() {
        return filter;
    }

    public ExploreFilter currentFilter() {
        ExploreFilter f = filter.getValue();
        return f == null ? new ExploreFilter() : f;
    }

    public void load() {
        User me = UserRepository.get().currentUserValue();
        if (me == null) {
            UserRepository.get().fetchUser(
                    com.skillswap.firebase.FirebaseManager.uid(),
                    new RepoCallback<User>() {
                        @Override
                        public void onSuccess(User data) {
                            fetchFor(data);
                        }

                        @Override
                        public void onError(String message) {
                            results.postValue(Resource.<List<MatchResult>>error(message));
                        }
                    });
            return;
        }
        fetchFor(me);
    }

    private void fetchFor(final User me) {
        results.postValue(Resource.<List<MatchResult>>loading());
        matchRepository.findMatches(me, new RepoCallback<List<MatchResult>>() {
            @Override
            public void onSuccess(List<MatchResult> data) {
                allMatches = data;
                applyCurrentFilter();
            }

            @Override
            public void onError(String message) {
                results.postValue(Resource.<List<MatchResult>>error(message));
            }
        });
    }

    public void setQuery(String query) {
        ExploreFilter f = currentFilter();
        f.setQuery(query);
        filter.setValue(f);
        applyCurrentFilter();
    }

    public void applyFilter(ExploreFilter newFilter) {
        filter.setValue(newFilter);
        applyCurrentFilter();
    }

    public void clearFilters() {
        ExploreFilter f = currentFilter();
        f.clearFilters();
        filter.setValue(f);
        applyCurrentFilter();
    }

    private void applyCurrentFilter() {
        List<MatchResult> filtered = MatchRepository.applyFilters(allMatches, currentFilter());
        results.postValue(Resource.success(filtered));
    }
}
EOF

# ============================================================ HomeViewModel
cat > "$V/HomeViewModel.java" <<'EOF'
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
EOF

echo "ViewModels (auth/perfil/skills/explorar/home) generados."
