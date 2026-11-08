package com.skillswap;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import com.skillswap.model.Exchange;
import com.skillswap.model.PassportEntry;
import com.skillswap.model.PointEntry;
import com.skillswap.model.User;
import com.skillswap.utils.LeaderboardEngine;
import com.skillswap.utils.LearningPathEngine;
import com.skillswap.utils.ReliabilityEngine;
import com.skillswap.utils.ScheduleMatcher;
import com.skillswap.utils.WeeklyDigestEngine;

import org.junit.Test;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Pruebas de las innovaciones 7 a 12.
 *
 * Todas son logica pura (sin Android ni Firebase), asi que se pueden
 * ejecutar con `gradlew testDebugUnitTest` y sirven para demostrar que los
 * calculos no son inventados ni aleatorios.
 */
public class InnovacionesTest {

    // ===================================================== INNOVACION 7

    @Test
    public void horarios_detectaFranjaCompartida() {
        List<String> cesar = Arrays.asList("Lunes a Viernes - Noche");
        List<String> ana = Arrays.asList("Lunes a Viernes - Noche");

        List<ScheduleMatcher.Franja> f = ScheduleMatcher.coincidencias(cesar, ana);

        // Cinco dias de lunes a viernes, todos por la noche.
        assertEquals(5, f.size());
        assertEquals("Lunes", f.get(0).getDia());
        assertEquals("Noche", f.get(0).getMomento());
    }

    @Test
    public void horarios_sinCoincidenciaDevuelveVacio() {
        List<String> a = Arrays.asList("Lunes a Viernes - Noche");
        List<String> b = Arrays.asList("Sabados - Manana");

        assertTrue(ScheduleMatcher.coincidencias(a, b).isEmpty());
        assertEquals("Sin horarios en común", ScheduleMatcher.resumen(a, b));
    }

    @Test
    public void horarios_mismoDiaDistintoMomentoNoCoincide() {
        List<String> a = Arrays.asList("Lunes a Viernes - Mañana");
        List<String> b = Arrays.asList("Lunes a Viernes - Noche");

        assertEquals(0, ScheduleMatcher.cuantasCoinciden(a, b));
    }

    @Test
    public void horarios_etiquetaCalculaLaHoraFinal() {
        List<String> a = Arrays.asList("Sábados - Mañana");
        List<String> b = Arrays.asList("Sabados - Manana");

        List<ScheduleMatcher.Franja> f = ScheduleMatcher.coincidencias(a, b);
        assertEquals(1, f.size());
        // La mañana empieza a las 9; 90 minutos redondean a 2 horas.
        assertEquals("Sábado 09:00 - 11:00", f.get(0).etiqueta(90));
    }

    @Test
    public void horarios_ordenaDeLunesADomingo() {
        List<String> a = Arrays.asList("Sabados - Noche", "Lunes - Noche");
        List<String> b = Arrays.asList("Sabados - Noche", "Lunes - Noche");

        List<ScheduleMatcher.Franja> f = ScheduleMatcher.coincidencias(a, b);
        assertEquals("Lunes", f.get(0).getDia());
        assertEquals("Sábado", f.get(f.size() - 1).getDia());
    }

    @Test
    public void horarios_toleraListasNulas() {
        assertTrue(ScheduleMatcher.coincidencias(null, null).isEmpty());
    }

    // ===================================================== INNOVACION 8

    @Test
    public void confiabilidad_sinHistorialNoCalcula() {
        ReliabilityEngine.Resultado r =
                ReliabilityEngine.calcular(new User(), 0, 0, 0, 0);

        assertFalse(r.tieneSuficientesDatos());
        assertEquals(0, r.getPuntaje());
        assertEquals("Sin historial", r.getEtiqueta());
    }

    @Test
    public void confiabilidad_perfilImpecableEsAlto() {
        ReliabilityEngine.Resultado r =
                ReliabilityEngine.calcular(new User(), 10, 0, 5.0, 10);

        assertTrue(r.tieneSuficientesDatos());
        assertEquals(100, r.getPuntaje());
        assertTrue(r.esFiable());
        assertEquals("Muy confiable", r.getEtiqueta());
    }

    @Test
    public void confiabilidad_abandonarBajaElPuntaje() {
        ReliabilityEngine.Resultado bueno =
                ReliabilityEngine.calcular(new User(), 4, 0, 4.0, 4);
        ReliabilityEngine.Resultado malo =
                ReliabilityEngine.calcular(new User(), 2, 6, 4.0, 2);

        assertTrue(malo.getPuntaje() < bueno.getPuntaje());
        assertFalse(malo.esFiable());
    }

    @Test
    public void confiabilidad_explicaSusMotivos() {
        ReliabilityEngine.Resultado r =
                ReliabilityEngine.calcular(new User(), 3, 0, 4.5, 3);

        assertFalse(r.getMotivos().isEmpty());
        assertTrue(r.getMotivos().get(0).contains("3"));
    }

    @Test
    public void confiabilidad_esDeterminista() {
        int primero = ReliabilityEngine.calcular(new User(), 5, 1, 4.2, 4).getPuntaje();
        for (int i = 0; i < 20; i++) {
            assertEquals(primero,
                    ReliabilityEngine.calcular(new User(), 5, 1, 4.2, 4).getPuntaje());
        }
    }

    // ===================================================== INNOVACION 9

    @Test
    public void rutas_sinPasaporteTodoPendiente() {
        List<LearningPathEngine.Ruta> rutas =
                LearningPathEngine.rutasDe(new ArrayList<>());

        assertEquals(LearningPathEngine.totalRutas(), rutas.size());
        for (LearningPathEngine.Ruta r : rutas) {
            assertEquals(0, r.getProgreso());
            assertFalse(r.estaTerminada());
        }
    }

    @Test
    public void rutas_marcaCompletadoLoQueEstaEnElPasaporte() {
        List<PassportEntry> pasaporte = new ArrayList<>();
        pasaporte.add(entrada("Java"));

        LearningPathEngine.Ruta android = buscarRuta("Desarrollo Android",
                LearningPathEngine.rutasDe(pasaporte));

        assertNotNull(android);
        assertEquals(1, android.getCompletados());
        assertTrue(android.getProgreso() > 0);
    }

    @Test
    public void rutas_elSiguientePasoEsElPrimerPendiente() {
        List<PassportEntry> pasaporte = new ArrayList<>();
        pasaporte.add(entrada("Java"));

        LearningPathEngine.Ruta android = buscarRuta("Desarrollo Android",
                LearningPathEngine.rutasDe(pasaporte));

        assertNotNull(android);
        assertEquals("POO", android.siguientePaso().getHabilidad());
    }

    @Test
    public void rutas_comparaSinTildesNiMayusculas() {
        List<PassportEntry> pasaporte = new ArrayList<>();
        pasaporte.add(entrada("inglés"));

        LearningPathEngine.Ruta ingles = buscarRuta("Inglés técnico",
                LearningPathEngine.rutasDe(pasaporte));

        assertNotNull(ingles);
        assertEquals(1, ingles.getCompletados());
    }

    @Test
    public void rutas_recomiendaLaMasAvanzadaSinTerminar() {
        List<PassportEntry> pasaporte = new ArrayList<>();
        pasaporte.add(entrada("Java"));
        pasaporte.add(entrada("POO"));

        LearningPathEngine.Ruta recomendada =
                LearningPathEngine.rutaRecomendada(pasaporte);

        assertNotNull(recomendada);
        assertEquals("Desarrollo Android", recomendada.getNombre());
    }

    @Test
    public void rutas_rutaTerminadaNoSeRecomienda() {
        List<PassportEntry> pasaporte = new ArrayList<>();
        for (String h : Arrays.asList("Inglés", "Lectura técnica", "Conversación")) {
            pasaporte.add(entrada(h));
        }

        LearningPathEngine.Ruta ingles = buscarRuta("Inglés técnico",
                LearningPathEngine.rutasDe(pasaporte));

        assertNotNull(ingles);
        assertTrue(ingles.estaTerminada());
        assertNull(ingles.siguientePaso());
    }

    // ===================================================== INNOVACION 10

    @Test
    public void tabla_ordenaPorPuntosDescendente() {
        List<User> todos = Arrays.asList(
                usuario("a", "Ana", 50), usuario("b", "Beto", 120), usuario("c", "Caro", 80));

        LeaderboardEngine.Tabla t = LeaderboardEngine.construir(
                todos, null, LeaderboardEngine.AMBITO_TODOS, 10);

        assertEquals("Beto", t.getPuestos().get(0).getUsuario().getFirstName());
        assertEquals(1, t.getPuestos().get(0).getPosicion());
        assertEquals("Ana", t.getPuestos().get(2).getUsuario().getFirstName());
    }

    @Test
    public void tabla_losEmpatesCompartenPosicion() {
        List<User> todos = Arrays.asList(
                usuario("a", "Ana", 100), usuario("b", "Beto", 100), usuario("c", "Caro", 50));

        LeaderboardEngine.Tabla t = LeaderboardEngine.construir(
                todos, null, LeaderboardEngine.AMBITO_TODOS, 10);

        assertEquals(1, t.getPuestos().get(0).getPosicion());
        assertEquals(1, t.getPuestos().get(1).getPosicion());
        // El siguiente es tercero, no segundo.
        assertEquals(3, t.getPuestos().get(2).getPosicion());
    }

    @Test
    public void tabla_excluyeAQuienNoTienePuntos() {
        List<User> todos = Arrays.asList(
                usuario("a", "Ana", 10), usuario("b", "Beto", 0));

        LeaderboardEngine.Tabla t = LeaderboardEngine.construir(
                todos, null, LeaderboardEngine.AMBITO_TODOS, 10);

        assertEquals(1, t.getPuestos().size());
        assertEquals(1, t.getTotalParticipantes());
    }

    @Test
    public void tabla_siempreIncluyeAlUsuarioAunqueQuedeFuera() {
        List<User> todos = new ArrayList<>();
        for (int i = 0; i < 10; i++) {
            todos.add(usuario("u" + i, "User" + i, 100 - i));
        }
        User yo = usuario("yo", "Cesar", 1);
        todos.add(yo);

        LeaderboardEngine.Tabla t = LeaderboardEngine.construir(
                todos, yo, LeaderboardEngine.AMBITO_TODOS, 3);

        // 3 del corte + mi fila anadida al final.
        assertEquals(4, t.getPuestos().size());
        assertTrue(t.getPuestos().get(3).esElUsuarioActual());
        assertEquals(11, t.getMiPosicion());
    }

    @Test
    public void tabla_filtraPorUniversidad() {
        User yo = usuario("yo", "Cesar", 100);
        yo.setUniversity("UPN");
        User otro = usuario("o", "Otro", 200);
        otro.setUniversity("Otra");

        LeaderboardEngine.Tabla t = LeaderboardEngine.construir(
                Arrays.asList(yo, otro), yo, LeaderboardEngine.AMBITO_UNIVERSIDAD, 10);

        assertEquals(1, t.getTotalParticipantes());
        assertEquals("Cesar", t.getPuestos().get(0).getUsuario().getFirstName());
    }

    @Test
    public void tabla_listaVaciaNoRompe() {
        LeaderboardEngine.Tabla t = LeaderboardEngine.construir(
                new ArrayList<>(), null, LeaderboardEngine.AMBITO_TODOS, 10);

        assertTrue(t.getPuestos().isEmpty());
        assertFalse(t.estoyEnLaTabla());
    }

    // ===================================================== INNOVACION 12

    @Test
    public void resumen_sumaSoloLosUltimosSieteDias() {
        long ahora = 1_700_000_000_000L;
        long dia = 24L * 60 * 60 * 1000;

        List<PointEntry> historial = Arrays.asList(
                punto(10, ahora - 2 * dia),     // esta semana
                punto(5, ahora - 6 * dia),      // esta semana
                punto(99, ahora - 10 * dia));   // semana anterior

        WeeklyDigestEngine.Resumen r =
                WeeklyDigestEngine.calcular(historial, new ArrayList<>(), ahora);

        assertEquals(15, r.getPuntosGanados());
        assertEquals(99, r.getPuntosSemanaAnterior());
        assertEquals(-84, r.getDiferencia());
    }

    @Test
    public void resumen_cuentaSesionesPorElMotivo() {
        long ahora = 1_700_000_000_000L;
        long dia = 24L * 60 * 60 * 1000;

        List<PointEntry> historial = Arrays.asList(
                puntoCon(15, ahora - dia, "Sesión registrada"),
                puntoCon(15, ahora - 2 * dia, "Sesion registrada"),
                puntoCon(25, ahora - 3 * dia, "Intercambio completado"));

        WeeklyDigestEngine.Resumen r =
                WeeklyDigestEngine.calcular(historial, new ArrayList<>(), ahora);

        assertEquals(2, r.getSesionesRegistradas());
    }

    @Test
    public void resumen_semanaSinActividad() {
        WeeklyDigestEngine.Resumen r = WeeklyDigestEngine.calcular(
                new ArrayList<>(), new ArrayList<>(), 1_700_000_000_000L);

        assertFalse(r.huboActividad());
        assertEquals("Semana tranquila: ningún punto esta vez", r.titular());
    }

    @Test
    public void resumen_distribuyeLosPuntosPorDia() {
        long ahora = 1_700_000_000_000L;
        long dia = 24L * 60 * 60 * 1000;

        List<PointEntry> historial = Arrays.asList(punto(8, ahora - dia));

        WeeklyDigestEngine.Resumen r =
                WeeklyDigestEngine.calcular(historial, new ArrayList<>(), ahora);

        assertEquals(8, r.getMaximoDiario());
        assertEquals(7, r.getPuntosPorDia().length);
    }

    @Test
    public void resumen_cuentaIntercambiosActivos() {
        long ahora = 1_700_000_000_000L;

        Exchange activo = new Exchange();
        activo.setStatus(Exchange.STATUS_IN_PROGRESS);
        Exchange cerrado = new Exchange();
        cerrado.setStatus(Exchange.STATUS_COMPLETED);
        cerrado.setUpdatedAt(ahora - 1000);

        WeeklyDigestEngine.Resumen r = WeeklyDigestEngine.calcular(
                new ArrayList<>(), Arrays.asList(activo, cerrado), ahora);

        assertEquals(1, r.getIntercambiosActivos());
        assertEquals(1, r.getIntercambiosCerrados());
    }

    @Test
    public void resumen_aconsejaSegunLoQueFalta() {
        WeeklyDigestEngine.Resumen sinNada = WeeklyDigestEngine.calcular(
                new ArrayList<>(), new ArrayList<>(), 1_700_000_000_000L);

        assertTrue(sinNada.consejo().contains("Explorar"));
    }

    @Test
    public void resumen_sieteEtiquetasDeDia() {
        assertEquals(7, WeeklyDigestEngine.etiquetasDias(1_700_000_000_000L).length);
    }

    // ===================================================== ayudas

    private PassportEntry entrada(String habilidad) {
        PassportEntry e = new PassportEntry();
        e.setSkillName(habilidad);
        return e;
    }

    private User usuario(String uid, String nombre, int puntos) {
        User u = new User();
        u.setUid(uid);
        u.setFirstName(nombre);
        u.setSkillPoints(puntos);
        return u;
    }

    private PointEntry punto(int puntos, long cuando) {
        return puntoCon(puntos, cuando, "Actividad");
    }

    private PointEntry puntoCon(int puntos, long cuando, String motivo) {
        PointEntry p = new PointEntry();
        p.setPoints(puntos);
        p.setCreatedAt(cuando);
        p.setReason(motivo);
        return p;
    }

    private LearningPathEngine.Ruta buscarRuta(String nombre,
                                               List<LearningPathEngine.Ruta> rutas) {
        for (LearningPathEngine.Ruta r : rutas) {
            if (r.getNombre().equals(nombre)) return r;
        }
        return null;
    }
}
