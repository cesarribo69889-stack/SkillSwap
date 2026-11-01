#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
mkdir -p "$J/view/passport" "$J/view/challenges"

# ============================================================ PassportActivity
cat > "$J/view/passport/PassportActivity.java" <<'EOF'
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
EOF

# ============================================================ SkillPointsActivity
cat > "$J/view/passport/SkillPointsActivity.java" <<'EOF'
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
EOF

# ============================================================ ChallengesActivity
cat > "$J/view/challenges/ChallengesActivity.java" <<'EOF'
package com.skillswap.view.challenges;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.skillswap.R;
import com.skillswap.adapter.ChallengeAdapter;
import com.skillswap.databinding.ActivityChallengesBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Challenge;
import com.skillswap.utils.Constants;
import com.skillswap.utils.UiUtils;
import com.skillswap.view.BaseActivity;
import com.skillswap.viewmodel.ChallengesViewModel;

import java.util.List;

/** INNOVACION 5 - Skill Challenges. */
public class ChallengesActivity extends BaseActivity {

    private ActivityChallengesBinding binding;
    private ChallengesViewModel viewModel;
    private ChallengeAdapter adapter;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityChallengesBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        viewModel = new ViewModelProvider(this).get(ChallengesViewModel.class);
        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.challenges));

        adapter = new ChallengeAdapter(FirebaseManager.uid(),
                new ChallengeAdapter.OnChallengeAction() {
                    @Override
                    public void onOpen(Challenge challenge) {
                        openDetail(challenge);
                    }

                    @Override
                    public void onJoin(Challenge challenge) {
                        openDetail(challenge);
                    }
                });
        binding.rvChallenges.setLayoutManager(new LinearLayoutManager(this));
        binding.rvChallenges.setAdapter(adapter);

        binding.fabCreate.setOnClickListener(v ->
                startActivity(new Intent(this, CreateChallengeActivity.class)));

        binding.swipeRefresh.setOnRefreshListener(() -> {
            viewModel.start();
            binding.swipeRefresh.setRefreshing(false);
        });

        viewModel.challenges().observe(this, new Observer<List<Challenge>>() {
            @Override
            public void onChanged(List<Challenge> challenges) {
                adapter.submit(challenges);
                boolean empty = challenges == null || challenges.isEmpty();
                UiUtils.visible(binding.empty.getRoot(), empty);
                UiUtils.visible(binding.swipeRefresh, !empty);
                binding.empty.imgEmpty.setImageResource(R.drawable.ic_challenge);
                binding.empty.txtEmptyTitle.setText("Aún no hay retos");
                binding.empty.txtEmptyDesc.setText(
                        "Crea el primero: define un objetivo, las habilidades que necesitas "
                                + "y arma tu equipo.");
            }
        });

        viewModel.start();
    }

    private void openDetail(Challenge challenge) {
        Intent intent = new Intent(this, ChallengeDetailActivity.class);
        intent.putExtra(Constants.EXTRA_CHALLENGE_ID, challenge.getId());
        startActivity(intent);
    }
}
EOF

# ============================================================ ChallengeDetailActivity
cat > "$J/view/challenges/ChallengeDetailActivity.java" <<'EOF'
package com.skillswap.view.challenges;

import android.os.Bundle;
import android.widget.ArrayAdapter;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.android.material.textfield.MaterialAutoCompleteTextView;
import com.google.android.material.textfield.TextInputLayout;
import com.skillswap.R;
import com.skillswap.adapter.ChallengeParticipantAdapter;
import com.skillswap.databinding.ActivityChallengeDetailBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Challenge;
import com.skillswap.model.ChallengeParticipant;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.model.UserSkill;
import com.skillswap.repository.UserRepository;
import com.skillswap.utils.ChipFactory;
import com.skillswap.utils.Constants;
import com.skillswap.utils.DateUtils;
import com.skillswap.utils.UiUtils;
import com.skillswap.view.BaseActivity;
import com.skillswap.viewmodel.ChallengesViewModel;

import java.util.ArrayList;
import java.util.List;

/** Detalle de un Skill Challenge: equipo, avance y postulaciones. */
public class ChallengeDetailActivity extends BaseActivity {

    private ActivityChallengeDetailBinding binding;
    private ChallengesViewModel viewModel;
    private ChallengeParticipantAdapter adapter;
    private Challenge challenge;
    private final String myUid = FirebaseManager.uid();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityChallengeDetailBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        String challengeId = getIntent().getStringExtra(Constants.EXTRA_CHALLENGE_ID);
        viewModel = new ViewModelProvider(this).get(ChallengesViewModel.class);

        setupToolbar(binding.toolbarInc.toolbar, "Reto colaborativo");

        adapter = new ChallengeParticipantAdapter((participant, accept) -> {
            if (challenge == null) return;
            viewModel.respond(challenge, participant, accept);
        });
        binding.rvParticipants.setLayoutManager(new LinearLayoutManager(this));
        binding.rvParticipants.setAdapter(adapter);

        binding.btnJoin.setOnClickListener(v -> askToJoin());

        binding.sliderProgress.addOnChangeListener((slider, value, fromUser) -> {
            if (!fromUser || challenge == null) return;
            viewModel.updateProgress(challenge.getId(), (int) value);
        });

        observe();
        if (challengeId != null) viewModel.observeDetail(challengeId);
    }

    private void observe() {
        viewModel.detail().observe(this, new Observer<Challenge>() {
            @Override
            public void onChanged(Challenge data) {
                if (data == null) return;
                challenge = data;
                render(data);
            }
        });

        viewModel.participants().observe(this, new Observer<List<ChallengeParticipant>>() {
            @Override
            public void onChanged(List<ChallengeParticipant> list) {
                adapter.setOwner(challenge != null && myUid.equals(challenge.getCreatorId()));
                adapter.submit(list);
            }
        });

        viewModel.joinState().observe(this, new Observer<Resource<Boolean>>() {
            @Override
            public void onChanged(Resource<Boolean> state) {
                if (state == null) return;
                binding.btnJoin.setEnabled(!state.isLoading());
                if (state.isSuccess()) {
                    toast(binding.getRoot(), "Listo, tu postulación fue enviada");
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });
    }

    private void render(Challenge c) {
        binding.txtTitle.setText(c.getTitle());
        binding.txtObjective.setText(c.getObjective());
        binding.txtDescription.setText(c.getDescription());
        binding.txtDeadline.setText(DateUtils.daysLeft(c.getDeadline())
                + " · " + c.getParticipantsCount() + "/" + c.getMaxParticipants() + " participantes");
        binding.progressBar.setProgress(c.getProgress());
        binding.txtProgress.setText("Avance: " + c.getProgress() + " %");

        ChipFactory.fillTexts(binding.chipsSkills, c.getRequiredSkills());

        boolean owner = myUid.equals(c.getCreatorId());
        UiUtils.visible(binding.ownerBox, owner);
        if (owner) binding.sliderProgress.setValue(c.getProgress());

        boolean joined = c.getParticipantIds().contains(myUid);
        if (owner) {
            binding.btnJoin.setEnabled(false);
            binding.btnJoin.setText("Eres el organizador");
        } else if (joined) {
            binding.btnJoin.setEnabled(false);
            binding.btnJoin.setText("Ya participas en este reto");
        } else if (c.isFull()) {
            binding.btnJoin.setEnabled(false);
            binding.btnJoin.setText("Equipo completo");
        } else if (!Challenge.STATUS_OPEN.equals(c.getStatus())) {
            binding.btnJoin.setEnabled(false);
            binding.btnJoin.setText("Postulaciones cerradas");
        } else {
            binding.btnJoin.setEnabled(true);
            binding.btnJoin.setText("Quiero participar");
        }
    }

    /** Dialogo para elegir con qué habilidad aportará el estudiante. */
    private void askToJoin() {
        if (challenge == null) return;

        User me = UserRepository.get().currentUserValue();
        final List<String> options = new ArrayList<>();
        if (me != null) {
            for (UserSkill s : me.getTeachSkills()) options.add(s.getName());
        }
        if (options.isEmpty()) {
            info("Agrega habilidades primero",
                    "Para unirte a un reto necesitas registrar al menos una habilidad "
                            + "que puedas enseñar.");
            return;
        }

        TextInputLayout layout = new TextInputLayout(this, null,
                com.google.android.material.R.style
                        .Widget_Material3_TextInputLayout_OutlinedBox_ExposedDropdownMenu);
        MaterialAutoCompleteTextView field = new MaterialAutoCompleteTextView(this);
        field.setHint("Elige tu aporte");
        field.setInputType(0);
        field.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, options));
        field.setText(options.get(0), false);
        layout.setPadding(UiUtils.dp(this, 24), UiUtils.dp(this, 8),
                UiUtils.dp(this, 24), 0);
        layout.addView(field);

        new MaterialAlertDialogBuilder(this)
                .setTitle("Unirme al reto")
                .setMessage(challenge.getTitle())
                .setView(layout)
                .setNegativeButton(R.string.cancel, null)
                .setPositiveButton("Postular", (dialog, which) ->
                        viewModel.requestJoin(challenge, field.getText().toString(),
                                "Quiero aportar en este reto"))
                .show();
    }
}
EOF

# ============================================================ CreateChallengeActivity
cat > "$J/view/challenges/CreateChallengeActivity.java" <<'EOF'
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
EOF

echo "Vistas 8 (pasaporte/skillpoints/retos) generadas."
