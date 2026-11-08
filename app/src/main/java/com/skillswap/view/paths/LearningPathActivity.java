package com.skillswap.view.paths;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.skillswap.R;
import com.skillswap.adapter.LearningPathAdapter;
import com.skillswap.databinding.ActivityLearningPathBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.PassportEntry;
import com.skillswap.utils.Constants;
import com.skillswap.utils.LearningPathEngine;
import com.skillswap.utils.UiUtils;
import com.skillswap.view.BaseActivity;
import com.skillswap.view.MainActivity;
import com.skillswap.viewmodel.PassportViewModel;

import java.util.List;

/**
 * INNOVACION 9 - Rutas de aprendizaje.
 *
 * Una habilidad rara vez se aprende suelta. Esta pantalla ordena las
 * habilidades por prerrequisitos y marca por donde va el estudiante usando
 * lo que ya tiene registrado en su Pasaporte, sin pedirle que rellene nada.
 *
 * Reutiliza el PassportViewModel: la fuente de verdad sigue siendo el
 * pasaporte, aqui solo se interpreta.
 */
public class LearningPathActivity extends BaseActivity {

    private ActivityLearningPathBinding binding;
    private PassportViewModel viewModel;
    private LearningPathAdapter adapter;

    private String habilidadSugerida;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityLearningPathBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.learning_paths));

        adapter = new LearningPathAdapter(this::buscarQuienEnsene);
        binding.rvPaths.setLayoutManager(new LinearLayoutManager(this));
        binding.rvPaths.setAdapter(adapter);

        binding.btnFindTeacher.setOnClickListener(v -> buscarQuienEnsene(habilidadSugerida));

        viewModel = new ViewModelProvider(this).get(PassportViewModel.class);
        viewModel.entries().observe(this, new Observer<List<PassportEntry>>() {
            @Override
            public void onChanged(List<PassportEntry> entries) {
                pintar(entries);
            }
        });
        viewModel.start(FirebaseManager.uid());
    }

    private void pintar(List<PassportEntry> pasaporte) {
        adapter.submit(LearningPathEngine.rutasDe(pasaporte));

        LearningPathEngine.Ruta recomendada =
                LearningPathEngine.rutaRecomendada(pasaporte);

        if (recomendada == null || recomendada.siguientePaso() == null) {
            UiUtils.visible(binding.cardRecommended, false);
            habilidadSugerida = null;
            return;
        }

        LearningPathEngine.Paso paso = recomendada.siguientePaso();
        habilidadSugerida = paso.getHabilidad();

        UiUtils.visible(binding.cardRecommended, true);
        binding.txtNextSkill.setText(paso.getHabilidad());
        binding.txtNextReason.setText(paso.getPorQue());
    }

    /** Lleva a la pestaña Explorar para buscar quien enseñe esa habilidad. */
    private void buscarQuienEnsene(String habilidad) {
        if (habilidad == null) return;
        Intent intent = new Intent(this, MainActivity.class);
        intent.putExtra(Constants.EXTRA_OPEN_SECTION, "explore");
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        startActivity(intent);
        finish();
    }
}
