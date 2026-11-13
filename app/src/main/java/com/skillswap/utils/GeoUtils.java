package com.skillswap.utils;

/**
 * RC4 - Calculos de distancia para el orden por cercania.
 *
 * Privacidad: la app NUNCA guarda la posicion exacta. Antes de escribirla en
 * Firestore se redondea a dos decimales, que equivale a una celda de poco mas
 * de un kilometro. Con eso alcanza para ordenar por cercania sin revelar
 * donde vive o estudia una persona.
 */
public final class GeoUtils {

    /** Radio medio de la Tierra en kilometros. */
    private static final double RADIO_TIERRA_KM = 6371.0;

    /** Dos decimales ~ 1,1 km de precision. Suficiente y poco invasivo. */
    private static final double FACTOR_REDONDEO = 100.0;

    private GeoUtils() {
    }

    /** Redondea una coordenada para no guardar la ubicacion exacta. */
    public static double redondear(double grados) {
        return Math.round(grados * FACTOR_REDONDEO) / FACTOR_REDONDEO;
    }

    /**
     * Distancia en kilometros entre dos puntos (formula de Haversine).
     * Devuelve -1 si alguna coordenada no es valida o esta sin definir.
     */
    public static double distanciaKm(double lat1, double lon1, double lat2, double lon2) {
        if (!esValida(lat1, lon1) || !esValida(lat2, lon2)) return -1;

        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);

        return RADIO_TIERRA_KM * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    /** (0,0) se trata como "sin ubicacion", no como un punto del Atlantico. */
    public static boolean esValida(double lat, double lon) {
        if (lat == 0 && lon == 0) return false;
        return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
    }

    /**
     * Texto aproximado para mostrar en pantalla. Se habla siempre de cifras
     * redondas para no dar una falsa sensacion de exactitud.
     */
    public static String textoDistancia(double km) {
        if (km < 0) return "";
        if (km < 1) return "A menos de 1 km";
        if (km < 10) return "A unos " + Math.round(km) + " km";
        if (km < 50) return "A unos " + (Math.round(km / 5) * 5) + " km";
        return "A más de 50 km";
    }
}
