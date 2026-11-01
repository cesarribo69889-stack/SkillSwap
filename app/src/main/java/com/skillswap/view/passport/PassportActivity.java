package com.skillswap.view.passport;

import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.skillswap.R;
import com.skillswap.adapter.BadgeAdapter;
import com.skillswap.adapter.EvidenceAdapter;
import com.skillswap.adapter.PassportAdapter;
import com.skillswap.databinding.ActivityPassportBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Badge;
import com.skillswap.model.LearningEvidence;
import com.skillswap.model.PassportEntry;
import com.skillswap.utils.Constants;
import com.skillswap.utils.UiUtils;
import com.skillswap.view.BaseActivity;
import com.skillswap.viewmodel.PassportViewModel;

import java.util.List;

/**
 * INNOVACION 2 - Pasaporte de Habilidades.
 * Refleja actividad real dentro de SkillSwap; no es una certificacion academica.
 */
public class PassportActivity extends BaseActivity {

    private ActivityPassportBinding binding;
    private PassportViewModel viewModel;
    private PassportAdapter passportAdapter;
    private BadgeAdapter badgeAdapter;
    private EvidenceAdapter evidenceAdapter;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityPassportBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        viewModel = new ViewModelProvider(this).get(PassportViewModel.class);
        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.passport));

        passportAdapter = new PassportAdapter();
        binding.rvPassport.setLayoutManager(new LinearLayoutManager(this));
        binding.rvPassport.setAdapter(passportAdapter);

        badgeAdapter = new BadgeAdapter(badge -> showBadge(badge));
        binding.rvBadges.setLayoutManager(
                new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false));
        binding.rvBadges.setAdapter(badgeAdapter);

        evidenceAdapter = new EvidenceAdapter();
        binding.rvEvidence.setLayoutManager(new LinearLayoutManager(this));
        binding.rvEvidence.setAdapter(evidenceAdapter);

        observe();

        String uid = getIntent().getStringExtra(Constants.EXTRA_USER_ID);
        viewModel.start(uid == null ? FirebaseManager.uid() : uid);
    }

    private void observe() {
        viewModel.entries().observe(this, new Observer<List<PassportEntry>>() {
            @Override
            public void onChanged(List<PassportEntry> entries) {
                passportAdapter.submit(entries);

                boolean empty = entries == null || entries.isEmpty();
                UiUtils.visible(binding.txtEmpty, empty);
                UiUtils.visible(binding.rvPassport, !empty);

                int taught = 0;
                int learned = 0;
                int exchanges = 0;
                if (entries != null) {
                    for (PassportEntry e : entries) {
                        if (PassportEntry.ROLE_TAUGHT.equals(e.getRole())) taught++;
                        else if (PassportEntry.ROLE_LEARNED.equals(e.getRole())) learned++;
                        exchanges += e.getExchangesCount();
                    }
                }
                binding.txtTaughtCount.setText(String.valueOf(taught));
                binding.txtLearnedCount.setText(String.valueOf(learned));
                binding.txtExchangesCount.setText(String.valueOf(exchanges / 2));
            }
        });

        viewModel.badges().observe(this, new Observer<List<Badge>>() {
            @Override
            public void onChanged(List<Badge> badges) {
                badgeAdapter.submit(badges);
            }
        });

        viewModel.evidences().observe(this, new Observer<List<LearningEvidence>>() {
            @Override
            public void onChanged(List<LearningEvidence> list) {
                evidenceAdapter.submit(list);
            }
        });
    }

    private void showBadge(Badge badge) {
        new MaterialAlertDialogBuilder(this)
                .setTitle(badge.getName())
                .setMessage(badge.getDescription()
                        + (badge.isUnlocked() ? "\n\n✓ Desbloqueada" : "\n\n🔒 Aún bloqueada"))
                .setPositiveButton("Entendido", null)
                .show();
    }
}
