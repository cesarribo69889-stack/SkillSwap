package com.skillswap.view.ratings;

import android.os.Bundle;
import android.widget.RatingBar;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;

import com.skillswap.R;
import com.skillswap.databinding.ActivityRateExchangeBinding;
import com.skillswap.firebase.FirebaseManager;
import com.skillswap.model.Exchange;
import com.skillswap.model.Rating;
import com.skillswap.model.Resource;
import com.skillswap.utils.Constants;
import com.skillswap.utils.ImageLoader;
import com.skillswap.utils.UiUtils;
import com.skillswap.utils.Validators;
import com.skillswap.view.BaseActivity;
import com.skillswap.viewmodel.ExchangeViewModel;
import com.skillswap.viewmodel.RatingViewModel;

/** Calificacion de un intercambio completado. */
public class RateExchangeActivity extends BaseActivity {

    private ActivityRateExchangeBinding binding;
    private RatingViewModel ratingViewModel;
    private ExchangeViewModel exchangeViewModel;
    private Exchange exchange;
    private final String myUid = FirebaseManager.uid();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityRateExchangeBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        String exchangeId = getIntent().getStringExtra(Constants.EXTRA_EXCHANGE_ID);
        ratingViewModel = new ViewModelProvider(this).get(RatingViewModel.class);
        exchangeViewModel = new ViewModelProvider(this).get(ExchangeViewModel.class);

        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.rate_exchange));

        binding.rowPunctuality.txtCriteria.setText(R.string.rate_punctuality);
        binding.rowCommunication.txtCriteria.setText(R.string.rate_communication);
        binding.rowTeaching.txtCriteria.setText(R.string.rate_teaching);

        binding.ratingGeneral.setOnRatingBarChangeListener(
                new RatingBar.OnRatingBarChangeListener() {
                    @Override
                    public void onRatingChanged(RatingBar bar, float rating, boolean fromUser) {
                        binding.txtRatingLabel.setText(labelFor(rating));
                    }
                });

        binding.btnSubmit.setOnClickListener(v -> submit());

        exchangeViewModel.detail().observe(this, new Observer<Exchange>() {
            @Override
            public void onChanged(Exchange data) {
                if (data == null) return;
                exchange = data;
                render();
            }
        });

        ratingViewModel.submitState().observe(this, new Observer<Resource<Rating>>() {
            @Override
            public void onChanged(Resource<Rating> state) {
                if (state == null) return;
                binding.btnSubmit.setEnabled(!state.isLoading());
                if (state.isSuccess()) {
                    info("¡Gracias por calificar!",
                            "Tu opinión actualiza la reputación de tu compañero "
                                    + "y su Pasaporte de Habilidades.");
                    binding.btnSubmit.postDelayed(RateExchangeActivity.this::finish, 1100);
                } else if (state.isError()) {
                    toast(binding.getRoot(), state.getMessage());
                }
            }
        });

        if (exchangeId != null) exchangeViewModel.observeDetail(exchangeId);
    }

    private void render() {
        binding.txtName.setText(exchange.getPartnerName(myUid));
        binding.txtSkill.setText(getString(R.string.fmt_taught_you,
                exchange.getSkillILearn(myUid)));
        ImageLoader.avatar(binding.imgAvatar, exchange.getPartnerPhoto(myUid));

        if (exchange.hasRated(myUid)) {
            binding.btnSubmit.setEnabled(false);
            binding.btnSubmit.setText(R.string.st_already_rated);
        }
    }

    private String labelFor(float rating) {
        int stars = Math.round(rating);
        switch (stars) {
            case 1: return "Muy mala experiencia";
            case 2: return "Podría mejorar";
            case 3: return "Aceptable";
            case 4: return "Muy buena";
            case 5: return "¡Excelente!";
            default: return "Toca las estrellas para calificar";
        }
    }

    private void submit() {
        UiUtils.hideKeyboard(binding.getRoot());
        if (exchange == null) {
            toast(binding.getRoot(), "El intercambio aún se está cargando");
            return;
        }
        if (binding.ratingGeneral.getRating() <= 0) {
            toast(binding.getRoot(), "Selecciona al menos una estrella");
            return;
        }

        Rating rating = new Rating();
        rating.setStars(binding.ratingGeneral.getRating());
        rating.setPunctuality(binding.rowPunctuality.ratingCriteria.getRating());
        rating.setCommunication(binding.rowCommunication.ratingCriteria.getRating());
        rating.setTeaching(binding.rowTeaching.ratingCriteria.getRating());
        rating.setComment(Validators.text(binding.tilComment).trim());

        // Si no calificó los criterios, se usa la puntuación general.
        if (rating.getPunctuality() <= 0) rating.setPunctuality(rating.getStars());
        if (rating.getCommunication() <= 0) rating.setCommunication(rating.getStars());
        if (rating.getTeaching() <= 0) rating.setTeaching(rating.getStars());

        ratingViewModel.submit(exchange, rating);
    }
}
