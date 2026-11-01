package com.skillswap.view.exchange;

import android.net.Uri;
import android.os.Bundle;

import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.skillswap.R;
import com.skillswap.databinding.ActivityEvidenceBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Exchange;
import com.skillswap.model.LearningEvidence;
import com.skillswap.model.Resource;
import com.skillswap.utils.Constants;
import com.skillswap.utils.UiUtils;
import com.skillswap.utils.Validators;
import com.skillswap.view.BaseActivity;
import com.skillswap.viewmodel.EvidenceViewModel;

/**
 * INNOVACION 6 - Validacion practica del aprendizaje.
 * Autoevaluacion entre pares, no es una certificacion academica.
 */
public class EvidenceActivity extends BaseActivity {

    private ActivityEvidenceBinding binding;
    private EvidenceViewModel viewModel;
    private Exchange exchange;
    private Uri fileUri;

    private final ActivityResultLauncher<String> pickImage =
            registerForActivityResult(new ActivityResultContracts.GetContent(),
                    new ActivityResultCallback<Uri>() {
                        @Override
                        public void onActivityResult(Uri uri) {
                            if (uri == null) return;
                            fileUri = uri;
                            binding.imgPreview.setImageURI(uri);
                            UiUtils.visible(binding.imgPreview, true);
                        }
                    });

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityEvidenceBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        String exchangeId = getIntent().getStringExtra(Constants.EXTRA_EXCHANGE_ID);
        viewModel = new ViewModelProvider(this).get(EvidenceViewModel.class);

        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.learning_evidence));

        binding.btnAttach.setOnClickListener(v -> pickImage.launch("image/*"));
        binding.btnSubmit.setOnClickListener(v -> submit());

        viewModel.exchange().observe(this, new Observer<Exchange>() {
            @Override
            public void onChanged(Exchange data) {
                if (data == null) return;
                exchange = data;
                binding.txtSkill.setText(data.getSkillILearn(FirebaseManager.uid()));
            }
        });

        viewModel.submitState().observe(this, new Observer<Resource<LearningEvidence>>() {
            @Override
            public void onChanged(Resource<LearningEvidence> state) {
                if (state == null) return;
                binding.btnSubmit.setEnabled(!state.isLoading());
                if (state.isSuccess()) {
                    info("Actividad registrada",
                            "Sumaste " + Constants.POINTS_EVIDENCE_REGISTERED
                                    + " SkillPoints. Recuerda que este registro es una "
                                    + "autoevaluación entre pares, no una certificación académica.");
                    binding.btnSubmit.postDelayed(EvidenceActivity.this::finish, 1200);
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });

        if (exchangeId != null) viewModel.load(exchangeId);
    }

    private void submit() {
        UiUtils.hideKeyboard(binding.getRoot());
        if (exchange == null) {
            toast(binding.getRoot(), "El intercambio aún se está cargando");
            return;
        }

        String activity = Validators.text(binding.tilActivity).trim();
        if (!Validators.apply(binding.tilActivity,
                Validators.validateMinLength(activity, 5, "La actividad"))) return;

        LearningEvidence evidence = new LearningEvidence();
        evidence.setActivity(activity);
        evidence.setNotes(Validators.text(binding.tilNotes).trim());
        evidence.setObjectiveAchieved(binding.switchAchieved.isChecked());
        evidence.setSelfAssessment((int) binding.ratingSelf.getRating());

        viewModel.submit(this, evidence, fileUri);
    }
}
