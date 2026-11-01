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
