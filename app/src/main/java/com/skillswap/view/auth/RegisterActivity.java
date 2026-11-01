package com.skillswap.view.auth;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.skillswap.databinding.ActivityRegisterBinding;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.utils.UiUtils;
import com.skillswap.utils.Validators;
import com.skillswap.view.profile.EditProfileActivity;
import com.skillswap.viewmodel.AuthViewModel;

/** Registro de estudiantes con validacion completa de campos. */
public class RegisterActivity extends AppCompatActivity {

    private ActivityRegisterBinding binding;
    private AuthViewModel viewModel;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityRegisterBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        viewModel = new ViewModelProvider(this).get(AuthViewModel.class);

        binding.btnBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        binding.btnGoLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        binding.btnRegister.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                attemptRegister();
            }
        });

        viewModel.authState().observe(this, new Observer<Resource<User>>() {
            @Override
            public void onChanged(Resource<User> state) {
                if (state == null) return;
                UiUtils.visible(binding.progress, state.isLoading());
                binding.btnRegister.setEnabled(!state.isLoading());

                if (state.isSuccess()) {
                    // Tras el registro se completa el perfil.
                    Intent intent = new Intent(RegisterActivity.this, EditProfileActivity.class);
                    intent.putExtra(EditProfileActivity.EXTRA_FIRST_TIME, true);
                    startActivity(intent);
                    finishAffinity();
                } else if (state.isError()) {
                    UiUtils.snack(binding.getRoot(), state.getMessage());
                }
            }
        });
    }

    private void attemptRegister() {
        UiUtils.hideKeyboard(binding.getRoot());

        String firstName = Validators.text(binding.tilFirstName).trim();
        String lastName = Validators.text(binding.tilLastName).trim();
        String email = Validators.text(binding.tilEmail).trim();
        String password = Validators.text(binding.tilPassword);
        String confirm = Validators.text(binding.tilConfirm);

        boolean ok = Validators.apply(binding.tilFirstName, Validators.validateName(firstName));
        ok &= Validators.apply(binding.tilLastName, Validators.validateName(lastName));
        ok &= Validators.apply(binding.tilEmail, Validators.validateEmail(email));
        ok &= Validators.apply(binding.tilPassword, Validators.validatePassword(password));
        ok &= Validators.apply(binding.tilConfirm,
                Validators.validateConfirmPassword(password, confirm));

        if (!ok) return;
        viewModel.register(firstName, lastName, email, password);
    }
}
