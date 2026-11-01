package com.skillswap.view.passport;

import android.content.res.ColorStateList;
import android.os.Bundle;
import android.view.LayoutInflater;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.skillswap.R;
import com.skillswap.adapter.PointEntryAdapter;
import com.skillswap.databinding.ActivitySkillPointsBinding;
import com.skillswap.databinding.ItemLevelBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.PointEntry;
import com.skillswap.model.SkillPointsAccount;
import com.skillswap.utils.GamificationEngine;
import com.skillswap.view.BaseActivity;
import com.skillswap.viewmodel.PassportViewModel;

import java.util.List;

/**
 * INNOVACION 4 - SkillPoints.
 * Puntos de reconocimiento dentro de la app: NO son dinero.
 */
public class SkillPointsActivity extends BaseActivity {

    private static final String[] LEVEL_NAMES = {
            GamificationEngine.LEVEL_BEGINNER,
            GamificationEngine.LEVEL_COLLABORATOR,
            GamificationEngine.LEVEL_MENTOR,
            GamificationEngine.LEVEL_MASTER
    };
    private static final String[] LEVEL_RANGES = {
            "0 - 99 pts", "100 - 299 pts", "300 - 699 pts", "700+ pts"
    };

    private ActivitySkillPointsBinding binding;
    private PassportViewModel viewModel;
    private PointEntryAdapter adapter;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivitySkillPointsBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        viewModel = new ViewModelProvider(this).get(PassportViewModel.class);
        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.skillpoints));

        adapter = new PointEntryAdapter();
        binding.rvHistory.setLayoutManager(new LinearLayoutManager(this));
        binding.rvHistory.setAdapter(adapter);

        viewModel.account().observe(this, new Observer<SkillPointsAccount>() {
            @Override
            public void onChanged(SkillPointsAccount account) {
                if (account == null) return;
                render(account);
            }
        });

        viewModel.history().observe(this, new Observer<List<PointEntry>>() {
            @Override
            public void onChanged(List<PointEntry> list) {
                adapter.submit(list);
            }
        });

        viewModel.start(FirebaseManager.uid());
    }

    private void render(SkillPointsAccount account) {
        binding.txtPoints.setText(String.valueOf(account.getPoints()));
        binding.txtLevel.setText(account.getLevel());
        binding.txtLevel.setTextColor(ContextCompat.getColor(this, R.color.white));
        binding.txtLevel.setBackgroundTintList(ColorStateList.valueOf(0x55FFFFFF));

        int progress = GamificationEngine.levelProgress(account.getPoints());
        binding.progressLevel.setProgress(progress);

        int next = GamificationEngine.nextLevelThreshold(account.getPoints());
        binding.txtNextLevel.setText(next == 0
                ? "Alcanzaste el nivel máximo 🏆"
                : "Te faltan " + (next - account.getPoints()) + " puntos para "
                + GamificationEngine.levelNameFor(next));

        renderLevels(account.getLevelIndex());
    }

    private void renderLevels(int currentIndex) {
        binding.containerLevels.removeAllViews();
        LayoutInflater inflater = LayoutInflater.from(this);
        for (int i = 0; i < LEVEL_NAMES.length; i++) {
            ItemLevelBinding row = ItemLevelBinding.inflate(
                    inflater, binding.containerLevels, false);
            row.txtLevel.setText(LEVEL_NAMES[i]);
            row.txtRange.setText(LEVEL_RANGES[i]);

            boolean reached = i <= currentIndex;
            int color = ContextCompat.getColor(this,
                    reached ? R.color.brand_primary : R.color.text_tertiary);
            row.imgIcon.setImageResource(reached
                    ? R.drawable.ic_check_circle : R.drawable.ic_trophy);
            row.imgIcon.setImageTintList(ColorStateList.valueOf(color));
            row.getRoot().setAlpha(reached ? 1f : 0.6f);

            binding.containerLevels.addView(row.getRoot());
        }
    }
}
