package com.skillswap.webservice;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

/**
 * RC2 - Cliente REST con Retrofit y Gson.
 *
 * A diferencia del SOAP, aqui basta declarar la interfaz y Retrofit se encarga
 * de armar la URL y Gson de convertir el JSON en objetos.
 */
public final class RestClient {

    public interface UniversidadesCallback {
        void onResultado(List<String> nombres);
        void onError(String mensaje);
    }

    private static final String BASE = "http://universities.hipolabs.com/";
    private static final Handler MAIN = new Handler(Looper.getMainLooper());

    private static Retrofit retrofit;

    private RestClient() {
    }

    private static UniversityApi api() {
        if (retrofit == null) {
            retrofit = new Retrofit.Builder()
                    .baseUrl(BASE)
                    .addConverterFactory(GsonConverterFactory.create())
                    .build();
        }
        return retrofit.create(UniversityApi.class);
    }

    /**
     * Sugiere universidades peruanas cuyo nombre contenga el texto escrito.
     *
     * Si el servicio no responde se avisa por onError y la pantalla deja el
     * campo como texto libre: el perfil se puede completar igual.
     */
    public static void buscarUniversidades(String texto,
                                           final UniversidadesCallback callback) {
        api().buscar("Peru", texto == null ? "" : texto.trim())
                .enqueue(new Callback<List<UniversityApi.UniversidadDto>>() {
                    @Override
                    public void onResponse(@NonNull Call<List<UniversityApi.UniversidadDto>> call,
                                           @NonNull Response<List<UniversityApi.UniversidadDto>> response) {
                        if (!response.isSuccessful() || response.body() == null) {
                            MAIN.post(() -> callback.onError("El servicio no respondió"));
                            return;
                        }
                        final List<String> nombres = new ArrayList<>();
                        for (UniversityApi.UniversidadDto u : response.body()) {
                            if (u != null && u.nombre != null && !nombres.contains(u.nombre)) {
                                nombres.add(u.nombre);
                            }
                            if (nombres.size() >= 25) break;
                        }
                        MAIN.post(() -> callback.onResultado(nombres));
                    }

                    @Override
                    public void onFailure(@NonNull Call<List<UniversityApi.UniversidadDto>> call,
                                          @NonNull Throwable t) {
                        MAIN.post(() -> callback.onError("Sin conexión con el servicio"));
                    }
                });
    }
}
