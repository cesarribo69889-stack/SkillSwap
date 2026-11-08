package com.skillswap.view.leaderboard;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.skillswap.R;
import com.skillswap.databinding.ActivityLeaderboardBinding;
import com.skillswap.adapter.LeaderboardAdapter;
import com.skillswap.model.User;
import com.skillswap.repository.RepoCallback;
import com.skillswap.repository.UserRepository;
import com.skillswap.utils.Constants;
import com.skillswap.utils.LeaderboardEngine;
import com.skillswap.utils.UiUtils;
import com.skillswap.view.BaseActivity;
import com.skillswap.view.profile.UserProfileActivity;

import java.util.ArrayList;
import java.util.List;

/**
 * INNOVACION 10 - Tabla de lideres.
 *
 * Compara SkillPoints entre estudiantes y deja acotar el ranking a la propia
 * universidad o carrera, que es donde la comparacion motiva de verdad.
 *
 * Toda la logica de orden, empates y posicion propia vive en
 * {@link LeaderboardEngine}, que se prueba con tests unitarios.
 */
public class LeaderboardActivity extends BaseActivity {

    private static final int LIMITE = 50;

    private ActivityLeaderboardBinding binding;
    private LeaderboardAdapter adapter;

    private final List<User> todos = new ArrayList<>();
    private User yo;
    private int ambito = LeaderboardEngine.AMBITO_TODOS;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityLeaderboardBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.leaderboard));

        adapter = new LeaderboardAdapter(this::abrirPerfil);
        binding.rvLeaderboard.setLayoutManager(new LinearLayoutManager(this));
        binding.rvLeaderboard.setAdapter(adapter);

        binding.chipsScope.setOnCheckedStateChangeListener((group, checkedIds) -> {
            if (checkedIds.isEmpty()) return;
            int id = checkedIds.get(0);
            if (id == R.id.chipUniversity) {
                ambito = LeaderboardEngine.AMBITO_UNIVERSIDAD;
            } else if (id == R.id.chipCareer) {
                ambito = LeaderboardEngine.AMBITO_CARRERA;
            } else {
                ambito = LeaderboardEngine.AMBITO_TODOS;
            }
            pintar();
        });

        cargar();
    }

    private void cargar() {
        yo = UserRepository.get().currentUserValue();

        // null como exclusion: aqui si queremos vernos en la lista.
        UserRepository.get().fetchCandidates(null, new RepoCallback<List<User>>() {
            @Override
            public void onSuccess(List<User> data) {
                todos.clear();
                if (data != null) todos.addAll(data);
                if (yo == null) yo = buscarme(todos);
                pintar();
            }

            @Override
            public void onError(String message) {
                toast(binding.getRoot(), message);
            }
        });
    }

    /** Si la cache local aun no tiene mi usuario, lo tomo de la lista. */
    private User buscarme(List<User> lista) {
        String uid = com.skillswap.firebase.FirebaseManager.uid();
        if (uid == null) return null;
        for (User u : lista) {
            if (uid.equals(u.getUid())) return u;
        }
        return null;
    }

    private void pintar() {
        LeaderboardEngine.Tabla tabla =
                LeaderboardEngine.construir(todos, yo, ambito, LIMITE);

        adapter.submit(tabla.getPuestos());

        boolean vacia = tabla.getPuestos().isEmpty();
        UiUtils.visible(binding.txtEmpty, vacia);
        UiUtils.visible(binding.rvLeaderboard, !vacia);

        binding.txtMyPosition.setText(tabla.resumenPersonal());
        binding.txtMyPoints.setText(getString(R.string.fmt_leaderboard_scope,
                LeaderboardEngine.nombreDeAmbito(ambito),
                tabla.getTotalParticipantes()));
    }

    private void abrirPerfil(User user) {
        if (user == null || user.getUid() == null) return;
        Intent intent = new Intent(this, UserProfileActivity.class);
        intent.putExtra(Constants.EXTRA_USER_ID, user.getUid());
        startActivity(intent);
    }
}
