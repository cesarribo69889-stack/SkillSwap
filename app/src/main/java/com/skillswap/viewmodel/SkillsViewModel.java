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
