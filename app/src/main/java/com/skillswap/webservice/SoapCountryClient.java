package com.skillswap.webservice;

import android.os.Handler;
import android.os.Looper;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * RC2 - Servicio SOAP (XML).
 *
 * Consume CountryInfoService para completar el pais y el idioma del perfil.
 *
 * El sobre SOAP se arma a mano con HttpURLConnection en vez de usar
 * ksoap2-android, porque esa libreria ya no se publica en Maven Central.
 * Hacerlo asi deja a la vista la diferencia real con REST: aqui hay que
 * construir un documento XML (Envelope + Body), declarar el espacio de
 * nombres y enviar la cabecera SOAPAction, mientras que en REST basta una
 * peticion GET.
 */
public final class SoapCountryClient {

    public interface Callback {
        void onResultado(String valor);
        void onError(String mensaje);
    }

    private static final String ENDPOINT =
            "http://webservices.oorsprong.org/websamples.countryinfo/CountryInfoService.wso";
    private static final String NS = "http://www.oorsprong.org/websamples.countryinfo";

    private static final ExecutorService IO = Executors.newSingleThreadExecutor();

    /**
     * El Handler se crea cuando hace falta, no en un campo estatico: asi
     * construirSobre() y extraer() se pueden probar con JUnit puro, sin que
     * Looper.getMainLooper() reviente al cargar la clase.
     */
    private static Handler main;

    private static Handler main() {
        if (main == null) main = new Handler(Looper.getMainLooper());
        return main;
    }

    private SoapCountryClient() {
    }

    /** Nombre del pais a partir del codigo ISO ("PE" -> "Peru"). */
    public static void nombreDePais(final String codigoIso, final Callback callback) {
        llamar("CountryName", "sCountryISOCode", codigoIso,
                "CountryNameResult", callback);
    }

    /** Nombre del idioma a partir del codigo ISO ("es" -> "Spanish"). */
    public static void nombreDeIdioma(final String codigoIso, final Callback callback) {
        llamar("LanguageName", "sISOCode", codigoIso,
                "LanguageNameResult", callback);
    }

    // ---------------------------------------------------------------------

    private static void llamar(final String operacion, final String parametro,
                               final String valor, final String etiquetaResultado,
                               final Callback callback) {
        IO.execute(() -> {
            HttpURLConnection con = null;
            try {
                String sobre = construirSobre(operacion, parametro, valor);

                con = (HttpURLConnection) new URL(ENDPOINT).openConnection();
                con.setRequestMethod("POST");
                con.setRequestProperty("Content-Type", "text/xml; charset=utf-8");
                con.setRequestProperty("SOAPAction", NS + "/" + operacion);
                con.setConnectTimeout(15000);
                con.setReadTimeout(15000);
                con.setDoOutput(true);

                byte[] cuerpo = sobre.getBytes(StandardCharsets.UTF_8);
                con.setFixedLengthStreamingMode(cuerpo.length);
                try (OutputStream os = con.getOutputStream()) {
                    os.write(cuerpo);
                }

                int codigo = con.getResponseCode();
                if (codigo != 200) {
                    fallo(callback, "El servicio respondió " + codigo);
                    return;
                }

                String xml = leer(con.getInputStream());
                final String resultado = extraer(xml, etiquetaResultado);

                if (resultado == null) {
                    fallo(callback, "Respuesta SOAP sin el dato esperado");
                } else {
                    main().post(() -> callback.onResultado(resultado));
                }
            } catch (Exception e) {
                // Si el servicio falla o no hay conexion, el campo se deja
                // como texto libre y la aplicacion sigue funcionando.
                fallo(callback, "No se pudo consultar el servicio");
            } finally {
                if (con != null) con.disconnect();
            }
        });
    }

    /** Documento XML que exige SOAP: Envelope -> Body -> operacion. */
    public static String construirSobre(String operacion, String parametro, String valor) {
        return "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                + "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                + "<soap:Body>"
                + "<" + operacion + " xmlns=\"" + NS + "\">"
                + "<" + parametro + ">" + escapar(valor) + "</" + parametro + ">"
                + "</" + operacion + ">"
                + "</soap:Body>"
                + "</soap:Envelope>";
    }

    /**
     * Saca el texto de la etiqueta de resultado. La respuesta la devuelve con
     * prefijo de espacio de nombres (m:CountryNameResult), por eso se busca
     * por el nombre local y no por la etiqueta completa.
     */
    public static String extraer(String xml, String etiqueta) {
        if (xml == null) return null;
        int inicio = xml.indexOf(etiqueta + ">");
        if (inicio < 0) return null;
        inicio = xml.indexOf('>', inicio) + 1;
        int fin = xml.indexOf("</", inicio);
        if (fin < 0 || fin < inicio) return null;
        return desescapar(xml.substring(inicio, fin).trim());
    }

    private static String leer(InputStream in) throws Exception {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader r = new BufferedReader(
                new InputStreamReader(in, StandardCharsets.UTF_8))) {
            String linea;
            while ((linea = r.readLine()) != null) sb.append(linea);
        }
        return sb.toString();
    }

    private static void fallo(final Callback callback, final String mensaje) {
        main().post(() -> callback.onError(mensaje));
    }

    private static String escapar(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }

    private static String desescapar(String s) {
        return s.replace("&amp;", "&").replace("&lt;", "<").replace("&gt;", ">");
    }
}
