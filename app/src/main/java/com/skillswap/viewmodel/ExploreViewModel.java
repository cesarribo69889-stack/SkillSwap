package com.skillswap.viewmodel;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.skillswap.model.ExploreFilter;
import com.skillswap.SkillSwapApp;
import com.skillswap.local.LocalCache;
import com.skillswap.model.MatchResult;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.repository.MatchRepository;
import com.skillswap.repository.RepoCallback;
import com.skillswap.repository.SafetyRepository;
import com.skillswap.repository.UserRepository;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

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
            public void onSuccess(final List<MatchResult> data) {
                // Quien yo bloquee no aparece en Explorar.
                SafetyRepository.get().fetchBlockedIds(new RepoCallback<Set<String>>() {
                    @Override
                    public void onSuccess(Set<String> bloqueados) {
                        allMatches = SafetyRepository.sinBloqueados(data, bloqueados);
                        applyCurrentFilter();
                        // RC1: se guarda lo ultimo mostrado para poder consultarlo
                        // sin conexion la proxima vez que se abra Explorar.
                        LocalCache.guardarCoincidencias(SkillSwapApp.contexto(), allMatches);
                    }

                    @Override
                    public void onError(String message) {
                        allMatches = data;
                        applyCurrentFilter();
                    }
                });
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
