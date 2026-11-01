package com.skillswap.view.auth;

import android.os.Bundle;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.skillswap.databinding.ActivityForgotPasswordBinding;
import com.skillswap.model.Resource;
import com.skillswap.utils.UiUtils;
import com.skillswap.utils.Validators;
import com.skillswap.view.BaseActivity;
import com.skillswap.viewmodel.AuthViewModel;

/** Recuperacion de contrasena por correo. */
public class ForgotPasswordActivity extends BaseActivity {

    private ActivityForgotPasswordBinding binding;
    private AuthViewModel viewModel;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityForgotPasswordBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        viewModel = new ViewModelProvider(this).get(AuthViewModel.class);

        binding.btnBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        binding.btnSend.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                UiUtils.hideKeyboard(binding.getRoot());
                String email = Validators.text(binding.tilEmail).trim();
                if (!Validators.apply(binding.tilEmail, Validators.validateEmail(email))) return;
                viewModel.resetPassword(email);
            }
        });

        viewModel.resetState().observe(this, new Observer<Resource<Boolean>>() {
            @Override
            public void onChanged(Resource<Boolean> state) {
                if (state == null) return;
                UiUtils.visible(binding.progress, state.isLoading());
                binding.btnSend.setEnabled(!state.isLoading());

                if (state.isSuccess()) {
                    info("Revisa tu correo",
                            "Te enviamos un enlace para restablecer tu contraseña. "
                                    + "Si no lo ves, revisa la carpeta de spam.");
                } else if (state.isError()) {
                    UiUtils.snack(binding.getRoot(), state.getMessage());
                }
            }
        });
    }
}
