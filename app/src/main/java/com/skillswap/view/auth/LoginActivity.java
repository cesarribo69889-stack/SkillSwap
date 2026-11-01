package com.skillswap.view.auth;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.skillswap.databinding.ActivityLoginBinding;
import com.skillswap.model.Resource;
import com.skillswap.model.User;
import com.skillswap.utils.UiUtils;
import com.skillswap.utils.Validators;
import com.skillswap.view.MainActivity;
import com.skillswap.viewmodel.AuthViewModel;

/** Inicio de sesion con Firebase Authentication. */
public class LoginActivity extends AppCompatActivity {

    private ActivityLoginBinding binding;
    private AuthViewModel viewModel;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityLoginBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        viewModel = new ViewModelProvider(this).get(AuthViewModel.class);

        binding.btnLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                attemptLogin();
            }
        });

        binding.btnGoRegister.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startActivity(new Intent(LoginActivity.this, RegisterActivity.class));
            }
        });

        binding.btnForgot.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startActivity(new Intent(LoginActivity.this, ForgotPasswordActivity.class));
            }
        });

        viewModel.authState().observe(this, new Observer<Resource<User>>() {
            @Override
            public void onChanged(Resource<User> state) {
                if (state == null) return;
                UiUtils.visible(binding.progress, state.isLoading());
                binding.btnLogin.setEnabled(!state.isLoading());

                if (state.isSuccess()) {
                    startActivity(new Intent(LoginActivity.this, MainActivity.class));
                    finishAffinity();
                } else if (state.isError()) {
                    UiUtils.snack(binding.getRoot(), state.getMessage());
                }
            }
        });
    }

    private void attemptLogin() {
        UiUtils.hideKeyboard(binding.getRoot());

        String email = Validators.text(binding.tilEmail).trim();
        String password = Validators.text(binding.tilPassword);

        boolean ok = Validators.apply(binding.tilEmail, Validators.validateEmail(email));
        ok &= Validators.apply(binding.tilPassword,
                Validators.isEmpty(password) ? "La contraseña es obligatoria" : null);

        if (!ok) return;
        viewModel.login(email, password);
    }
}
