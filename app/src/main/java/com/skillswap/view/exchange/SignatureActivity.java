package com.skillswap.view.exchange;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;

import com.skillswap.R;
import com.skillswap.databinding.ActivitySignatureBinding;
import com.skillswap.repository.RepoCallback;
import com.skillswap.repository.SignatureRepository;
import com.skillswap.utils.Constants;
import com.skillswap.view.BaseActivity;

/**
 * RC3 - Firma de la aceptacion de un intercambio.
 *
 * Muestra el resumen de lo que se acepta y los terminos, y pide al estudiante
 * que firme con el dedo. Al confirmar se guarda la constancia (quien, que
 * solicitud, hora del servidor y huella SHA-256 del texto) y se devuelve
 * RESULT_OK para que la pantalla anterior continue con la aceptacion.
 *
 * Si la firma no se puede guardar, NO se acepta el intercambio: la constancia
 * es parte del acto, no un adorno posterior.
 */
public class SignatureActivity extends BaseActivity {

    public static final String EXTRA_RESUMEN = "extra_resumen";
    public static final String EXTRA_HUELLA = "extra_huella";

    private ActivitySignatureBinding binding;
    private String requestId;
    private String textoAceptado;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivitySignatureBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        setupToolbar(binding.toolbarInc.toolbar, getString(R.string.signature_title));

        requestId = getIntent().getStringExtra(Constants.EXTRA_REQUEST_ID);
        String resumen = getIntent().getStringExtra(EXTRA_RESUMEN);
        if (resumen == null) resumen = "";

        binding.txtResumen.setText(resumen);

        // El texto del que se saca la huella es exactamente lo que se le
        // muestra al estudiante: resumen + terminos.
        textoAceptado = resumen + "\n" + getString(R.string.signature_terms);

        binding.signatureView.setOnFirmaListener(hay -> binding.btnFirmar.setEnabled(hay));
        binding.btnLimpiar.setOnClickListener(v -> {
            binding.signatureView.limpiar();
            binding.btnFirmar.setEnabled(false);
        });
        binding.btnFirmar.setOnClickListener(v -> firmar());
    }

    private void firmar() {
        if (!binding.signatureView.tieneFirma()) {
            toast(binding.getRoot(), getString(R.string.signature_required));
            return;
        }
        binding.btnFirmar.setEnabled(false);

        SignatureRepository.get().registrar(requestId, textoAceptado,
                binding.signatureView.obtenerFirma(), new RepoCallback<String>() {
                    @Override
                    public void onSuccess(String huella) {
                        Intent data = new Intent();
                        data.putExtra(EXTRA_HUELLA, huella);
                        setResult(RESULT_OK, data);
                        finish();
                    }

                    @Override
                    public void onError(String message) {
                        binding.btnFirmar.setEnabled(true);
                        toast(binding.getRoot(), message);
                    }
                });
    }
}
