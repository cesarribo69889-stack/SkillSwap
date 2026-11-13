package com.skillswap.view.profile;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.widget.ArrayAdapter;

import androidx.activity.result.ActivityResultCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.google.android.material.chip.Chip;
import com.google.android.material.textfield.MaterialAutoCompleteTextView;
import com.skillswap.R;
import com.skillswap.databinding.ActivityEditProfileBinding;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import android.text.Editable;
import android.text.TextWatcher;

import com.skillswap.utils.ChipFactory;
import com.skillswap.webservice.RestClient;
import com.skillswap.webservice.SoapCountryClient;
import com.skillswap.utils.Constants;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;
import com.skillswap.utils.Validators;
import com.skillswap.view.BaseActivity;
import com.skillswap.view.MainActivity;
import com.skillswap.view.skills.MySkillsActivity;
import com.skillswap.viewmodel.ProfileViewModel;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/** Edicion del perfil del estudiante. */
public class EditProfileActivity extends BaseActivity {

    /** Ultimo texto consultado al servicio REST, para no repetir peticiones. */
    private String ultimaConsulta = "";

    public static final String EXTRA_FIRST_TIME = "extra_first_time";

    private ActivityEditProfileBinding binding;
    private ProfileViewModel viewModel;
    private User current;
    private boolean firstTime;

    private final ActivityResultLauncher<String> pickImage =
            registerForActivityResult(new ActivityResultContracts.GetContent(),
                    new ActivityResultCallback<Uri>() {
                        @Override
                        public void onActivityResult(Uri uri) {
                            if (uri == null || current == null) return;
                            binding.imgAvatar.setImageURI(uri);
                            viewModel.uploadPhoto(EditProfileActivity.this, current.getUid(), uri);
                        }
                    });

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityEditProfileBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        firstTime = getIntent().getBooleanExtra(EXTRA_FIRST_TIME, false);
        viewModel = new ViewModelProvider(this).get(ProfileViewModel.class);

        setupToolbar(binding.toolbarInc.toolbar,
                firstTime ? "Completa tu perfil" : getString(R.string.profile_edit));
        setupCycles();
        setupWebServices();
        setupAvailability();

        binding.fabPhoto.setOnClickListener(v -> pickImage.launch("image/*"));
        binding.btnSave.setOnClickListener(v -> save());

        viewModel.currentUser().observe(this, new Observer<User>() {
            @Override
            public void onChanged(User user) {
                if (user == null) return;
                current = user;
                render(user);
            }
        });
        viewModel.listenCurrentUser();

        viewModel.photoState().observe(this, new Observer<Resource<String>>() {
            @Override
            public void onChanged(Resource<String> state) {
                if (state == null) return;
                UiUtils.visible(binding.progressPhoto, state.isLoading());
                if (state.isSuccess() && current != null) {
                    current.setPhotoUrl(state.getData());
                    toast(binding.getRoot(), "Foto actualizada");
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });

        viewModel.saveState().observe(this, new Observer<Resource<User>>() {
            @Override
            public void onChanged(Resource<User> state) {
                if (state == null) return;
                binding.btnSave.setEnabled(!state.isLoading());
                if (state.isSuccess()) {
                    if (firstTime) {
                        startActivity(new Intent(EditProfileActivity.this, MySkillsActivity.class));
                        startActivity(new Intent(EditProfileActivity.this, MainActivity.class));
                        finishAffinity();
                    } else {
                        toast(binding.getRoot(), "Perfil actualizado");
                        finish();
                    }
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });
    }

    private void setupCycles() {
        List<String> cycles = Arrays.asList(getResources().getStringArray(R.array.cycles));
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this,
                android.R.layout.simple_list_item_1, cycles);
        if (binding.tilCycle.getEditText() instanceof MaterialAutoCompleteTextView) {
            ((MaterialAutoCompleteTextView) binding.tilCycle.getEditText()).setAdapter(adapter);
        }
    }

    /**
     * RC2 - Servicios web.
     *
     * REST: mientras el estudiante escribe el nombre de su universidad, se
     * consulta la API de Hipolabs y se ofrecen sugerencias.
     * SOAP: al elegir una, se completa el pais y el idioma con
     * CountryInfoService.
     *
     * Si cualquiera de los dos falla, el campo queda como texto libre y el
     * perfil se puede guardar igual.
     */
    private void setupWebServices() {
        if (!(binding.tilUniversity.getEditText() instanceof MaterialAutoCompleteTextView)) return;
        final MaterialAutoCompleteTextView campo =
                (MaterialAutoCompleteTextView) binding.tilUniversity.getEditText();

        campo.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int a, int b, int c) {
            }

            @Override
            public void onTextChanged(CharSequence s, int a, int b, int c) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                String texto = s == null ? "" : s.toString().trim();
                // Se consulta a partir de 3 letras para no saturar el servicio.
                if (texto.length() < 3) return;
                if (texto.equals(ultimaConsulta)) return;
                ultimaConsulta = texto;

                RestClient.buscarUniversidades(texto, new RestClient.UniversidadesCallback() {
                    @Override
                    public void onResultado(List<String> nombres) {
                        if (isFinishing() || nombres.isEmpty()) return;
                        campo.setSimpleItems(nombres.toArray(new String[0]));
                        campo.showDropDown();
                    }

                    @Override
                    public void onError(String mensaje) {
                        // Silencioso: el campo sigue siendo de texto libre.
                    }
                });
            }
        });

        // Al elegir una universidad de la lista se pide pais e idioma por SOAP.
        campo.setOnItemClickListener((parent, view, position, id) -> consultarPaisPorSoap());
        consultarPaisPorSoap();
    }

    private void consultarPaisPorSoap() {
        SoapCountryClient.nombreDePais("PE", new SoapCountryClient.Callback() {
            @Override
            public void onResultado(final String pais) {
                SoapCountryClient.nombreDeIdioma("es", new SoapCountryClient.Callback() {
                    @Override
                    public void onResultado(String idioma) {
                        if (isFinishing()) return;
                        binding.txtCountryInfo.setText(getString(
                                R.string.fmt_country_info, pais, idioma));
                    }

                    @Override
                    public void onError(String mensaje) {
                        if (isFinishing()) return;
                        binding.txtCountryInfo.setText(getString(
                                R.string.fmt_country_info_partial, pais));
                    }
                });
            }

            @Override
            public void onError(String mensaje) {
                if (isFinishing()) return;
                binding.txtCountryInfo.setText(R.string.country_info_unavailable);
            }
        });
    }

    private void setupAvailability() {
        binding.chipsAvailability.removeAllViews();
        for (String slot : getResources().getStringArray(R.array.availability_slots)) {
            Chip chip = ChipFactory.choiceChip(this, slot, false);
            chip.setTag(slot);
            binding.chipsAvailability.addView(chip);
        }
    }

    private void render(User user) {
        if (binding.tilFirstName.getEditText() != null) {
            binding.tilFirstName.getEditText().setText(user.getFirstName());
        }
        if (binding.tilLastName.getEditText() != null) {
            binding.tilLastName.getEditText().setText(user.getLastName());
        }
        if (binding.tilUniversity.getEditText() != null) {
            binding.tilUniversity.getEditText().setText(user.getUniversity());
        }
        if (binding.tilCareer.getEditText() != null) {
            binding.tilCareer.getEditText().setText(user.getCareer());
        }
        if (binding.tilCycle.getEditText() instanceof MaterialAutoCompleteTextView) {
            ((MaterialAutoCompleteTextView) binding.tilCycle.getEditText())
                    .setText(user.getCycle(), false);
        }
        if (binding.tilDescription.getEditText() != null) {
            binding.tilDescription.getEditText().setText(user.getDescription());
        }

        binding.chipPresencial.setChecked(Constants.MODALITY_PRESENCIAL.equals(user.getModality()));
        binding.chipVirtual.setChecked(Constants.MODALITY_VIRTUAL.equals(user.getModality()));
        binding.chipBoth.setChecked(Constants.MODALITY_BOTH.equals(user.getModality()));

        for (int i = 0; i < binding.chipsAvailability.getChildCount(); i++) {
            Chip chip = (Chip) binding.chipsAvailability.getChildAt(i);
            chip.setChecked(user.getAvailability().contains(String.valueOf(chip.getTag())));
        }

        ImageLoader.avatar(binding.imgAvatar, user.getPhotoUrl());
    }

    private void save() {
        UiUtils.hideKeyboard(binding.getRoot());
        if (current == null) {
            toast(binding.getRoot(), "Tu perfil aún se está cargando");
            return;
        }

        String firstName = Validators.text(binding.tilFirstName).trim();
        String lastName = Validators.text(binding.tilLastName).trim();
        String university = Validators.text(binding.tilUniversity).trim();
        String career = Validators.text(binding.tilCareer).trim();

        boolean ok = Validators.apply(binding.tilFirstName, Validators.validateName(firstName));
        ok &= Validators.apply(binding.tilLastName, Validators.validateName(lastName));
        ok &= Validators.apply(binding.tilUniversity,
                Validators.validateMinLength(university, 3, "La universidad"));
        ok &= Validators.apply(binding.tilCareer,
                Validators.validateMinLength(career, 3, "La carrera"));
        // HU06: el ciclo es obligatorio. Antes un perfil sin ciclo se marcaba
        // como completo y aparecia en los resultados de busqueda.
        ok &= Validators.apply(binding.tilCycle,
                Validators.text(binding.tilCycle).trim().isEmpty() ? "Selecciona tu ciclo" : null);
        if (!ok) return;

        String modality = "";
        if (binding.chipPresencial.isChecked()) modality = Constants.MODALITY_PRESENCIAL;
        else if (binding.chipVirtual.isChecked()) modality = Constants.MODALITY_VIRTUAL;
        else if (binding.chipBoth.isChecked()) modality = Constants.MODALITY_BOTH;

        if (modality.isEmpty()) {
            toast(binding.getRoot(), "Elige una modalidad de intercambio");
            return;
        }

        List<String> availability = new ArrayList<>();
        for (int i = 0; i < binding.chipsAvailability.getChildCount(); i++) {
            Chip chip = (Chip) binding.chipsAvailability.getChildAt(i);
            if (chip.isChecked()) availability.add(String.valueOf(chip.getTag()));
        }
        if (availability.isEmpty()) {
            toast(binding.getRoot(), "Selecciona al menos un bloque de disponibilidad");
            return;
        }

        current.setFirstName(firstName);
        current.setLastName(lastName);
        current.setUniversity(university);
        current.setCareer(career);
        current.setCycle(Validators.text(binding.tilCycle).trim());
        current.setDescription(Validators.text(binding.tilDescription).trim());
        current.setModality(modality);
        current.setAvailability(availability);

        viewModel.saveProfile(current);
    }
}
