package com.skillswap.view.exchange;

import android.os.Bundle;
import android.widget.ArrayAdapter;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.google.android.material.chip.Chip;
import com.google.android.material.textfield.MaterialAutoCompleteTextView;
import com.skillswap.R;
import com.skillswap.databinding.ActivitySendRequestBinding;
import com.skillswap.model.ExchangeRequest;
import com.skillswap.model.MatchResult;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.model.UserSkill;
import com.skillswap.repository.UserRepository;
import com.skillswap.utils.ChipFactory;
import com.skillswap.utils.Constants;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.SkillMatchEngine;
import com.skillswap.utils.UiUtils;
import com.skillswap.utils.Validators;
import com.skillswap.view.BaseActivity;
import com.skillswap.viewmodel.ProfileViewModel;
import com.skillswap.viewmodel.RequestsViewModel;

import java.util.Arrays;
import java.util.List;
import java.util.Locale;

/** Formulario de solicitud de intercambio. */
public class SendRequestActivity extends BaseActivity {

    private ActivitySendRequestBinding binding;
    private RequestsViewModel requestsViewModel;
    private ProfileViewModel profileViewModel;

    private User target;
    private int matchScore;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivitySendRequestBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        String userId = getIntent().getStringExtra(Constants.EXTRA_USER_ID);
        requestsViewModel = new ViewModelProvider(this).get(RequestsViewModel.class);
        profileViewModel = new ViewModelProvider(this).get(ProfileViewModel.class);

        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.send_request));
        setupSchedules();

        binding.btnSend.setOnClickListener(v -> send());

        profileViewModel.profileState().observe(this, new Observer<Resource<User>>() {
            @Override
            public void onChanged(Resource<User> state) {
                if (state == null) return;
                if (state.isSuccess()) {
                    target = state.getData();
                    render();
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });

        requestsViewModel.sendState().observe(this, new Observer<Resource<ExchangeRequest>>() {
            @Override
            public void onChanged(Resource<ExchangeRequest> state) {
                if (state == null) return;
                binding.btnSend.setEnabled(!state.isLoading());
                if (state.isSuccess()) {
                    info("¡Solicitud enviada!",
                            "Te avisaremos cuando " + target.getShortName() + " responda.");
                    binding.btnSend.postDelayed(SendRequestActivity.this::finish, 900);
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });

        profileViewModel.loadProfile(userId);
    }

    private void setupSchedules() {
        List<String> slots = Arrays.asList(getResources().getStringArray(R.array.availability_slots));
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this,
                android.R.layout.simple_list_item_1, slots);
        if (binding.tilSchedule.getEditText() instanceof MaterialAutoCompleteTextView) {
            ((MaterialAutoCompleteTextView) binding.tilSchedule.getEditText()).setAdapter(adapter);
        }
    }

    private void render() {
        if (target == null) return;

        User me = UserRepository.get().currentUserValue();
        MatchResult match = SkillMatchEngine.calculate(me, target);
        matchScore = match.getScore();

        binding.txtName.setText(target.getFullName());
        binding.txtCareer.setText(target.getAcademicLine());
        binding.txtScore.setText(String.format(Locale.getDefault(), "%d %%", matchScore));
        ImageLoader.avatar(binding.imgAvatar, target.getPhotoUrl());

        // Habilidades que el otro ensena (lo que yo puedo aprender).
        binding.chipsWanted.removeAllViews();
        for (UserSkill s : target.getTeachSkills()) {
            Chip chip = ChipFactory.choiceChip(this, s.getName() + " · " + s.getLevel(), false);
            chip.setTag(s.getName());
            binding.chipsWanted.addView(chip);
        }
        preselect(binding.chipsWanted, match.getTheyTeachYouWant());

        // Habilidades que yo ensenio.
        binding.chipsOffered.removeAllViews();
        if (me != null) {
            for (UserSkill s : me.getTeachSkills()) {
                Chip chip = ChipFactory.choiceChip(this, s.getName() + " · " + s.getLevel(), false);
                chip.setTag(s.getName());
                binding.chipsOffered.addView(chip);
            }
            preselect(binding.chipsOffered, match.getYouTeachTheyWant());
        }

        boolean presencial = Constants.MODALITY_PRESENCIAL.equals(target.getModality());
        binding.chipPresencial.setChecked(presencial);
        binding.chipVirtual.setChecked(!presencial);

        if (!target.getAvailability().isEmpty()
                && binding.tilSchedule.getEditText() instanceof MaterialAutoCompleteTextView) {
            ((MaterialAutoCompleteTextView) binding.tilSchedule.getEditText())
                    .setText(target.getAvailability().get(0), false);
        }
    }

    private void preselect(com.google.android.material.chip.ChipGroup group, List<String> values) {
        if (values == null || values.isEmpty()) return;
        for (int i = 0; i < group.getChildCount(); i++) {
            Chip chip = (Chip) group.getChildAt(i);
            if (values.contains(String.valueOf(chip.getTag()))) {
                chip.setChecked(true);
                return;
            }
        }
    }

    private void send() {
        UiUtils.hideKeyboard(binding.getRoot());
        if (target == null) return;

        String wanted = selected(binding.chipsWanted);
        String offered = selected(binding.chipsOffered);

        if (wanted == null) {
            toast(binding.getRoot(), "Elige qué quieres aprender");
            return;
        }
        if (offered == null) {
            toast(binding.getRoot(), "Elige qué puedes enseñar");
            return;
        }

        String modality = binding.chipPresencial.isChecked()
                ? Constants.MODALITY_PRESENCIAL : Constants.MODALITY_VIRTUAL;
        String schedule = Validators.text(binding.tilSchedule).trim();
        String message = Validators.text(binding.tilMessage).trim();

        if (schedule.isEmpty()) {
            toast(binding.getRoot(), "Propón un horario");
            return;
        }

        requestsViewModel.sendRequest(target, wanted, offered, message, modality,
                schedule, matchScore);
    }

    private String selected(com.google.android.material.chip.ChipGroup group) {
        for (int i = 0; i < group.getChildCount(); i++) {
            Chip chip = (Chip) group.getChildAt(i);
            if (chip.isChecked()) return String.valueOf(chip.getTag());
        }
        return null;
    }
}
