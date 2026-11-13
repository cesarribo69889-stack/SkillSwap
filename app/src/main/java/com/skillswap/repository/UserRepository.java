package com.skillswap.repository;

import android.content.Context;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;

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
import com.skillswap.SkillSwapApp;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.local.LocalCache;
import com.skillswap.firebase.FirestoreCollections;
import com.skillswap.model.User;
import com.skillswap.model.UserSkill;
import com.skillswap.utils.Constants;
import com.skillswap.utils.ImageUtils;

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
                            // RC1: copia local para poder abrir la app sin conexion.
                            LocalCache.guardarPerfil(SkillSwapApp.contexto(), u);
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
        // RC1: al cerrar sesion no debe quedar nada del usuario en el telefono.
        LocalCache.limpiar(SkillSwapApp.contexto());
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

    /**
     * RC4 - Guarda la ubicacion aproximada del estudiante.
     *
     * Llega ya redondeada desde LocationHelper, asi que aqui no se escribe
     * nunca la posicion exacta.
     */
    public void updateLocation(final double lat, final double lon,
                               final RepoCallback<Boolean> callback) {
        String uid = FirebaseManager.uid();
        if (uid == null || uid.isEmpty()) {
            callback.onError("Sesión no válida");
            return;
        }
        Map<String, Object> data = new HashMap<>();
        data.put("lat", lat);
        data.put("lon", lon);
        data.put("updatedAt", System.currentTimeMillis());

        FirestoreCollections.user(uid)
                .set(data, com.google.firebase.firestore.SetOptions.merge())
                .addOnSuccessListener(unused -> {
                    User actual = currentUser.getValue();
                    if (actual != null) {
                        actual.setLat(lat);
                        actual.setLon(lon);
                    }
                    callback.onSuccess(Boolean.TRUE);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
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

    /**
     * Guarda la foto de perfil (HU07).
     *
     * Intenta primero Cloud Storage, que es el sitio natural para un binario.
     * Si el bucket no esta disponible —el plan Spark no lo incluye— se recurre
     * automaticamente a incrustar la imagen reducida en el propio documento
     * del usuario (ver {@link ImageUtils}). El resto de la app no nota la
     * diferencia porque todo se pinta con {@link ImageLoader}.
     */
    public void uploadPhoto(final Context context, final String uid, final Uri uri,
                            final RepoCallback<String> callback) {
        if (uri == null) {
            callback.onError("Selecciona una imagen");
            return;
        }
        // HU07: tipo y tamano se comprueban antes de subir O incrustar.
        String problema = ImageUtils.validar(context, uri);
        if (problema != null) {
            callback.onError(problema);
            return;
        }
        final StorageReference ref = FirebaseManager.storage().getReference()
                .child(Constants.STORAGE_AVATARS)
                .child(uid + ".jpg");

        ref.putFile(uri)
                .continueWithTask(new Continuation<UploadTask.TaskSnapshot, Task<Uri>>() {
                    @Override
                    public Task<Uri> then(@NonNull Task<UploadTask.TaskSnapshot> task)
                            throws Exception {
                        if (!task.isSuccessful() && task.getException() != null) {
                            throw task.getException();
                        }
                        return ref.getDownloadUrl();
                    }
                })
                .addOnCompleteListener(new OnCompleteListener<Uri>() {
                    @Override
                    public void onComplete(@NonNull Task<Uri> task) {
                        if (task.isSuccessful() && task.getResult() != null) {
                            savePhotoValue(uid, task.getResult().toString(), callback);
                        } else {
                            // Sin Storage: se incrusta la imagen en el documento.
                            embedPhoto(context, uid, uri, callback);
                        }
                    }
                });
    }

    /** Respaldo cuando Cloud Storage no esta disponible. */
    private void embedPhoto(final Context context, final String uid, final Uri uri,
                            final RepoCallback<String> callback) {
        final Handler main = new Handler(Looper.getMainLooper());
        new Thread(new Runnable() {
            @Override
            public void run() {
                final String data;
                try {
                    data = ImageUtils.encodeAvatar(context, uri);
                } catch (Exception e) {
                    main.post(new Runnable() {
                        @Override
                        public void run() {
                            callback.onError("No se pudo procesar la imagen. "
                                    + "Prueba con otra foto");
                        }
                    });
                    return;
                }
                main.post(new Runnable() {
                    @Override
                    public void run() {
                        savePhotoValue(uid, data, callback);
                    }
                });
            }
        }).start();
    }

    /** Escribe el valor final de photoUrl, sea una URL o una imagen incrustada. */
    private void savePhotoValue(final String uid, final String value,
                                final RepoCallback<String> callback) {
        FirestoreCollections.user(uid)
                .update("photoUrl", value)
                .addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void unused) {
                        User u = currentUser.getValue();
                        if (u != null && uid.equals(u.getUid())) {
                            u.setPhotoUrl(value);
                            currentUser.postValue(u);
                        }
                        callback.onSuccess(value);
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        callback.onError(FirebaseErrors.translate(e));
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

                            // HU06: un perfil esta completo cuando tiene tambien
                            // habilidades. Si no se recalcula aqui, quien completa
                            // el perfil y DESPUES anade sus habilidades se queda
                            // marcado como incompleto y desaparece de Explorar.
                            boolean completo = isProfileComplete(u);
                            if (completo != u.isProfileCompleted()) {
                                u.setProfileCompleted(completo);
                                Map<String, Object> flag = new HashMap<>();
                                flag.put("profileCompleted", completo);
                                FirestoreCollections.user(uid)
                                        .set(flag, com.google.firebase.firestore.SetOptions.merge());
                            }
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
            public Void apply(@NonNull com.google.firebase.firestore.Transaction transaction)
                    throws com.google.firebase.firestore.FirebaseFirestoreException {
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
                && !isBlank(u.getCycle())
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
