package com.skillswap.utils;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageManager;
import android.location.Location;

import androidx.core.content.ContextCompat;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.Priority;
import com.google.android.gms.tasks.CancellationTokenSource;

/**
 * RC4 - Ubicacion aproximada del estudiante.
 *
 * Solo se pide ACCESS_COARSE_LOCATION, y unicamente cuando el estudiante
 * activa "Mostrar estudiantes cercanos": nunca al abrir la aplicacion. Si no
 * concede el permiso, el resto de funciones sigue igual, solo se pierde el
 * orden por cercania.
 *
 * La coordenada se redondea antes de salir de aqui (ver {@link GeoUtils}).
 */
public final class LocationHelper {

    public interface Callback {
        void onUbicacion(double lat, double lon);
        void onError(String mensaje);
    }

    public static final String PERMISO = Manifest.permission.ACCESS_COARSE_LOCATION;

    private LocationHelper() {
    }

    public static boolean tienePermiso(Context context) {
        return ContextCompat.checkSelfPermission(context, PERMISO)
                == PackageManager.PERMISSION_GRANTED;
    }

    /**
     * Pide una ubicacion puntual. Se usa getCurrentLocation en vez de
     * requestLocationUpdates porque no hace falta seguir al usuario: basta
     * una lectura cuando activa la opcion.
     */
    @SuppressLint("MissingPermission")
    public static void obtener(final Context context, final Callback callback) {
        if (!tienePermiso(context)) {
            callback.onError("Falta el permiso de ubicación");
            return;
        }

        try {
            FusedLocationProviderClient cliente =
                    LocationServices.getFusedLocationProviderClient(context);

            cliente.getCurrentLocation(Priority.PRIORITY_BALANCED_POWER_ACCURACY,
                            new CancellationTokenSource().getToken())
                    .addOnSuccessListener(location -> {
                        if (location == null) {
                            ultimaConocida(cliente, callback);
                            return;
                        }
                        entregar(location, callback);
                    })
                    .addOnFailureListener(e ->
                            callback.onError("No se pudo obtener la ubicación"));
        } catch (Exception e) {
            callback.onError("No se pudo obtener la ubicación");
        }
    }

    /** Respaldo: en emuladores getCurrentLocation suele devolver null. */
    @SuppressLint("MissingPermission")
    private static void ultimaConocida(FusedLocationProviderClient cliente,
                                       final Callback callback) {
        cliente.getLastLocation()
                .addOnSuccessListener(location -> {
                    if (location == null) {
                        callback.onError("Todavía no hay una ubicación disponible");
                    } else {
                        entregar(location, callback);
                    }
                })
                .addOnFailureListener(e ->
                        callback.onError("No se pudo obtener la ubicación"));
    }

    private static void entregar(Location location, Callback callback) {
        callback.onUbicacion(
                GeoUtils.redondear(location.getLatitude()),
                GeoUtils.redondear(location.getLongitude()));
    }
}
