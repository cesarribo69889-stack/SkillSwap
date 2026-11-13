package com.skillswap.repository;

import android.content.Context;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.Continuation;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.firebase.FirestoreCollections;
import com.skillswap.model.Exchange;
import com.skillswap.model.LearningEvidence;
import com.skillswap.utils.Constants;
import com.skillswap.utils.ImageUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * INNOVACION 6 - Validacion practica del aprendizaje.
 * Es una autoevaluacion entre pares, NO una certificacion academica.
 */
public class EvidenceRepository {

    private static EvidenceRepository instance;

    public static synchronized EvidenceRepository get() {
        if (instance == null) instance = new EvidenceRepository();
        return instance;
    }

    private EvidenceRepository() {
    }

    /**
     * Registra la actividad realizada, con evidencia opcional.
     *
     * Igual que la foto de perfil: se intenta Cloud Storage y, si el bucket no
     * esta disponible, la imagen se reduce a 800 px y se guarda incrustada en
     * el propio documento. Si aun asi falla, la evidencia se guarda sin imagen:
     * lo que importa es el registro de la actividad.
     */
    public void submit(final Context context, final Exchange exchange, final String uid,
                       final LearningEvidence evidence, final Uri fileUri,
                       final RepoCallback<LearningEvidence> callback) {
        if (exchange == null) {
            callback.onError("Intercambio no disponible");
            return;
        }
        if (evidence.getActivity() == null || evidence.getActivity().trim().isEmpty()) {
            callback.onError("Describe la actividad realizada");
            return;
        }

        final DocumentReference ref = FirestoreCollections.evidence().document();
        evidence.setId(ref.getId());
        evidence.setExchangeId(exchange.getId());
        evidence.setUserId(uid);
        evidence.setPartnerId(exchange.getPartnerId(uid));
        evidence.setSkillName(exchange.getSkillILearn(uid));
        evidence.setCreatedAt(System.currentTimeMillis());

        if (fileUri == null) {
            persist(ref, evidence, uid, callback);
            return;
        }

        // Mismo control que la foto de perfil (HU07): tipo y 5 MB maximo,
        // tanto si se sube a Storage como si cae al respaldo incrustado.
        String problema = ImageUtils.validar(context, fileUri);
        if (problema != null) {
            callback.onError(problema);
            return;
        }

        final StorageReference storage = FirebaseManager.storage().getReference()
                .child(Constants.STORAGE_EVIDENCE)
                .child(uid)
                .child(evidence.getId() + ".jpg");

        storage.putFile(fileUri)
                .continueWithTask(new Continuation<UploadTask.TaskSnapshot, Task<Uri>>() {
                    @Override
                    public Task<Uri> then(@NonNull Task<UploadTask.TaskSnapshot> task)
                            throws Exception {
                        if (!task.isSuccessful() && task.getException() != null) {
                            throw task.getException();
                        }
                        return storage.getDownloadUrl();
                    }
                })
                .addOnCompleteListener(new OnCompleteListener<Uri>() {
                    @Override
                    public void onComplete(@NonNull Task<Uri> task) {
                        if (task.isSuccessful() && task.getResult() != null) {
                            evidence.setEvidenceUrl(task.getResult().toString());
                            persist(ref, evidence, uid, callback);
                        } else {
                            embedEvidence(context, ref, evidence, uid, fileUri, callback);
                        }
                    }
                });
    }

    /** Respaldo cuando Cloud Storage no esta disponible. */
    private void embedEvidence(final Context context, final DocumentReference ref,
                               final LearningEvidence evidence, final String uid,
                               final Uri fileUri, final RepoCallback<LearningEvidence> callback) {
        final Handler main = new Handler(Looper.getMainLooper());
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    evidence.setEvidenceUrl(ImageUtils.encodeEvidence(context, fileUri));
                } catch (Exception e) {
                    // La imagen es opcional: lo que importa es el registro.
                    evidence.setEvidenceUrl("");
                }
                main.post(new Runnable() {
                    @Override
                    public void run() {
                        persist(ref, evidence, uid, callback);
                    }
                });
            }
        }).start();
    }

    private void persist(DocumentReference ref, final LearningEvidence evidence, final String uid,
                         final RepoCallback<LearningEvidence> callback) {
        ref.set(evidence)
                .addOnSuccessListener(unused -> {
                    GamificationRepository.get().award(uid, Constants.POINTS_EVIDENCE_REGISTERED,
                            "Validación de aprendizaje", evidence.getId());
                    callback.onSuccess(evidence);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }

    public void fetchByUser(String uid, final RepoCallback<List<LearningEvidence>> callback) {
        FirestoreCollections.evidence()
                .whereEqualTo("userId", uid)
                .limit(100)
                .get()
                .addOnSuccessListener(snapshots -> {
                    List<LearningEvidence> list = new ArrayList<>();
                    for (QueryDocumentSnapshot doc : snapshots) {
                        LearningEvidence ev = doc.toObject(LearningEvidence.class);
                        ev.setId(doc.getId());
                        list.add(ev);
                    }
                    Collections.sort(list, new Comparator<LearningEvidence>() {
                        @Override
                        public int compare(LearningEvidence a, LearningEvidence b) {
                            return Long.compare(b.getCreatedAt(), a.getCreatedAt());
                        }
                    });
                    callback.onSuccess(list);
                })
                .addOnFailureListener(e -> callback.onError(FirebaseErrors.translate(e)));
    }
}
