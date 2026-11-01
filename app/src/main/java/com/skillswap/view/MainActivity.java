package com.skillswap.view;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;

import androidx.activity.OnBackPressedCallback;
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

    private static final String TAG_HOME = "home";
    private static final String TAG_EXPLORE = "explore";
    private static final String TAG_EXCHANGES = "exchanges";
    private static final String TAG_CHATS = "chats";
    private static final String TAG_PROFILE = "profile";

    private Fragment homeFragment;
    private Fragment exploreFragment;
    private Fragment exchangesFragment;
    private Fragment chatsFragment;
    private Fragment profileFragment;

    private Fragment activeFragment;

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
        setupBackNavigation();

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

    /**
     * Se anaden los cinco fragments una sola vez y se alternan con show/hide
     * para conservar su estado. Tras un cambio de configuracion el
     * FragmentManager ya los restauro, asi que se reutilizan por tag.
     */
    private void setupFragments() {
        androidx.fragment.app.FragmentManager fm = getSupportFragmentManager();

        homeFragment = fm.findFragmentByTag(TAG_HOME);
        exploreFragment = fm.findFragmentByTag(TAG_EXPLORE);
        exchangesFragment = fm.findFragmentByTag(TAG_EXCHANGES);
        chatsFragment = fm.findFragmentByTag(TAG_CHATS);
        profileFragment = fm.findFragmentByTag(TAG_PROFILE);

        if (homeFragment != null) {
            // Restauracion: el fragment visible es el que no esta oculto.
            activeFragment = homeFragment;
            for (Fragment f : new Fragment[]{homeFragment, exploreFragment,
                    exchangesFragment, chatsFragment, profileFragment}) {
                if (f != null && !f.isHidden()) {
                    activeFragment = f;
                    break;
                }
            }
            return;
        }

        homeFragment = new HomeFragment();
        exploreFragment = new ExploreFragment();
        exchangesFragment = new ExchangesFragment();
        chatsFragment = new ChatsFragment();
        profileFragment = new ProfileFragment();

        FragmentTransaction tx = fm.beginTransaction();
        tx.add(R.id.fragmentContainer, profileFragment, TAG_PROFILE).hide(profileFragment);
        tx.add(R.id.fragmentContainer, chatsFragment, TAG_CHATS).hide(chatsFragment);
        tx.add(R.id.fragmentContainer, exchangesFragment, TAG_EXCHANGES).hide(exchangesFragment);
        tx.add(R.id.fragmentContainer, exploreFragment, TAG_EXPLORE).hide(exploreFragment);
        tx.add(R.id.fragmentContainer, homeFragment, TAG_HOME);
        tx.commit();

        activeFragment = homeFragment;
    }

    private boolean show(Fragment fragment) {
        if (fragment == null || fragment == activeFragment) return true;
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

    /** Abre Explorar ya filtrado por una habilidad concreta. */
    public void openExploreWithSkill(String skillName) {
        openExplore();
        if (exploreFragment instanceof ExploreFragment) {
            ((ExploreFragment) exploreFragment).filterBySkill(skillName);
        }
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

    /**
     * El boton/gesto de retroceso vuelve primero a Inicio y solo despues sale.
     * Se usa OnBackPressedDispatcher porque desde Android 16 el gesto de
     * retroceso ya no invoca Activity.onBackPressed().
     */
    private void setupBackNavigation() {
        getOnBackPressedDispatcher().addCallback(this, new OnBackPressedCallback(true) {
            @Override
            public void handleOnBackPressed() {
                if (activeFragment != homeFragment) {
                    binding.bottomNav.setSelectedItemId(R.id.nav_home);
                    return;
                }
                setEnabled(false);
                getOnBackPressedDispatcher().onBackPressed();
            }
        });
    }
}
