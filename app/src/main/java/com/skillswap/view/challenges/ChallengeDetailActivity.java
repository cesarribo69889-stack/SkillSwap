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
        binding.txtDeadline.setText(getResources().getQuantityString(
                R.plurals.plu_deadline_participants, c.getMaxParticipants(),
                DateUtils.daysLeft(c.getDeadline()),
                c.getParticipantsCount(), c.getMaxParticipants()));
        binding.progressBar.setProgress(c.getProgress());
        binding.txtProgress.setText(getString(R.string.fmt_progress_advance, c.getProgress()));

        ChipFactory.fillTexts(binding.chipsSkills, c.getRequiredSkills());

        boolean owner = myUid.equals(c.getCreatorId());
        UiUtils.visible(binding.ownerBox, owner);
        if (owner) binding.sliderProgress.setValue(c.getProgress());

        boolean joined = c.getParticipantIds().contains(myUid);
        if (owner) {
            binding.btnJoin.setEnabled(false);
            binding.btnJoin.setText(R.string.st_you_are_organizer);
        } else if (joined) {
            binding.btnJoin.setEnabled(false);
            binding.btnJoin.setText(R.string.st_already_joined_long);
        } else if (c.isFull()) {
            binding.btnJoin.setEnabled(false);
            binding.btnJoin.setText(R.string.st_team_full);
        } else if (!Challenge.STATUS_OPEN.equals(c.getStatus())) {
            binding.btnJoin.setEnabled(false);
            binding.btnJoin.setText(R.string.st_applications_closed);
        } else {
            binding.btnJoin.setEnabled(true);
            binding.btnJoin.setText(R.string.lbl_join_challenge);
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
