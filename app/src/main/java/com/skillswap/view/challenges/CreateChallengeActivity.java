package com.skillswap.view.challenges;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.google.android.material.chip.Chip;
import com.skillswap.databinding.ActivityCreateChallengeBinding;
import com.skillswap.model.Challenge;
import com.skillswap.model.Resource;
import com.skillswap.utils.ChipFactory;
import com.skillswap.utils.Constants;
import com.skillswap.utils.DateUtils;
import com.skillswap.utils.SkillCatalog;
import com.skillswap.utils.UiUtils;
import com.skillswap.utils.Validators;
import com.skillswap.view.BaseActivity;
import com.skillswap.viewmodel.ChallengesViewModel;

import java.util.ArrayList;
import java.util.List;

/** Publicacion de un nuevo Skill Challenge. */
public class CreateChallengeActivity extends BaseActivity {

    private ActivityCreateChallengeBinding binding;
    private ChallengesViewModel viewModel;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityCreateChallengeBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        viewModel = new ViewModelProvider(this).get(ChallengesViewModel.class);
        setupToolbar(binding.toolbarInc.toolbar, "Crear reto");

        buildSkillChips();
        binding.btnCreate.setOnClickListener(v -> create());

        viewModel.createState().observe(this, new Observer<Resource<Challenge>>() {
            @Override
            public void onChanged(Resource<Challenge> state) {
                if (state == null) return;
                binding.btnCreate.setEnabled(!state.isLoading());
                if (state.isSuccess() && state.getData() != null) {
                    toast(binding.getRoot(), "¡Reto publicado!");
                    Intent intent = new Intent(CreateChallengeActivity.this,
                            ChallengeDetailActivity.class);
                    intent.putExtra(Constants.EXTRA_CHALLENGE_ID, state.getData().getId());
                    startActivity(intent);
                    finish();
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });
    }

    private void buildSkillChips() {
        binding.chipsSkills.removeAllViews();
        for (String skill : SkillCatalog.getAllSkillNames()) {
            Chip chip = ChipFactory.choiceChip(this, skill, false);
            chip.setTag(skill);
            binding.chipsSkills.addView(chip);
        }
    }

    private void create() {
        UiUtils.hideKeyboard(binding.getRoot());

        String title = Validators.text(binding.tilTitle).trim();
        String objective = Validators.text(binding.tilObjective).trim();
        String description = Validators.text(binding.tilDescription).trim();
        String max = Validators.text(binding.tilMax).trim();
        String days = Validators.text(binding.tilDays).trim();

        boolean ok = Validators.apply(binding.tilTitle,
                Validators.validateMinLength(title, 5, "El título"));
        ok &= Validators.apply(binding.tilObjective,
                Validators.validateMinLength(objective, 10, "El objetivo"));
        ok &= Validators.apply(binding.tilMax,
                Validators.validateIntRange(max, 2, 10, "Los participantes"));
        ok &= Validators.apply(binding.tilDays,
                Validators.validateIntRange(days, 1, 60, "Los días"));
        if (!ok) return;

        List<String> skills = new ArrayList<>();
        for (int i = 0; i < binding.chipsSkills.getChildCount(); i++) {
            Chip chip = (Chip) binding.chipsSkills.getChildAt(i);
            if (chip.isChecked()) skills.add(String.valueOf(chip.getTag()));
        }
        if (skills.isEmpty()) {
            toast(binding.getRoot(), "Selecciona al menos una habilidad requerida");
            return;
        }

        int durationDays = Integer.parseInt(days);

        Challenge challenge = new Challenge();
        challenge.setTitle(title);
        challenge.setObjective(objective);
        challenge.setDescription(description);
        challenge.setRequiredSkills(skills);
        challenge.setCategory(SkillCatalog.categoryOf(skills.get(0)));
        challenge.setMaxParticipants(Integer.parseInt(max));
        challenge.setDurationDays(durationDays);
        challenge.setDeadline(DateUtils.plusDays(durationDays));

        viewModel.create(challenge);
    }
}
