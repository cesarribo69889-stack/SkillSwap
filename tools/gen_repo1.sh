#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
R="$J/repository"
mkdir -p "$R"

# ============================================================ RepoCallback
cat > "$R/RepoCallback.java" <<'EOF'
package com.skillswap.repository;

/** Callback generico usado por los repositorios. */
public interface RepoCallback<T> {

    void onSuccess(T data);

    void onError(String message);
}
EOF

# ============================================================ FirebaseErrors
cat > "$R/FirebaseErrors.java" <<'EOF'
package com.skillswap.repository;

import com.google.firebase.auth.FirebaseAuthInvalidCredentialsException;
import com.google.firebase.auth.FirebaseAuthInvalidUserException;
import com.google.firebase.auth.FirebaseAuthUserCollisionException;
import com.google.firebase.auth.FirebaseAuthWeakPasswordException;

/** Traduce los errores de Firebase a mensajes en espanol. */
public final class FirebaseErrors {

    private FirebaseErrors() {
    }

    public static String translate(Exception e) {
        if (e == null) return "Ocurrió un error inesperado";
        if (e instanceof FirebaseAuthWeakPasswordException) {
            return "La contraseña es demasiado débil";
        }
        if (e instanceof FirebaseAuthUserCollisionException) {
            return "Ya existe una cuenta con ese correo";
        }
        if (e instanceof FirebaseAuthInvalidCredentialsException) {
            return "Correo o contraseña incorrectos";
        }
        if (e instanceof FirebaseAuthInvalidUserException) {
            return "No encontramos una cuenta con ese correo";
        }
        String msg = e.getMessage();
        if (msg == null || msg.isEmpty()) return "Ocurrió un error inesperado";
        if (msg.contains("network") || msg.contains("Network")) {
            return "Sin conexión a internet. Inténtalo de nuevo";
        }
        if (msg.contains("PERMISSION_DENIED")) {
            return "No tienes permisos para realizar esta acción";
        }
        if (msg.contains("FAILED_PRECONDITION") && msg.contains("index")) {
            return "Falta crear un índice en Firestore. Revisa el enlace en Logcat";
        }
        return msg;
    }
}
EOF

# ============================================================ AuthRepository
cat > "$R/AuthRepository.java" <<'EOF'
package com.skillswap.repository;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseUser;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.User;
import com.skillswap.utils.GamificationEngine;
import com.skillswap.utils.Validators;

/** Autenticacion con Firebase Authentication. */
public class AuthRepository {

    private static AuthRepository instance;

    public static synchronized AuthRepository get() {
        if (instance == null) instance = new AuthRepository();
        return instance;
    }

    private AuthRepository() {
    }

    public boolean isLogged() {
        return FirebaseManager.isLogged();
    }

    public String currentUid() {
        return FirebaseManager.uid();
    }

    /** Registro con correo y contrasena + creacion del documento de usuario. */
    public void register(final String firstName, final String lastName,
                         final String email, final String password,
                         final RepoCallback<User> callback) {

        String err = Validators.validateEmail(email);
        if (err == null) err = Validators.validatePassword(password);
        if (err != null) {
            callback.onError(err);
            return;
        }

        FirebaseManager.auth()
                .createUserWithEmailAndPassword(email.trim(), password)
                .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        if (!task.isSuccessful()) {
                            callback.onError(FirebaseErrors.translate(task.getException()));
                            return;
                        }
                        FirebaseUser fu = FirebaseManager.currentUser();
                        if (fu == null) {
                            callback.onError("No se pudo crear la cuenta");
                            return;
                        }
                        User user = new User(fu.getUid(), firstName.trim(), lastName.trim(), email.trim());
                        user.setGamificationLevel(GamificationEngine.LEVEL_BEGINNER);
                        UserRepository.get().createUser(user, callback);
                    }
                });
    }

    public void login(final String email, final String password, final RepoCallback<User> callback) {
        String err = Validators.validateEmail(email);
        if (err != null) {
            callback.onError(err);
            return;
        }
        if (Validators.isEmpty(password)) {
            callback.onError("La contraseña es obligatoria");
            return;
        }

        FirebaseManager.auth()
                .signInWithEmailAndPassword(email.trim(), password)
                .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        if (!task.isSuccessful()) {
                            callback.onError(FirebaseErrors.translate(task.getException()));
                            return;
                        }
                        UserRepository.get().fetchUser(FirebaseManager.uid(), callback);
                    }
                });
    }

    public void resetPassword(final String email, final RepoCallback<Boolean> callback) {
        String err = Validators.validateEmail(email);
        if (err != null) {
            callback.onError(err);
            return;
        }
        FirebaseManager.auth()
                .sendPasswordResetEmail(email.trim())
                .addOnCompleteListener(new OnCompleteListener<Void>() {
                    @Override
                    public void onComplete(@NonNull Task<Void> task) {
                        if (task.isSuccessful()) {
                            callback.onSuccess(Boolean.TRUE);
                        } else {
                            callback.onError(FirebaseErrors.translate(task.getException()));
                        }
                    }
                });
    }

    public void logout() {
        UserRepository.get().clearCache();
        FirebaseManager.auth().signOut();
    }
}
EOF

# ============================================================ UserRepository
cat > "$R/UserRepository.java" <<'EOF'
package com.skillswap.repository;

import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;

import com.google.android.gms.tasks.Continuation;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.ListenerRegistration;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.firebase.FirestoreCollections;
import com.skillswap.model.User;
import com.skillswap.model.UserSkill;
import com.skillswap.utils.Constants;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

/** Acceso a la coleccion "users". */
public class UserRepository {

    private static UserRepository instance;

    private final MutableLiveData<User> currentUser = new MutableLiveData<>();
    private ListenerRegistration currentUserListener;

    public static synchronized UserRepository get() {
        if (instance == null) instance = new UserRepository();
        return instance;
    }

    private UserRepository() {
    }

    /** Usuario autenticado, observable. */
    public LiveData<User> currentUser() {
        return currentUser;
    }

    @Nullable
    public User currentUserValue() {
        return currentUser.getValue();
    }

    /** Se suscribe en tiempo real al documento del usuario autenticado. */
    public void listenCurrentUser() {
        String uid = FirebaseManager.uid();
        if (uid.isEmpty()) return;
        detachCurrentUser();
        currentUserListener = FirestoreCollections.user(uid)
                .addSnapshotListener(new EventListener<DocumentSnapshot>() {
                    @Override
                    public void onEvent(@Nullable DocumentSnapshot snapshot,
                                        @Nullable FirebaseFirestoreException e) {
                        if (e != null || snapshot == null || !snapshot.exists()) return;
                        User u = snapshot.toObject(User.class);
                        if (u != null) {
                            u.setUid(snapshot.getId());
                            currentUser.postValue(u);
                        }
                    }
                });
    }

    public void detachCurrentUser() {
        if (currentUserListener != null) {
            currentUserListener.remove();
            currentUserListener = null;
        }
    }

    public void clearCache() {
        detachCurrentUser();
        currentUser.postValue(null);
    }

    public void createUser(final User user, final RepoCallback<User> callback) {
        user.setSearchKeywords(buildKeywords(user));
        user.setUpdatedAt(System.currentTimeMillis());
        if (user.getCreatedAt() == 0) user.setCreatedAt(user.getUpdatedAt());

        FirestoreCollections.user(user.getUid())
                .set(user)
                .addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void unused) {
                        currentUser.postValue(user);
                        GamificationRepository.get().ensureAccount(user.getUid());
                        callback.onSuccess(user);
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        callback.onError(FirebaseErrors.translate(e));
                    }
                });
    }

    public void fetchUser(final String uid, final RepoCallback<User> callback) {
        if (uid == null || uid.isEmpty()) {
            callback.onError("Usuario no válido");
            return;
        }
        FirestoreCollections.user(uid).get()
                .addOnCompleteListener(new OnCompleteListener<DocumentSnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<DocumentSnapshot> task) {
                        if (!task.isSuccessful() || task.getResult() == null || !task.getResult().exists()) {
                            callback.onError("No encontramos el perfil del estudiante");
                            return;
                        }
                        User u = task.getResult().toObject(User.class);
                        if (u == null) {
                            callback.onError("No se pudo leer el perfil");
                            return;
                        }
                        u.setUid(task.getResult().getId());
                        if (uid.equals(FirebaseManager.uid())) currentUser.postValue(u);
                        callback.onSuccess(u);
                    }
                });
    }

    /** Actualiza campos del perfil. */
    public void updateProfile(final User user, final RepoCallback<User> callback) {
        Map<String, Object> data = new HashMap<>();
        data.put("firstName", user.getFirstName());
        data.put("lastName", user.getLastName());
        data.put("university", user.getUniversity());
        data.put("career", user.getCareer());
        data.put("cycle", user.getCycle());
        data.put("description", user.getDescription());
        data.put("modality", user.getModality());
        data.put("availability", user.getAvailability());
        data.put("photoUrl", user.getPhotoUrl());
        data.put("searchKeywords", buildKeywords(user));
        data.put("profileCompleted", isProfileComplete(user));
        data.put("updatedAt", System.currentTimeMillis());

        FirestoreCollections.user(user.getUid())
                .set(data, com.google.firebase.firestore.SetOptions.merge())
                .addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void unused) {
                        user.setProfileCompleted(isProfileComplete(user));
                        currentUser.postValue(user);
                        callback.onSuccess(user);
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        callback.onError(FirebaseErrors.translate(e));
                    }
                });
    }

    /** Sube la foto de perfil a Firebase Storage y devuelve la URL. */
    public void uploadPhoto(final String uid, Uri uri, final RepoCallback<String> callback) {
        if (uri == null) {
            callback.onError("Selecciona una imagen");
            return;
        }
        final StorageReference ref = FirebaseManager.storage().getReference()
                .child(Constants.STORAGE_AVATARS)
                .child(uid + ".jpg");

        ref.putFile(uri).continueWithTask(new Continuation<UploadTask.TaskSnapshot, Task<Uri>>() {
            @Override
            public Task<Uri> then(@NonNull Task<UploadTask.TaskSnapshot> task) throws Exception {
                if (!task.isSuccessful() && task.getException() != null) {
                    throw task.getException();
                }
                return ref.getDownloadUrl();
            }
        }).addOnCompleteListener(new OnCompleteListener<Uri>() {
            @Override
            public void onComplete(@NonNull Task<Uri> task) {
                if (!task.isSuccessful() || task.getResult() == null) {
                    callback.onError(FirebaseErrors.translate(task.getException()));
                    return;
                }
                final String url = task.getResult().toString();
                FirestoreCollections.user(uid).update("photoUrl", url);
                callback.onSuccess(url);
            }
        });
    }

    /** Guarda el arreglo de habilidades (ensena / aprende). */
    public void saveSkills(final String uid, final List<UserSkill> teach,
                           final List<UserSkill> learn, final RepoCallback<Boolean> callback) {
        Map<String, Object> data = new HashMap<>();
        data.put("teachSkills", teach);
        data.put("learnSkills", learn);
        data.put("teachSkillKeys", keysOf(teach));
        data.put("learnSkillKeys", keysOf(learn));
        data.put("updatedAt", System.currentTimeMillis());

        FirestoreCollections.user(uid)
                .set(data, com.google.firebase.firestore.SetOptions.merge())
                .addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void unused) {
                        User u = currentUser.getValue();
                        if (u != null) {
                            u.setTeachSkills(teach);
                            u.setLearnSkills(learn);
                            u.setTeachSkillKeys(keysOf(teach));
                            u.setLearnSkillKeys(keysOf(learn));
                            currentUser.postValue(u);
                        }
                        callback.onSuccess(Boolean.TRUE);
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        callback.onError(FirebaseErrors.translate(e));
                    }
                });
    }

    /** Trae candidatos para Explorar / SkillMatch. */
    public void fetchCandidates(final String excludeUid, final RepoCallback<List<User>> callback) {
        Query q = FirestoreCollections.users()
                .whereEqualTo("active", true)
                .limit(Constants.EXPLORE_PAGE_SIZE);

        q.get().addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
            @Override
            public void onComplete(@NonNull Task<QuerySnapshot> task) {
                if (!task.isSuccessful() || task.getResult() == null) {
                    callback.onError(FirebaseErrors.translate(task.getException()));
                    return;
                }
                List<User> users = new ArrayList<>();
                for (QueryDocumentSnapshot doc : task.getResult()) {
                    User u = doc.toObject(User.class);
                    u.setUid(doc.getId());
                    if (excludeUid != null && excludeUid.equals(u.getUid())) continue;
                    users.add(u);
                }
                callback.onSuccess(users);
            }
        });
    }

    /** Busca estudiantes que ensenan una habilidad concreta. */
    public void fetchBySkillTaught(final String skillName, final String excludeUid,
                                   final RepoCallback<List<User>> callback) {
        String key = skillName == null ? "" : skillName.toLowerCase(Locale.ROOT).trim();
        FirestoreCollections.users()
                .whereArrayContains("teachSkillKeys", key)
                .limit(Constants.EXPLORE_PAGE_SIZE)
                .get()
                .addOnCompleteListener(new OnCompleteListener<QuerySnapshot>() {
                    @Override
                    public void onComplete(@NonNull Task<QuerySnapshot> task) {
                        if (!task.isSuccessful() || task.getResult() == null) {
                            callback.onError(FirebaseErrors.translate(task.getException()));
                            return;
                        }
                        List<User> users = new ArrayList<>();
                        for (QueryDocumentSnapshot doc : task.getResult()) {
                            User u = doc.toObject(User.class);
                            u.setUid(doc.getId());
                            if (excludeUid != null && excludeUid.equals(u.getUid())) continue;
                            users.add(u);
                        }
                        callback.onSuccess(users);
                    }
                });
    }

    public void updateFcmToken(String uid, String token) {
        if (uid == null || uid.isEmpty() || token == null) return;
        FirestoreCollections.user(uid).update("fcmToken", token);
    }

    /** Aplica una nueva calificacion al promedio de reputacion. */
    public void applyRating(final String uid, final float newStars, final RepoCallback<Boolean> callback) {
        final com.google.firebase.firestore.DocumentReference ref = FirestoreCollections.user(uid);
        FirebaseManager.db().runTransaction(new com.google.firebase.firestore.Transaction.Function<Void>() {
            @Override
            public Void apply(@NonNull com.google.firebase.firestore.Transaction transaction) {
                DocumentSnapshot snap = transaction.get(ref);
                double reputation = snap.contains("reputation") && snap.getDouble("reputation") != null
                        ? snap.getDouble("reputation") : 0d;
                long total = snap.contains("totalRatings") && snap.getLong("totalRatings") != null
                        ? snap.getLong("totalRatings") : 0L;
                double newAvg = ((reputation * total) + newStars) / (total + 1);
                transaction.update(ref, "reputation", Math.round(newAvg * 100d) / 100d);
                transaction.update(ref, "totalRatings", total + 1);
                return null;
            }
        }).addOnCompleteListener(new OnCompleteListener<Void>() {
            @Override
            public void onComplete(@NonNull Task<Void> task) {
                if (task.isSuccessful()) callback.onSuccess(Boolean.TRUE);
                else callback.onError(FirebaseErrors.translate(task.getException()));
            }
        });
    }

    public void incrementExchanges(String uid) {
        if (uid == null || uid.isEmpty()) return;
        FirestoreCollections.user(uid).update("exchangesCount", FieldValue.increment(1));
    }

    // ---------------------------------------------------------- helpers

    public static boolean isProfileComplete(User u) {
        return u != null
                && !isBlank(u.getUniversity())
                && !isBlank(u.getCareer())
                && !isBlank(u.getModality())
                && !u.getTeachSkills().isEmpty()
                && !u.getLearnSkills().isEmpty();
    }

    public static List<String> keysOf(List<UserSkill> skills) {
        List<String> keys = new ArrayList<>();
        if (skills == null) return keys;
        for (UserSkill s : skills) {
            if (s != null && !s.getKey().isEmpty()) keys.add(s.getKey());
        }
        return keys;
    }

    private static List<String> buildKeywords(User u) {
        Set<String> set = new HashSet<>();
        addTokens(set, u.getFirstName());
        addTokens(set, u.getLastName());
        addTokens(set, u.getCareer());
        addTokens(set, u.getUniversity());
        return new ArrayList<>(set);
    }

    private static void addTokens(Set<String> set, String value) {
        if (value == null) return;
        for (String token : value.toLowerCase(Locale.ROOT).trim().split("\\s+")) {
            if (token.length() >= 2) set.add(token);
        }
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
EOF

# ============================================================ SkillRepository
cat > "$R/SkillRepository.java" <<'EOF'
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
EOF

echo "Repositorios (auth/user/skill) generados."
