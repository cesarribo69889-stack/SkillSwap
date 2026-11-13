package com.skillswap.view.matches;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
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
import com.skillswap.model.User;
import com.skillswap.repository.RepoCallback;
import com.skillswap.repository.UserRepository;
import com.skillswap.utils.ChipFactory;
import com.skillswap.utils.GeoUtils;
import com.skillswap.utils.LocationHelper;
import com.skillswap.utils.Constants;
import com.skillswap.utils.UiUtils;
import com.skillswap.view.exchange.SendRequestActivity;
import com.skillswap.view.profile.UserProfileActivity;
import com.skillswap.viewmodel.ExploreViewModel;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/** Explorar estudiantes con SkillMatch, buscador y filtros. */
public class ExploreFragment extends Fragment {

    private FragmentExploreBinding binding;
    private ExploreViewModel viewModel;
    private MatchAdapter adapter;

    /** Habilidad pedida desde Inicio antes de que la vista exista. */
    private String pendingSkill;

    /** RC4 - permiso de ubicacion aproximada, pedido al activar "Cercanos". */
    private final ActivityResultLauncher<String> permisoUbicacion =
            registerForActivityResult(new ActivityResultContracts.RequestPermission(),
                    concedido -> {
                        if (binding == null) return;
                        if (concedido) {
                            obtenerYGuardarUbicacion();
                        } else {
                            avisarYDesmarcar(getString(R.string.nearby_denied));
                        }
                    });

    /**
     * Filtra la lista por una habilidad concreta. Se invoca desde Inicio al
     * tocar una habilidad popular; si la vista aun no esta creada se guarda
     * y se aplica en onViewCreated.
     */
    public void filterBySkill(String skillName) {
        if (skillName == null || skillName.trim().isEmpty()) return;
        if (viewModel == null || binding == null) {
            pendingSkill = skillName;
            return;
        }
        ExploreFilter filter = viewModel.currentFilter();
        filter.setSkill(skillName);
        viewModel.applyFilter(filter);
    }

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

        setupCercanos();
        observe();
        viewModel.load();

        if (pendingSkill != null) {
            filterBySkill(pendingSkill);
            pendingSkill = null;
        }
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
                        // RC4: si "Cercanos" esta activo, se reordena por distancia.
                        if (binding.chipCercanos.isChecked()) {
                            data = ordenarPorCercania(data);
                        }
                        adapter.submit(data);
                        boolean empty = data == null || data.isEmpty();
                        UiUtils.visible(binding.empty.getRoot(), empty);
                        UiUtils.visible(binding.swipeRefresh, !empty);

                        int count = data == null ? 0 : data.size();
                        binding.txtCount.setText(getResources().getQuantityString(
                                R.plurals.plu_compatible_students, count, count));

                        binding.empty.txtEmptyTitle.setText(R.string.empty_title_explore);
                        binding.empty.txtEmptyDesc.setText(R.string.empty_desc_explore);
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

    /**
     * RC4 - "Mostrar estudiantes cercanos".
     *
     * El permiso se pide AQUI, al activar la opcion, no al abrir la app. Si
     * el estudiante lo rechaza, el chip se desmarca y Explorar sigue
     * funcionando con el orden normal por compatibilidad.
     */
    private void setupCercanos() {
        binding.chipCercanos.setOnCheckedChangeListener((boton, activado) -> {
            if (!activado) {
                viewModel.load();
                return;
            }
            if (LocationHelper.tienePermiso(requireContext())) {
                obtenerYGuardarUbicacion();
            } else {
                permisoUbicacion.launch(LocationHelper.PERMISO);
            }
        });
    }

    private void obtenerYGuardarUbicacion() {
        LocationHelper.obtener(requireContext(), new LocationHelper.Callback() {
            @Override
            public void onUbicacion(double lat, double lon) {
                if (binding == null) return;
                UserRepository.get().updateLocation(lat, lon, new RepoCallback<Boolean>() {
                    @Override
                    public void onSuccess(Boolean data) {
                        if (binding == null) return;
                        viewModel.load();
                    }

                    @Override
                    public void onError(String message) {
                        avisarYDesmarcar(message);
                    }
                });
            }

            @Override
            public void onError(String mensaje) {
                avisarYDesmarcar(mensaje);
            }
        });
    }

    private void avisarYDesmarcar(String mensaje) {
        if (binding == null) return;
        UiUtils.snack(binding.getRoot(), mensaje);
        binding.chipCercanos.setChecked(false);
    }

    /** Ordena por distancia; los que no comparten ubicacion quedan al final. */
    private List<MatchResult> ordenarPorCercania(List<MatchResult> data) {
        if (data == null) return null;
        User yo = UserRepository.get().currentUserValue();
        if (yo == null || !GeoUtils.esValida(yo.getLat(), yo.getLon())) return data;

        List<MatchResult> copia = new ArrayList<>(data);
        Collections.sort(copia, (a, b) -> {
            double da = distancia(yo, a);
            double db = distancia(yo, b);
            if (da < 0 && db < 0) return 0;
            if (da < 0) return 1;
            if (db < 0) return -1;
            return Double.compare(da, db);
        });
        return copia;
    }

    private double distancia(User yo, MatchResult m) {
        if (m == null || m.getUser() == null) return -1;
        User o = m.getUser();
        return GeoUtils.distanciaKm(yo.getLat(), yo.getLon(), o.getLat(), o.getLon());
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
            active.add(new String[]{"min",
                    getString(R.string.fmt_min_compatibility, filter.getMinCompatibility())});
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
