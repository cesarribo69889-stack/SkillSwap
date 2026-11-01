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
                binding.empty.txtEmptyTitle.setText(R.string.empty_title_challenges);
                binding.empty.txtEmptyDesc.setText(R.string.empty_desc_challenges);
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
