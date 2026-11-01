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
                        ? getString(R.string.st_no_description)
                        : user.getDescription());
        binding.txtModality.setText(getString(R.string.fmt_modality,
                user.getModality() == null || user.getModality().isEmpty()
                        ? getString(R.string.st_modality_pending) : user.getModality()));
        binding.txtAvailability.setText(user.getAvailability().isEmpty()
                ? getString(R.string.st_availability_pending)
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
            binding.btnRequest.setText(R.string.st_no_complementary_skills);
        }
    }
}
