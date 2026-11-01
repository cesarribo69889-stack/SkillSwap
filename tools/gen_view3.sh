#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
mkdir -p "$J/view/profile" "$J/view/skills" "$J/view/matches"

# ============================================================ ProfileFragment
cat > "$J/view/profile/ProfileFragment.java" <<'EOF'
package com.skillswap.view.profile;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.skillswap.R;
import com.skillswap.databinding.FragmentProfileBinding;
import com.skillswap.databinding.ItemProfileRowBinding;
import com.skillswap.model.User;
import com.skillswap.utils.ChipFactory;
import com.skillswap.utils.ImageLoader;
import com.skillswap.view.auth.LoginActivity;
import com.skillswap.view.challenges.ChallengesActivity;
import com.skillswap.view.exchange.RequestsActivity;
import com.skillswap.view.notifications.NotificationsActivity;
import com.skillswap.view.passport.PassportActivity;
import com.skillswap.view.passport.SkillPointsActivity;
import com.skillswap.view.ratings.HistoryActivity;
import com.skillswap.view.skills.MySkillsActivity;
import com.skillswap.viewmodel.AuthViewModel;
import com.skillswap.viewmodel.ProfileViewModel;

import java.util.Locale;

/** Perfil del estudiante autenticado. */
public class ProfileFragment extends Fragment {

    private FragmentProfileBinding binding;
    private ProfileViewModel viewModel;
    private AuthViewModel authViewModel;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        binding = FragmentProfileBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        viewModel = new ViewModelProvider(this).get(ProfileViewModel.class);
        authViewModel = new ViewModelProvider(this).get(AuthViewModel.class);

        setupRows();

        binding.btnEditProfile.setOnClickListener(v ->
                startActivity(new Intent(requireContext(), EditProfileActivity.class)));
        binding.btnManageSkills.setOnClickListener(v ->
                startActivity(new Intent(requireContext(), MySkillsActivity.class)));
        binding.btnLogout.setOnClickListener(v -> confirmLogout());

        viewModel.currentUser().observe(getViewLifecycleOwner(), new Observer<User>() {
            @Override
            public void onChanged(User user) {
                if (user != null) render(user);
            }
        });
        viewModel.listenCurrentUser();
    }

    private void setupRows() {
        row(binding.rowPassport, R.drawable.ic_passport, getString(R.string.passport),
                "Tu actividad por habilidad", PassportActivity.class);
        row(binding.rowPoints, R.drawable.ic_points, getString(R.string.skillpoints),
                "Puntos, niveles e insignias", SkillPointsActivity.class);
        row(binding.rowChallenges, R.drawable.ic_challenge, getString(R.string.challenges),
                "Retos colaborativos", ChallengesActivity.class);
        row(binding.rowHistory, R.drawable.ic_history, getString(R.string.history),
                "Intercambios completados", HistoryActivity.class);
        row(binding.rowRequests, R.drawable.ic_inbox, "Solicitudes",
                "Recibidas y enviadas", RequestsActivity.class);
        row(binding.rowNotifications, R.drawable.ic_notifications, getString(R.string.notifications),
                "Centro de notificaciones", NotificationsActivity.class);
    }

    private void row(ItemProfileRowBinding rowBinding, int icon, String title, String subtitle,
                     final Class<?> target) {
        rowBinding.rowIcon.setImageResource(icon);
        rowBinding.rowTitle.setText(title);
        rowBinding.rowSubtitle.setText(subtitle);
        rowBinding.getRoot().setOnClickListener(v ->
                startActivity(new Intent(requireContext(), target)));
    }

    private void render(User user) {
        binding.txtName.setText(user.getFullName());
        binding.txtAcademic.setText(user.getAcademicLine());
        binding.txtUniversity.setText(user.getUniversity());
        binding.txtReputation.setText(user.getTotalRatings() > 0
                ? String.format(Locale.getDefault(), "%.1f", user.getReputation()) : "—");
        binding.txtExchanges.setText(String.valueOf(user.getExchangesCount()));
        binding.txtPoints.setText(String.valueOf(user.getSkillPoints()));

        binding.txtDescription.setText(
                user.getDescription() == null || user.getDescription().trim().isEmpty()
                        ? "Cuéntale a la comunidad quién eres y qué te gusta enseñar."
                        : user.getDescription());

        binding.txtModality.setText(
                user.getModality() == null || user.getModality().isEmpty()
                        ? "Modalidad sin definir" : "Modalidad: " + user.getModality());

        binding.txtAvailability.setText(user.getAvailability().isEmpty()
                ? "Disponibilidad sin definir"
                : android.text.TextUtils.join(" · ", user.getAvailability()));

        ChipFactory.fillSkills(binding.chipsTeach, user.getTeachSkills(), true);
        ChipFactory.fillSkills(binding.chipsLearn, user.getLearnSkills(), false);
        ImageLoader.avatar(binding.imgAvatar, user.getPhotoUrl());
    }

    private void confirmLogout() {
        new MaterialAlertDialogBuilder(requireContext())
                .setTitle(R.string.logout)
                .setMessage("¿Seguro que quieres cerrar tu sesión en SkillSwap?")
                .setNegativeButton(R.string.cancel, null)
                .setPositiveButton(R.string.logout, (dialog, which) -> {
                    authViewModel.logout();
                    Intent intent = new Intent(requireContext(), LoginActivity.class);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                    startActivity(intent);
                    requireActivity().finish();
                })
                .show();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
EOF

# ============================================================ EditProfileActivity
cat > "$J/view/profile/EditProfileActivity.java" <<'EOF'
package com.skillswap.view.profile;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.widget.ArrayAdapter;

import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.google.android.material.chip.Chip;
import com.google.android.material.textfield.MaterialAutoCompleteTextView;
import com.skillswap.R;
import com.skillswap.databinding.ActivityEditProfileBinding;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.utils.ChipFactory;
import com.skillswap.utils.Constants;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;
import com.skillswap.utils.Validators;
import com.skillswap.view.BaseActivity;
import com.skillswap.view.MainActivity;
import com.skillswap.view.skills.MySkillsActivity;
import com.skillswap.viewmodel.ProfileViewModel;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/** Edicion del perfil del estudiante. */
public class EditProfileActivity extends BaseActivity {

    public static final String EXTRA_FIRST_TIME = "extra_first_time";

    private ActivityEditProfileBinding binding;
    private ProfileViewModel viewModel;
    private User current;
    private boolean firstTime;

    private final ActivityResultLauncher<String> pickImage =
            registerForActivityResult(new ActivityResultContracts.GetContent(),
                    new ActivityResultCallback<Uri>() {
                        @Override
                        public void onActivityResult(Uri uri) {
                            if (uri == null || current == null) return;
                            binding.imgAvatar.setImageURI(uri);
                            viewModel.uploadPhoto(current.getUid(), uri);
                        }
                    });

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityEditProfileBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        firstTime = getIntent().getBooleanExtra(EXTRA_FIRST_TIME, false);
        viewModel = new ViewModelProvider(this).get(ProfileViewModel.class);

        setupToolbar(binding.toolbarInc.toolbar,
                firstTime ? "Completa tu perfil" : getString(R.string.profile_edit));
        setupCycles();
        setupAvailability();

        binding.fabPhoto.setOnClickListener(v -> pickImage.launch("image/*"));
        binding.btnSave.setOnClickListener(v -> save());

        viewModel.currentUser().observe(this, new Observer<User>() {
            @Override
            public void onChanged(User user) {
                if (user == null) return;
                current = user;
                render(user);
            }
        });
        viewModel.listenCurrentUser();

        viewModel.photoState().observe(this, new Observer<Resource<String>>() {
            @Override
            public void onChanged(Resource<String> state) {
                if (state == null) return;
                UiUtils.visible(binding.progressPhoto, state.isLoading());
                if (state.isSuccess() && current != null) {
                    current.setPhotoUrl(state.getData());
                    toast(binding.getRoot(), "Foto actualizada");
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });

        viewModel.saveState().observe(this, new Observer<Resource<User>>() {
            @Override
            public void onChanged(Resource<User> state) {
                if (state == null) return;
                binding.btnSave.setEnabled(!state.isLoading());
                if (state.isSuccess()) {
                    if (firstTime) {
                        startActivity(new Intent(EditProfileActivity.this, MySkillsActivity.class));
                        startActivity(new Intent(EditProfileActivity.this, MainActivity.class));
                        finishAffinity();
                    } else {
                        toast(binding.getRoot(), "Perfil actualizado");
                        finish();
                    }
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });
    }

    private void setupCycles() {
        List<String> cycles = Arrays.asList(getResources().getStringArray(R.array.cycles));
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this,
                android.R.layout.simple_list_item_1, cycles);
        if (binding.tilCycle.getEditText() instanceof MaterialAutoCompleteTextView) {
            ((MaterialAutoCompleteTextView) binding.tilCycle.getEditText()).setAdapter(adapter);
        }
    }

    private void setupAvailability() {
        binding.chipsAvailability.removeAllViews();
        for (String slot : getResources().getStringArray(R.array.availability_slots)) {
            Chip chip = ChipFactory.choiceChip(this, slot, false);
            chip.setTag(slot);
            binding.chipsAvailability.addView(chip);
        }
    }

    private void render(User user) {
        if (binding.tilFirstName.getEditText() != null) {
            binding.tilFirstName.getEditText().setText(user.getFirstName());
        }
        if (binding.tilLastName.getEditText() != null) {
            binding.tilLastName.getEditText().setText(user.getLastName());
        }
        if (binding.tilUniversity.getEditText() != null) {
            binding.tilUniversity.getEditText().setText(user.getUniversity());
        }
        if (binding.tilCareer.getEditText() != null) {
            binding.tilCareer.getEditText().setText(user.getCareer());
        }
        if (binding.tilCycle.getEditText() instanceof MaterialAutoCompleteTextView) {
            ((MaterialAutoCompleteTextView) binding.tilCycle.getEditText())
                    .setText(user.getCycle(), false);
        }
        if (binding.tilDescription.getEditText() != null) {
            binding.tilDescription.getEditText().setText(user.getDescription());
        }

        binding.chipPresencial.setChecked(Constants.MODALITY_PRESENCIAL.equals(user.getModality()));
        binding.chipVirtual.setChecked(Constants.MODALITY_VIRTUAL.equals(user.getModality()));
        binding.chipBoth.setChecked(Constants.MODALITY_BOTH.equals(user.getModality()));

        for (int i = 0; i < binding.chipsAvailability.getChildCount(); i++) {
            Chip chip = (Chip) binding.chipsAvailability.getChildAt(i);
            chip.setChecked(user.getAvailability().contains(String.valueOf(chip.getTag())));
        }

        ImageLoader.avatar(binding.imgAvatar, user.getPhotoUrl());
    }

    private void save() {
        UiUtils.hideKeyboard(binding.getRoot());
        if (current == null) {
            toast(binding.getRoot(), "Tu perfil aún se está cargando");
            return;
        }

        String firstName = Validators.text(binding.tilFirstName).trim();
        String lastName = Validators.text(binding.tilLastName).trim();
        String university = Validators.text(binding.tilUniversity).trim();
        String career = Validators.text(binding.tilCareer).trim();

        boolean ok = Validators.apply(binding.tilFirstName, Validators.validateName(firstName));
        ok &= Validators.apply(binding.tilLastName, Validators.validateName(lastName));
        ok &= Validators.apply(binding.tilUniversity,
                Validators.validateMinLength(university, 3, "La universidad"));
        ok &= Validators.apply(binding.tilCareer,
                Validators.validateMinLength(career, 3, "La carrera"));
        if (!ok) return;

        String modality = "";
        if (binding.chipPresencial.isChecked()) modality = Constants.MODALITY_PRESENCIAL;
        else if (binding.chipVirtual.isChecked()) modality = Constants.MODALITY_VIRTUAL;
        else if (binding.chipBoth.isChecked()) modality = Constants.MODALITY_BOTH;

        if (modality.isEmpty()) {
            toast(binding.getRoot(), "Elige una modalidad de intercambio");
            return;
        }

        List<String> availability = new ArrayList<>();
        for (int i = 0; i < binding.chipsAvailability.getChildCount(); i++) {
            Chip chip = (Chip) binding.chipsAvailability.getChildAt(i);
            if (chip.isChecked()) availability.add(String.valueOf(chip.getTag()));
        }
        if (availability.isEmpty()) {
            toast(binding.getRoot(), "Selecciona al menos un bloque de disponibilidad");
            return;
        }

        current.setFirstName(firstName);
        current.setLastName(lastName);
        current.setUniversity(university);
        current.setCareer(career);
        current.setCycle(Validators.text(binding.tilCycle).trim());
        current.setDescription(Validators.text(binding.tilDescription).trim());
        current.setModality(modality);
        current.setAvailability(availability);

        viewModel.saveProfile(current);
    }
}
EOF

# ============================================================ UserProfileActivity
cat > "$J/view/profile/UserProfileActivity.java" <<'EOF'
package com.skillswap.view.profile;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.skillswap.R;
import com.skillswap.adapter.RatingAdapter;
import com.skillswap.databinding.ActivityUserProfileBinding;
import com.skillswap.databinding.ItemMatchReasonBinding;
import com.skillswap.model.MatchReason;
import com.skillswap.model.MatchResult;
import com.skillswap.model.Rating;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.repository.UserRepository;
import com.skillswap.utils.ChipFactory;
import com.skillswap.utils.Constants;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.SkillMatchEngine;
import com.skillswap.utils.UiUtils;
import com.skillswap.view.BaseActivity;
import com.skillswap.view.exchange.SendRequestActivity;
import com.skillswap.viewmodel.ProfileViewModel;

import java.util.List;
import java.util.Locale;

/** Perfil publico de otro estudiante, con explicacion del SkillMatch. */
public class UserProfileActivity extends BaseActivity {

    private ActivityUserProfileBinding binding;
    private ProfileViewModel viewModel;
    private RatingAdapter ratingAdapter;
    private String userId;
    private User target;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityUserProfileBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        userId = getIntent().getStringExtra(Constants.EXTRA_USER_ID);
        viewModel = new ViewModelProvider(this).get(ProfileViewModel.class);

        ratingAdapter = new RatingAdapter();
        binding.rvRatings.setLayoutManager(new LinearLayoutManager(this));
        binding.rvRatings.setAdapter(ratingAdapter);

        binding.btnBack.setOnClickListener(v -> finish());
        binding.btnRequest.setOnClickListener(v -> {
            Intent intent = new Intent(this, SendRequestActivity.class);
            intent.putExtra(Constants.EXTRA_USER_ID, userId);
            startActivity(intent);
        });

        viewModel.profileState().observe(this, new Observer<Resource<User>>() {
            @Override
            public void onChanged(Resource<User> state) {
                if (state == null) return;
                if (state.isSuccess()) {
                    target = state.getData();
                    render(target);
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });

        viewModel.ratings().observe(this, new Observer<List<Rating>>() {
            @Override
            public void onChanged(List<Rating> ratings) {
                ratingAdapter.submit(ratings);
                boolean empty = ratings == null || ratings.isEmpty();
                UiUtils.visible(binding.txtNoRatings, empty);
                UiUtils.visible(binding.rvRatings, !empty);
            }
        });

        viewModel.loadProfile(userId);
    }

    private void render(User user) {
        if (user == null) return;

        binding.txtName.setText(user.getFullName());
        binding.txtAcademic.setText(user.getAcademicLine());
        binding.txtUniversity.setText(user.getUniversity());
        binding.txtReputation.setText(user.getTotalRatings() > 0
                ? String.format(Locale.getDefault(), "%.1f", user.getReputation()) : "—");
        binding.txtExchanges.setText(String.valueOf(user.getExchangesCount()));
        binding.txtDescription.setText(
                user.getDescription() == null || user.getDescription().trim().isEmpty()
                        ? "Este estudiante aún no escribió su descripción."
                        : user.getDescription());
        binding.txtModality.setText("Modalidad: "
                + (user.getModality() == null || user.getModality().isEmpty()
                ? "por definir" : user.getModality()));
        binding.txtAvailability.setText(user.getAvailability().isEmpty()
                ? "Disponibilidad por definir"
                : android.text.TextUtils.join(" · ", user.getAvailability()));

        ChipFactory.fillSkills(binding.chipsTeach, user.getTeachSkills(), true);
        ChipFactory.fillSkills(binding.chipsLearn, user.getLearnSkills(), false);
        ImageLoader.avatar(binding.imgAvatar, user.getPhotoUrl());

        renderMatch(user);
    }

    private void renderMatch(User user) {
        User me = UserRepository.get().currentUserValue();
        MatchResult match = SkillMatchEngine.calculate(me, user);

        binding.txtScore.setText(getString(R.string.compatibility, match.getScore()));
        binding.txtScoreLabel.setText(UiUtils.compatibilityLabel(match.getScore()));

        binding.containerReasons.removeAllViews();
        LayoutInflater inflater = LayoutInflater.from(this);
        int shown = 0;
        for (MatchReason reason : match.getReasons()) {
            if (shown >= 6) break;
            ItemMatchReasonBinding row = ItemMatchReasonBinding.inflate(
                    inflater, binding.containerReasons, false);
            row.txtReason.setText(reason.getText());
            row.txtReason.setTextColor(ContextCompat.getColor(this, R.color.white));
            row.imgIcon.setImageResource(reason.isPositive()
                    ? R.drawable.ic_check : R.drawable.ic_info);
            row.imgIcon.setImageTintList(android.content.res.ColorStateList.valueOf(
                    ContextCompat.getColor(this, R.color.white)));
            binding.containerReasons.addView(row.getRoot());
            shown++;
        }

        binding.btnRequest.setEnabled(match.getScore() > 0);
        if (match.getScore() == 0) {
            binding.btnRequest.setText("Sin habilidades complementarias");
        }
    }
}
EOF

echo "Vistas 3 (perfil) generadas."
