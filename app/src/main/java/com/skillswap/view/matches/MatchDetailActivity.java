package com.skillswap.view.matches;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.skillswap.R;
import com.skillswap.databinding.ActivityMatchDetailBinding;
import com.skillswap.databinding.ItemMatchReasonBinding;
import com.skillswap.model.MatchReason;
import com.skillswap.model.MatchResult;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.repository.UserRepository;
import com.skillswap.utils.Constants;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.SkillMatchEngine;
import com.skillswap.utils.UiUtils;
import com.skillswap.view.BaseActivity;
import com.skillswap.view.exchange.SendRequestActivity;
import com.skillswap.viewmodel.ProfileViewModel;

import java.util.Locale;

/**
 * Detalle del SkillMatch: porcentaje y explicacion de por que son compatibles.
 */
public class MatchDetailActivity extends BaseActivity {

    private ActivityMatchDetailBinding binding;
    private ProfileViewModel viewModel;
    private String userId;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityMatchDetailBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        userId = getIntent().getStringExtra(Constants.EXTRA_USER_ID);
        viewModel = new ViewModelProvider(this).get(ProfileViewModel.class);

        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.st_skillmatch));

        binding.txtFormula.setText(getString(R.string.fmt_match_formula,
                SkillMatchEngine.W_SKILLS, SkillMatchEngine.W_LEVEL,
                SkillMatchEngine.W_MODALITY, SkillMatchEngine.W_AVAILABILITY,
                SkillMatchEngine.W_REPUTATION));

        binding.btnRequest.setOnClickListener(v -> {
            Intent intent = new Intent(this, SendRequestActivity.class);
            intent.putExtra(Constants.EXTRA_USER_ID, userId);
            startActivity(intent);
        });

        viewModel.profileState().observe(this, new Observer<Resource<User>>() {
            @Override
            public void onChanged(Resource<User> state) {
                if (state == null) return;
                if (state.isSuccess()) render(state.getData());
                else if (state.isError()) toast(binding.getRoot(), state.getMessage());
            }
        });

        viewModel.loadProfile(userId);
    }

    private void render(User other) {
        if (other == null) return;

        User me = UserRepository.get().currentUserValue();
        MatchResult match = SkillMatchEngine.calculate(me, other);

        binding.txtName.setText(other.getFullName());
        binding.txtScore.setText(String.format(Locale.getDefault(), "%d %%", match.getScore()));
        binding.txtScoreLabel.setText(UiUtils.compatibilityLabel(match.getScore()));
        ImageLoader.avatar(binding.imgAvatar, other.getPhotoUrl());

        binding.containerReasons.removeAllViews();
        LayoutInflater inflater = LayoutInflater.from(this);
        for (MatchReason reason : match.getReasons()) {
            ItemMatchReasonBinding row = ItemMatchReasonBinding.inflate(
                    inflater, binding.containerReasons, false);
            row.txtReason.setText(reason.getText());
            row.txtReason.setTextColor(ContextCompat.getColor(this,
                    reason.isPositive() ? R.color.text_primary : R.color.text_secondary));
            row.imgIcon.setImageResource(reason.isPositive()
                    ? R.drawable.ic_check : R.drawable.ic_info);
            row.imgIcon.setImageTintList(android.content.res.ColorStateList.valueOf(
                    ContextCompat.getColor(this,
                            reason.isPositive() ? R.color.state_accepted : R.color.state_pending)));
            binding.containerReasons.addView(row.getRoot());
        }

        binding.btnRequest.setEnabled(match.getScore() > 0);
    }
}
