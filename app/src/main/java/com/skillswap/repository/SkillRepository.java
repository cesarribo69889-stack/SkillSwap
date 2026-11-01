package com.skillswap.repository;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.firestore.WriteBatch;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.firebase.FirestoreCollections;
import com.skillswap.model.Skill;
import com.skillswap.model.User;
import com.skillswap.model.UserSkill;
import com.skillswap.utils.SkillCatalog;

import java.util.ArrayList;
import java.util.List;

/**
 * Coleccion "skills": catalogo global.
 * Las habilidades de cada usuario viven embebidas en su documento
 * (teachSkills / learnSkills) y se gestionan aqui mismo.
 */
public class SkillRepository {

    private static SkillRepository instance;

    public static synchronized SkillRepository get() {
        if (instance == null) instance = new SkillRepository();
        return instance;
    }

    private SkillRepository() {
    }

    /** Lee el catalogo remoto; si esta vacio usa el catalogo local. */
    public void fetchCatalog(final RepoCallback<List<Skill>> callback) {
        FirestoreCollections.skills().get()
                .addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<QuerySnapshot> task) {
                        List<Skill> skills = new ArrayList<>();
                        if (task.isSuccessful() && task.getResult() != null) {
                            for (QueryDocumentSnapshot doc : task.getResult()) {
                                Skill s = doc.toObject(Skill.class);
                                s.setId(doc.getId());
                                skills.add(s);
                            }
                        }
                        if (skills.isEmpty()) skills = SkillCatalog.getAllSkills();
                        callback.onSuccess(skills);
                    }
                });
    }

    /** Publica el catalogo local en Firestore (se ejecuta una sola vez). */
    public void seedCatalog(final RepoCallback<Boolean> callback) {
        FirestoreCollections.skills().limit(1).get()
                .addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<QuerySnapshot> task) {
                        if (!task.isSuccessful() || task.getResult() == null) {
                            if (callback != null) callback.onError("No se pudo leer el catálogo");
                            return;
                        }
                        if (!task.getResult().isEmpty()) {
                            if (callback != null) callback.onSuccess(Boolean.FALSE);
                            return;
                        }
                        WriteBatch batch = FirebaseManager.db().batch();
                        for (Skill s : SkillCatalog.getAllSkills()) {
                            batch.set(FirestoreCollections.skills().document(s.getId()), s);
                        }
                        batch.commit().addOnCompleteListener(new OnCompleteListener<Void>() {
                            @Override
                            public void onComplete(@NonNull Task<Void> t) {
                                if (callback == null) return;
                                if (t.isSuccessful()) callback.onSuccess(Boolean.TRUE);
                                else callback.onError(FirebaseErrors.translate(t.getException()));
                            }
                        });
                    }
                });
    }

    /** Agrega una habilidad al usuario. */
    public void addSkill(User user, UserSkill skill, RepoCallback<Boolean> callback) {
        if (user == null) {
            callback.onError("Perfil no disponible");
            return;
        }
        List<UserSkill> teach = new ArrayList<>(user.getTeachSkills());
        List<UserSkill> learn = new ArrayList<>(user.getLearnSkills());
        List<UserSkill> target = skill.isTeach() ? teach : learn;

        for (UserSkill s : target) {
            if (s.getKey().equals(skill.getKey())) {
                callback.onError("Ya tienes esa habilidad registrada");
                return;
            }
        }
        target.add(skill);
        UserRepository.get().saveSkills(user.getUid(), teach, learn, callback);
    }

    /** Edita el nivel o la nota de una habilidad existente. */
    public void updateSkill(User user, UserSkill skill, RepoCallback<Boolean> callback) {
        if (user == null) {
            callback.onError("Perfil no disponible");
            return;
        }
        List<UserSkill> teach = new ArrayList<>(user.getTeachSkills());
        List<UserSkill> learn = new ArrayList<>(user.getLearnSkills());
        List<UserSkill> target = skill.isTeach() ? teach : learn;

        boolean found = false;
        for (int i = 0; i < target.size(); i++) {
            if (target.get(i).getKey().equals(skill.getKey())) {
                target.set(i, skill);
                found = true;
                break;
            }
        }
        if (!found) {
            callback.onError("La habilidad ya no existe");
            return;
        }
        UserRepository.get().saveSkills(user.getUid(), teach, learn, callback);
    }

    /** Elimina una habilidad del usuario. */
    public void removeSkill(User user, UserSkill skill, RepoCallback<Boolean> callback) {
        if (user == null) {
            callback.onError("Perfil no disponible");
            return;
        }
        List<UserSkill> teach = new ArrayList<>(user.getTeachSkills());
        List<UserSkill> learn = new ArrayList<>(user.getLearnSkills());
        List<UserSkill> target = skill.isTeach() ? teach : learn;

        for (int i = 0; i < target.size(); i++) {
            if (target.get(i).getKey().equals(skill.getKey())) {
                target.remove(i);
                break;
            }
        }
        UserRepository.get().saveSkills(user.getUid(), teach, learn, callback);
    }
}
