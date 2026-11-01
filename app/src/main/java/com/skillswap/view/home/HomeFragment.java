package com.skillswap.view.home;

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
import androidx.recyclerview.widget.LinearLayoutManager;

import com.skillswap.R;
import com.skillswap.adapter.ChallengeHomeAdapter;
import com.skillswap.adapter.ExchangeAdapter;
import com.skillswap.adapter.MatchHomeAdapter;
import com.skillswap.adapter.PopularSkillAdapter;
import com.skillswap.databinding.FragmentHomeBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Challenge;
import com.skillswap.model.Exchange;
import com.skillswap.model.MatchResult;
import com.skillswap.model.User;
import com.skillswap.utils.Constants;
import com.skillswap.utils.SkillCatalog;
import com.skillswap.utils.UiUtils;
import com.skillswap.view.MainActivity;
import com.skillswap.view.challenges.ChallengeDetailActivity;
import com.skillswap.view.challenges.ChallengesActivity;
import com.skillswap.view.chat.ChatActivity;
import com.skillswap.view.exchange.ExchangeDetailActivity;
import com.skillswap.view.exchange.RequestsActivity;
import com.skillswap.view.matches.MatchDetailActivity;
import com.skillswap.view.notifications.NotificationsActivity;
import com.skillswap.view.passport.PassportActivity;
import com.skillswap.view.passport.SkillPointsActivity;
import com.skillswap.viewmodel.HomeViewModel;

import java.util.List;

/** Pantalla de Inicio. */
public class HomeFragment extends Fragment {

    private FragmentHomeBinding binding;
    private HomeViewModel viewModel;

    private PopularSkillAdapter popularAdapter;
    private MatchHomeAdapter matchAdapter;
    private ExchangeAdapter exchangeAdapter;
    private ChallengeHomeAdapter challengeAdapter;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        binding = FragmentHomeBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        viewModel = new ViewModelProvider(this).get(HomeViewModel.class);

        setupQuickActions();
        setupLists();
        setupListeners();
        observe();

        viewModel.start();
    }

    private void setupQuickActions() {
        binding.quickPassport.quickIcon.setImageResource(R.drawable.ic_passport);
        binding.quickPassport.quickLabel.setText(R.string.passport);
        binding.quickPassport.getRoot().setOnClickListener(v ->
                startActivity(new Intent(requireContext(), PassportActivity.class)));

        binding.quickPoints.quickIcon.setImageResource(R.drawable.ic_points);
        binding.quickPoints.quickLabel.setText(R.string.skillpoints);
        binding.quickPoints.getRoot().setOnClickListener(v ->
                startActivity(new Intent(requireContext(), SkillPointsActivity.class)));

        binding.quickChallenges.quickIcon.setImageResource(R.drawable.ic_challenge);
        binding.quickChallenges.quickLabel.setText(R.string.challenges);
        binding.quickChallenges.getRoot().setOnClickListener(v ->
                startActivity(new Intent(requireContext(), ChallengesActivity.class)));

        binding.quickRequests.quickIcon.setImageResource(R.drawable.ic_inbox);
        binding.quickRequests.quickLabel.setText(R.string.lbl_requests);
        binding.quickRequests.getRoot().setOnClickListener(v ->
                startActivity(new Intent(requireContext(), RequestsActivity.class)));
    }

    private void setupLists() {
        popularAdapter = new PopularSkillAdapter(skillName -> openExploreWith(skillName));
        binding.rvPopular.setLayoutManager(
                new LinearLayoutManager(requireContext(), LinearLayoutManager.HORIZONTAL, false));
        binding.rvPopular.setAdapter(popularAdapter);
        popularAdapter.submit(SkillCatalog.getPopular());

        matchAdapter = new MatchHomeAdapter(match -> {
            Intent intent = new Intent(requireContext(), MatchDetailActivity.class);
            intent.putExtra(Constants.EXTRA_USER_ID, match.getUserBId());
            startActivity(intent);
        });
        binding.rvMatches.setLayoutManager(
                new LinearLayoutManager(requireContext(), LinearLayoutManager.HORIZONTAL, false));
        binding.rvMatches.setAdapter(matchAdapter);

        exchangeAdapter = new ExchangeAdapter(FirebaseManager.uid(),
                new ExchangeAdapter.OnExchangeAction() {
                    @Override
                    public void onOpenChat(Exchange exchange) {
                        Intent intent = new Intent(requireContext(), ChatActivity.class);
                        intent.putExtra(Constants.EXTRA_CHAT_ID,
                                exchange.getChatId().isEmpty()
                                        ? exchange.getId() : exchange.getChatId());
                        startActivity(intent);
                    }

                    @Override
                    public void onOpenDetail(Exchange exchange) {
                        Intent intent = new Intent(requireContext(), ExchangeDetailActivity.class);
                        intent.putExtra(Constants.EXTRA_EXCHANGE_ID, exchange.getId());
                        startActivity(intent);
                    }
                });
        binding.rvActiveExchanges.setLayoutManager(new LinearLayoutManager(requireContext()));
        binding.rvActiveExchanges.setAdapter(exchangeAdapter);

        challengeAdapter = new ChallengeHomeAdapter(challenge -> {
            Intent intent = new Intent(requireContext(), ChallengeDetailActivity.class);
            intent.putExtra(Constants.EXTRA_CHALLENGE_ID, challenge.getId());
            startActivity(intent);
        });
        binding.rvChallenges.setLayoutManager(
                new LinearLayoutManager(requireContext(), LinearLayoutManager.HORIZONTAL, false));
        binding.rvChallenges.setAdapter(challengeAdapter);
    }

    private void setupListeners() {
        binding.swipeRefresh.setOnRefreshListener(() -> {
            viewModel.loadMatches();
            binding.swipeRefresh.setRefreshing(false);
        });

        binding.cardSearch.setOnClickListener(v -> openExplore());
        binding.btnAllMatches.setOnClickListener(v -> openExplore());
        binding.btnAllChallenges.setOnClickListener(v ->
                startActivity(new Intent(requireContext(), ChallengesActivity.class)));
        binding.btnNotifications.setOnClickListener(v ->
                startActivity(new Intent(requireContext(), NotificationsActivity.class)));
    }

    private void observe() {
        viewModel.currentUser().observe(getViewLifecycleOwner(), new Observer<User>() {
            @Override
            public void onChanged(User user) {
                if (user == null) return;
                binding.txtGreeting.setText(getString(R.string.home_greeting, user.getShortName()));
                binding.txtLevel.setText(getString(R.string.fmt_points_level,
                        user.getSkillPoints(),
                        user.getGamificationLevel() == null
                                || user.getGamificationLevel().isEmpty()
                                ? getString(R.string.st_level_beginner)
                                : user.getGamificationLevel()));
                com.skillswap.utils.ImageLoader.avatar(binding.imgAvatar, user.getPhotoUrl());
                viewModel.loadMatches();
            }
        });

        viewModel.topMatches().observe(getViewLifecycleOwner(), new Observer<List<MatchResult>>() {
            @Override
            public void onChanged(List<MatchResult> matches) {
                matchAdapter.submit(matches);
                boolean empty = matches == null || matches.isEmpty();
                UiUtils.visible(binding.txtNoMatches, empty);
                UiUtils.visible(binding.rvMatches, !empty);
            }
        });

        viewModel.activeExchanges().observe(getViewLifecycleOwner(), new Observer<List<Exchange>>() {
            @Override
            public void onChanged(List<Exchange> exchanges) {
                exchangeAdapter.submit(exchanges);
                boolean empty = exchanges == null || exchanges.isEmpty();
                UiUtils.visible(binding.txtNoExchanges, empty);
                UiUtils.visible(binding.rvActiveExchanges, !empty);
            }
        });

        viewModel.challenges().observe(getViewLifecycleOwner(), new Observer<List<Challenge>>() {
            @Override
            public void onChanged(List<Challenge> challenges) {
                challengeAdapter.submit(challenges);
            }
        });

        viewModel.unreadNotifications().observe(getViewLifecycleOwner(), new Observer<Integer>() {
            @Override
            public void onChanged(Integer count) {
                boolean show = count != null && count > 0;
                UiUtils.visible(binding.txtNotifBadge, show);
                if (show) {
                    binding.txtNotifBadge.setText(count > 9 ? "9+" : String.valueOf(count));
                }
            }
        });
    }

    private void openExplore() {
        if (getActivity() instanceof MainActivity) {
            ((MainActivity) getActivity()).openExplore();
        }
    }

    /** Abre Explorar filtrado por la habilidad popular que se tocó. */
    private void openExploreWith(String skillName) {
        if (getActivity() instanceof MainActivity) {
            ((MainActivity) getActivity()).openExploreWithSkill(skillName);
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
