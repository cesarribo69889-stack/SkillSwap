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
import com.skillswap.view.auth.OnboardingActivity;
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
                    // Al quedarse sin sesion se vuelve a la introduccion, igual
                    // que cuando la app se abre desde cero sin haber iniciado sesion.
                    Intent intent = new Intent(requireContext(), OnboardingActivity.class);
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
