#!/usr/bin/env bash
set -e
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
mkdir -p "$J/view/home" "$J/view/matches"

# ============================================================ MainActivity
cat > "$J/view/MainActivity.java" <<'EOF'
package com.skillswap.view;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;

import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentTransaction;

import com.google.android.material.navigation.NavigationBarView;
import com.google.firebase.messaging.FirebaseMessaging;
import com.skillswap.R;
import com.skillswap.databinding.ActivityMainBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.repository.UserRepository;
import com.skillswap.utils.Constants;
import com.skillswap.view.chat.ChatsFragment;
import com.skillswap.view.exchange.ExchangesFragment;
import com.skillswap.view.home.HomeFragment;
import com.skillswap.view.matches.ExploreFragment;
import com.skillswap.view.profile.ProfileFragment;

/** Contenedor principal con BottomNavigationView. */
public class MainActivity extends BaseActivity {

    private ActivityMainBinding binding;

    private final HomeFragment homeFragment = new HomeFragment();
    private final ExploreFragment exploreFragment = new ExploreFragment();
    private final ExchangesFragment exchangesFragment = new ExchangesFragment();
    private final ChatsFragment chatsFragment = new ChatsFragment();
    private final ProfileFragment profileFragment = new ProfileFragment();

    private Fragment activeFragment = homeFragment;

    private final ActivityResultLauncher<String> notificationPermission =
            registerForActivityResult(new ActivityResultContracts.RequestPermission(),
                    new ActivityResultCallback<Boolean>() {
                        @Override
                        public void onActivityResult(Boolean granted) {
                            // El usuario decide; la app funciona igual sin el permiso.
                        }
                    });

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        UserRepository.get().listenCurrentUser();
        registerFcmToken();
        askNotificationPermission();
        setupFragments();

        binding.bottomNav.setOnItemSelectedListener(new NavigationBarView.OnItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(@NonNull android.view.MenuItem item) {
                int id = item.getItemId();
                if (id == R.id.nav_home) return show(homeFragment);
                if (id == R.id.nav_explore) return show(exploreFragment);
                if (id == R.id.nav_exchanges) return show(exchangesFragment);
                if (id == R.id.nav_chats) return show(chatsFragment);
                if (id == R.id.nav_profile) return show(profileFragment);
                return false;
            }
        });

        handleIntent(getIntent());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        handleIntent(intent);
    }

    private void handleIntent(Intent intent) {
        if (intent == null) return;
        String section = intent.getStringExtra(Constants.EXTRA_OPEN_SECTION);
        if (section == null) return;
        switch (section) {
            case "explore":
                binding.bottomNav.setSelectedItemId(R.id.nav_explore);
                break;
            case "exchanges":
                binding.bottomNav.setSelectedItemId(R.id.nav_exchanges);
                break;
            case "chats":
                binding.bottomNav.setSelectedItemId(R.id.nav_chats);
                break;
            case "profile":
                binding.bottomNav.setSelectedItemId(R.id.nav_profile);
                break;
            default:
                binding.bottomNav.setSelectedItemId(R.id.nav_home);
                break;
        }
    }

    /** Se anaden todos los fragments y se alternan con show/hide para conservar el estado. */
    private void setupFragments() {
        FragmentTransaction tx = getSupportFragmentManager().beginTransaction();
        tx.add(R.id.fragmentContainer, profileFragment, "profile").hide(profileFragment);
        tx.add(R.id.fragmentContainer, chatsFragment, "chats").hide(chatsFragment);
        tx.add(R.id.fragmentContainer, exchangesFragment, "exchanges").hide(exchangesFragment);
        tx.add(R.id.fragmentContainer, exploreFragment, "explore").hide(exploreFragment);
        tx.add(R.id.fragmentContainer, homeFragment, "home");
        tx.commit();
    }

    private boolean show(Fragment fragment) {
        if (fragment == activeFragment) return true;
        getSupportFragmentManager().beginTransaction()
                .setCustomAnimations(R.anim.fade_in, R.anim.fade_out)
                .hide(activeFragment)
                .show(fragment)
                .commit();
        activeFragment = fragment;
        return true;
    }

    /** Permite abrir la pestana Explorar desde otras pantallas. */
    public void openExplore() {
        binding.bottomNav.setSelectedItemId(R.id.nav_explore);
    }

    public void openExchanges() {
        binding.bottomNav.setSelectedItemId(R.id.nav_exchanges);
    }

    private void registerFcmToken() {
        final String uid = FirebaseManager.uid();
        if (uid.isEmpty()) return;
        FirebaseMessaging.getInstance().getToken()
                .addOnSuccessListener(token -> UserRepository.get().updateFcmToken(uid, token));
    }

    private void askNotificationPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return;
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS)
                == PackageManager.PERMISSION_GRANTED) return;
        notificationPermission.launch(Manifest.permission.POST_NOTIFICATIONS);
    }

    @Override
    public void onBackPressed() {
        if (activeFragment != homeFragment) {
            binding.bottomNav.setSelectedItemId(R.id.nav_home);
            return;
        }
        super.onBackPressed();
    }
}
EOF

# ============================================================ HomeFragment
cat > "$J/view/home/HomeFragment.java" <<'EOF'
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
        binding.quickRequests.quickLabel.setText("Solicitudes");
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
                binding.txtLevel.setText(user.getSkillPoints() + " SkillPoints · "
                        + (user.getGamificationLevel() == null || user.getGamificationLevel().isEmpty()
                        ? "Principiante" : user.getGamificationLevel()));
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

    private void openExploreWith(String skillName) {
        openExplore();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
EOF

# ============================================================ ExploreFragment
cat > "$J/view/matches/ExploreFragment.java" <<'EOF'
package com.skillswap.view.matches;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
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
import com.skillswap.adapter.MatchAdapter;
import com.skillswap.databinding.FragmentExploreBinding;
import com.skillswap.model.ExploreFilter;
import com.skillswap.model.MatchResult;
import com.skillswap.model.Resource;
import com.skillswap.utils.ChipFactory;
import com.skillswap.utils.Constants;
import com.skillswap.utils.UiUtils;
import com.skillswap.view.exchange.SendRequestActivity;
import com.skillswap.view.profile.UserProfileActivity;
import com.skillswap.viewmodel.ExploreViewModel;

import java.util.ArrayList;
import java.util.List;

/** Explorar estudiantes con SkillMatch, buscador y filtros. */
public class ExploreFragment extends Fragment {

    private FragmentExploreBinding binding;
    private ExploreViewModel viewModel;
    private MatchAdapter adapter;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        binding = FragmentExploreBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        viewModel = new ViewModelProvider(this).get(ExploreViewModel.class);

        adapter = new MatchAdapter(new MatchAdapter.OnMatchAction() {
            @Override
            public void onViewProfile(MatchResult match) {
                Intent intent = new Intent(requireContext(), UserProfileActivity.class);
                intent.putExtra(Constants.EXTRA_USER_ID, match.getUserBId());
                startActivity(intent);
            }

            @Override
            public void onExchange(MatchResult match) {
                Intent intent = new Intent(requireContext(), SendRequestActivity.class);
                intent.putExtra(Constants.EXTRA_USER_ID, match.getUserBId());
                startActivity(intent);
            }
        });
        binding.rvUsers.setLayoutManager(new LinearLayoutManager(requireContext()));
        binding.rvUsers.setAdapter(adapter);

        binding.swipeRefresh.setOnRefreshListener(() -> viewModel.load());

        binding.btnFilters.setOnClickListener(v -> {
            FiltersSheet sheet = FiltersSheet.newInstance(viewModel.currentFilter());
            sheet.setListener(filter -> viewModel.applyFilter(filter));
            sheet.show(getChildFragmentManager(), "filters");
        });

        if (binding.tilSearch.getEditText() != null) {
            binding.tilSearch.getEditText().addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                }

                @Override
                public void afterTextChanged(Editable s) {
                    viewModel.setQuery(s == null ? "" : s.toString());
                }
            });
        }

        observe();
        viewModel.load();
    }

    private void observe() {
        viewModel.results().observe(getViewLifecycleOwner(),
                new Observer<Resource<List<MatchResult>>>() {
                    @Override
                    public void onChanged(Resource<List<MatchResult>> state) {
                        if (state == null) return;
                        UiUtils.visible(binding.progress, state.isLoading());
                        if (state.isLoading()) return;

                        binding.swipeRefresh.setRefreshing(false);

                        if (state.isError()) {
                            UiUtils.snack(binding.getRoot(), state.getMessage());
                            return;
                        }

                        List<MatchResult> data = state.getData();
                        adapter.submit(data);
                        boolean empty = data == null || data.isEmpty();
                        UiUtils.visible(binding.empty.getRoot(), empty);
                        UiUtils.visible(binding.swipeRefresh, !empty);

                        int count = data == null ? 0 : data.size();
                        binding.txtCount.setText(count + (count == 1
                                ? " estudiante compatible" : " estudiantes compatibles"));

                        binding.empty.txtEmptyTitle.setText("Sin coincidencias");
                        binding.empty.txtEmptyDesc.setText(
                                "Agrega más habilidades a tu perfil o ajusta los filtros "
                                        + "para encontrar estudiantes compatibles.");
                        binding.empty.imgEmpty.setImageResource(R.drawable.ic_search);
                    }
                });

        viewModel.filter().observe(getViewLifecycleOwner(), new Observer<ExploreFilter>() {
            @Override
            public void onChanged(ExploreFilter filter) {
                renderActiveChips(filter);
            }
        });
    }

    private void renderActiveChips(ExploreFilter filter) {
        binding.chipGroupActive.removeAllViews();
        if (filter == null) return;

        List<String[]> active = new ArrayList<>();
        if (notBlank(filter.getCategory())) active.add(new String[]{"category", filter.getCategory()});
        if (notBlank(filter.getSkill())) active.add(new String[]{"skill", filter.getSkill()});
        if (notBlank(filter.getLevel())) active.add(new String[]{"level", filter.getLevel()});
        if (notBlank(filter.getModality())) active.add(new String[]{"modality", filter.getModality()});
        if (notBlank(filter.getUniversity())) active.add(new String[]{"university", filter.getUniversity()});
        if (filter.getMinCompatibility() > 0) {
            active.add(new String[]{"min", filter.getMinCompatibility() + " % o más"});
        }

        for (String[] entry : active) {
            binding.chipGroupActive.addView(ChipFactory.removableChip(
                    requireContext(), entry[1], entry[0], value -> removeFilter(value)));
        }
    }

    private void removeFilter(String key) {
        ExploreFilter f = viewModel.currentFilter();
        switch (key) {
            case "category": f.setCategory(""); break;
            case "skill": f.setSkill(""); break;
            case "level": f.setLevel(""); break;
            case "modality": f.setModality(""); break;
            case "university": f.setUniversity(""); break;
            case "min": f.setMinCompatibility(0); break;
            default: break;
        }
        viewModel.applyFilter(f);
    }

    private boolean notBlank(String s) {
        return s != null && !s.trim().isEmpty();
    }

    @Override
    public void onResume() {
        super.onResume();
        if (viewModel != null) viewModel.load();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
EOF

# ============================================================ FiltersSheet
cat > "$J/view/matches/FiltersSheet.java" <<'EOF'
package com.skillswap.view.matches;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.google.android.material.chip.Chip;
import com.skillswap.R;
import com.skillswap.databinding.SheetFiltersBinding;
import com.skillswap.model.ExploreFilter;
import com.skillswap.utils.ChipFactory;
import com.skillswap.utils.Constants;
import com.skillswap.utils.SkillCatalog;

import java.util.ArrayList;
import java.util.List;

/** Hoja inferior con los filtros de la pantalla Explorar. */
public class FiltersSheet extends BottomSheetDialogFragment {

    public interface OnFiltersApplied {
        void onApplied(ExploreFilter filter);
    }

    private static final String ARG_FILTER = "arg_filter";

    private SheetFiltersBinding binding;
    private ExploreFilter filter = new ExploreFilter();
    private OnFiltersApplied listener;

    public static FiltersSheet newInstance(ExploreFilter current) {
        FiltersSheet sheet = new FiltersSheet();
        Bundle args = new Bundle();
        args.putSerializable(ARG_FILTER, current);
        sheet.setArguments(args);
        return sheet;
    }

    public void setListener(OnFiltersApplied listener) {
        this.listener = listener;
    }

    @Override
    public int getTheme() {
        return R.style.Theme_SkillSwap_BottomSheet;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        binding = SheetFiltersBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        if (getArguments() != null && getArguments().getSerializable(ARG_FILTER) != null) {
            filter = (ExploreFilter) getArguments().getSerializable(ARG_FILTER);
        }

        buildCategories();
        buildSkills();
        restoreSelection();

        binding.sliderMin.addOnChangeListener((slider, value, fromUser) ->
                binding.txtMinValue.setText(((int) value) + " %"));

        binding.btnClear.setOnClickListener(v -> {
            filter.clearFilters();
            if (listener != null) listener.onApplied(filter);
            dismiss();
        });

        binding.btnApply.setOnClickListener(v -> {
            collect();
            if (listener != null) listener.onApplied(filter);
            dismiss();
        });
    }

    private void buildCategories() {
        binding.chipsCategory.removeAllViews();
        for (String category : SkillCatalog.getCategories()) {
            Chip chip = ChipFactory.choiceChip(requireContext(), category,
                    category.equals(filter.getCategory()));
            chip.setTag(category);
            binding.chipsCategory.addView(chip);
        }
    }

    private void buildSkills() {
        List<String> skills = new ArrayList<>();
        skills.add("Todas");
        skills.addAll(SkillCatalog.getAllSkillNames());
        ArrayAdapter<String> adapter = new ArrayAdapter<>(requireContext(),
                android.R.layout.simple_list_item_1, skills);
        if (binding.tilSkill.getEditText() instanceof
                com.google.android.material.textfield.MaterialAutoCompleteTextView) {
            ((com.google.android.material.textfield.MaterialAutoCompleteTextView)
                    binding.tilSkill.getEditText()).setAdapter(adapter);
        }
        if (binding.tilSkill.getEditText() != null
                && filter.getSkill() != null && !filter.getSkill().isEmpty()) {
            binding.tilSkill.getEditText().setText(filter.getSkill(), false);
        }
    }

    private void restoreSelection() {
        binding.chipLvlBasic.setChecked(Constants.LEVEL_BASIC.equals(filter.getLevel()));
        binding.chipLvlIntermediate.setChecked(Constants.LEVEL_INTERMEDIATE.equals(filter.getLevel()));
        binding.chipLvlAdvanced.setChecked(Constants.LEVEL_ADVANCED.equals(filter.getLevel()));

        binding.chipModPresencial.setChecked(Constants.MODALITY_PRESENCIAL.equals(filter.getModality()));
        binding.chipModVirtual.setChecked(Constants.MODALITY_VIRTUAL.equals(filter.getModality()));

        if (binding.tilUniversity.getEditText() != null) {
            binding.tilUniversity.getEditText().setText(filter.getUniversity());
        }
        binding.sliderMin.setValue(filter.getMinCompatibility());
        binding.txtMinValue.setText(filter.getMinCompatibility() + " %");
    }

    private void collect() {
        String category = "";
        for (int i = 0; i < binding.chipsCategory.getChildCount(); i++) {
            Chip chip = (Chip) binding.chipsCategory.getChildAt(i);
            if (chip.isChecked()) category = String.valueOf(chip.getTag());
        }
        filter.setCategory(category);

        String skill = binding.tilSkill.getEditText() == null ? ""
                : binding.tilSkill.getEditText().getText().toString();
        filter.setSkill("Todas".equals(skill) ? "" : skill);

        if (binding.chipLvlBasic.isChecked()) filter.setLevel(Constants.LEVEL_BASIC);
        else if (binding.chipLvlIntermediate.isChecked()) filter.setLevel(Constants.LEVEL_INTERMEDIATE);
        else if (binding.chipLvlAdvanced.isChecked()) filter.setLevel(Constants.LEVEL_ADVANCED);
        else filter.setLevel("");

        if (binding.chipModPresencial.isChecked()) filter.setModality(Constants.MODALITY_PRESENCIAL);
        else if (binding.chipModVirtual.isChecked()) filter.setModality(Constants.MODALITY_VIRTUAL);
        else filter.setModality("");

        filter.setUniversity(binding.tilUniversity.getEditText() == null ? ""
                : binding.tilUniversity.getEditText().getText().toString().trim());
        filter.setMinCompatibility((int) binding.sliderMin.getValue());
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
EOF

echo "Vistas 2 (main/home/explorar) generadas."
