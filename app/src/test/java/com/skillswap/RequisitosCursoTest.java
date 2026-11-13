package com.skillswap;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertTrue;

import com.skillswap.repository.SignatureRepository;
import com.skillswap.utils.GeoUtils;
import com.skillswap.webservice.SoapCountryClient;

import org.junit.Test;

/**
 * Pruebas de los requisitos del curso que son logica pura:
 *   RC2 - armado y lectura del sobre SOAP
 *   RC3 - huella SHA-256 del texto aceptado
 *   RC4 - distancias y redondeo de la ubicacion
 *
 * RC1 (Room) y la parte de red no entran aqui: necesitan instrumentacion.
 */
public class RequisitosCursoTest {

    // ===================================================== RC2 (SOAP)

    @Test
    public void soap_elSobreLlevaEnvelopeBodyYEspacioDeNombres() {
        String sobre = SoapCountryClient.construirSobre(
                "CountryName", "sCountryISOCode", "PE");

        assertTrue(sobre.contains("soap:Envelope"));
        assertTrue(sobre.contains("soap:Body"));
        assertTrue(sobre.contains("http://schemas.xmlsoap.org/soap/envelope/"));
        assertTrue(sobre.contains("http://www.oorsprong.org/websamples.countryinfo"));
        assertTrue(sobre.contains("<sCountryISOCode>PE</sCountryISOCode>"));
    }

    @Test
    public void soap_escapaLosCaracteresQueRompenElXml() {
        String sobre = SoapCountryClient.construirSobre("Op", "p", "a<b&c");

        assertTrue(sobre.contains("a&lt;b&amp;c"));
        assertFalse(sobre.contains("a<b&c"));
    }

    @Test
    public void soap_leeElResultadoAunqueVengaConPrefijo() {
        String respuesta = "<?xml version=\"1.0\"?>"
                + "<soap:Envelope><soap:Body>"
                + "<m:CountryNameResponse xmlns:m=\"x\">"
                + "<m:CountryNameResult>Peru</m:CountryNameResult>"
                + "</m:CountryNameResponse>"
                + "</soap:Body></soap:Envelope>";

        assertEquals("Peru", SoapCountryClient.extraer(respuesta, "CountryNameResult"));
    }

    @Test
    public void soap_siNoEstaLaEtiquetaDevuelveNull() {
        assertEquals(null, SoapCountryClient.extraer("<a>1</a>", "NoExiste"));
    }

    // ===================================================== RC3 (firma)

    @Test
    public void huella_tieneSesentaYCuatroCaracteresHex() {
        String h = SignatureRepository.sha256("Acepto el intercambio");

        assertEquals(64, h.length());
        assertTrue(h.matches("[0-9a-f]{64}"));
    }

    @Test
    public void huella_esEstableParaElMismoTexto() {
        String texto = "Tú enseñas Java y aprendes Figma con Marcelo.";
        assertEquals(SignatureRepository.sha256(texto),
                SignatureRepository.sha256(texto));
    }

    @Test
    public void huella_cambiaSiCambiaUnaLetra() {
        assertNotEquals(SignatureRepository.sha256("Acepto el intercambio"),
                SignatureRepository.sha256("Acepto el Intercambio"));
    }

    @Test
    public void huella_valorConocidoDeSha256() {
        // Vector de prueba estandar: SHA-256 de la cadena vacia.
        assertEquals("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                SignatureRepository.sha256(""));
    }

    // ===================================================== RC4 (ubicacion)

    @Test
    public void ubicacion_seRedondeaADosDecimales() {
        // Nunca debe guardarse la posicion exacta.
        assertEquals(-12.05, GeoUtils.redondear(-12.0463731), 0.0001);
        assertEquals(-77.04, GeoUtils.redondear(-77.0427934), 0.0001);
    }

    @Test
    public void distancia_entreDosPuntosConocidos() {
        // Plaza de Armas de Lima -> Universidad Privada del Norte (Los Olivos).
        double km = GeoUtils.distanciaKm(-12.0464, -77.0428, -11.9800, -77.0700);

        assertTrue("Esperaba entre 5 y 12 km, fue " + km, km > 5 && km < 12);
    }

    @Test
    public void distancia_mismoPuntoEsCero() {
        assertEquals(0.0, GeoUtils.distanciaKm(-12.05, -77.04, -12.05, -77.04), 0.001);
    }

    @Test
    public void distancia_sinUbicacionDevuelveMenosUno() {
        // (0,0) significa "sin ubicacion", no un punto en el Atlantico.
        assertEquals(-1, GeoUtils.distanciaKm(-12.05, -77.04, 0, 0), 0.001);
        assertFalse(GeoUtils.esValida(0, 0));
    }

    @Test
    public void distancia_rechazaCoordenadasImposibles() {
        assertFalse(GeoUtils.esValida(95, 10));
        assertFalse(GeoUtils.esValida(10, 200));
        assertTrue(GeoUtils.esValida(-12.05, -77.04));
    }

    @Test
    public void textoDistancia_hablaSiempreEnCifrasRedondas() {
        assertEquals("A menos de 1 km", GeoUtils.textoDistancia(0.4));
        assertEquals("A unos 3 km", GeoUtils.textoDistancia(3.2));
        assertEquals("A más de 50 km", GeoUtils.textoDistancia(80));
        assertEquals("", GeoUtils.textoDistancia(-1));
    }
}
