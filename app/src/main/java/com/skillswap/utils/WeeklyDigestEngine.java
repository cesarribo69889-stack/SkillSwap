package com.skillswap.utils;

import com.skillswap.model.Exchange;
import com.skillswap.model.PointEntry;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;

/**
 * INNOVACION 12 - Resumen semanal de progreso.
 *
 * Reune en una sola pantalla lo que el estudiante hizo en los ultimos 7 dias
 * y lo compara con la semana anterior. Todo sale de datos que ya existen
 * (intercambios, historial de SkillPoints): no se guarda nada nuevo.
 *
 * La idea es cerrar el ciclo de la gamificacion: los puntos sueltos no
 * dicen gran cosa, pero "esta semana ganaste 23 puntos, 8 mas que la
 * pasada" si.
 */
public final class WeeklyDigestEngine {

    private static final long DIA = 24L * 60 * 60 * 1000;
    private static final long SEMANA = 7 * DIA;

    private WeeklyDigestEngine() {
    }

    /** El resumen de una semana. */
    public static class Resumen {
        private int puntosGanados;
        private int sesionesRegistradas;
        private int intercambiosCerrados;
        private int intercambiosActivos;
        private int diasActivos;
        private int puntosSemanaAnterior;
        private final int[] puntosPorDia = new int[7];   // indice 0 = hace 6 dias

        public int getPuntosGanados() { return puntosGanados; }
        public int getSesionesRegistradas() { return sesionesRegistradas; }
        public int getIntercambiosCerrados() { return intercambiosCerrados; }
        public int getIntercambiosActivos() { return intercambiosActivos; }
        public int getDiasActivos() { return diasActivos; }
        public int getPuntosSemanaAnterior() { return puntosSemanaAnterior; }
        public int[] getPuntosPorDia() { return puntosPorDia; }

        /** Diferencia con la semana pasada. Positivo = mejoro. */
        public int getDiferencia() {
            return puntosGanados - puntosSemanaAnterior;
        }

        public boolean huboActividad() {
            return puntosGanados > 0 || sesionesRegistradas > 0
                    || intercambiosCerrados > 0;
        }

        /** El valor mas alto de la semana, para escalar el grafico. */
        public int getMaximoDiario() {
            int max = 0;
            for (int v : puntosPorDia) max = Math.max(max, v);
            return max;
        }

        /** Frase principal del resumen. */
        public String titular() {
            if (!huboActividad()) {
                return "Semana tranquila: ningún punto esta vez";
            }
            if (puntosSemanaAnterior == 0) {
                return String.format(Locale.getDefault(),
                        "Ganaste %d SkillPoints esta semana", puntosGanados);
            }
            int dif = getDiferencia();
            if (dif > 0) {
                return String.format(Locale.getDefault(),
                        "Ganaste %d SkillPoints, %d más que la semana pasada",
                        puntosGanados, dif);
            }
            if (dif < 0) {
                return String.format(Locale.getDefault(),
                        "Ganaste %d SkillPoints, %d menos que la semana pasada",
                        puntosGanados, -dif);
            }
            return String.format(Locale.getDefault(),
                    "Ganaste %d SkillPoints, igual que la semana pasada", puntosGanados);
        }

        /** Sugerencia concreta segun lo que falto. */
        public String consejo() {
            if (intercambiosActivos == 0) {
                return "No tienes intercambios activos. Busca a alguien en Explorar.";
            }
            if (sesionesRegistradas == 0) {
                return "Tienes intercambios abiertos pero no registraste sesiones. "
                        + "Anota tu avance para que cuente.";
            }
            if (diasActivos <= 2) {
                return "Repartir las sesiones en más días rinde mejor que juntarlas.";
            }
            return "Buen ritmo. Mantenlo la próxima semana.";
        }
    }

    /**
     * Calcula el resumen de los ultimos 7 dias.
     *
     * @param historial  movimientos de SkillPoints del usuario
     * @param misIntercambios  intercambios en los que participa
     * @param ahora      instante de referencia (se inyecta para poder probarlo)
     */
    public static Resumen calcular(List<PointEntry> historial,
                                   List<Exchange> misIntercambios,
                                   long ahora) {
        Resumen r = new Resumen();
        long inicioSemana = ahora - SEMANA;
        long inicioAnterior = ahora - 2 * SEMANA;

        List<Integer> diasVistos = new ArrayList<>();

        if (historial != null) {
            for (PointEntry p : historial) {
                long t = p.getCreatedAt();
                if (t <= 0) continue;

                if (t >= inicioSemana && t <= ahora) {
                    r.puntosGanados += p.getPoints();

                    int indice = (int) ((t - inicioSemana) / DIA);
                    if (indice >= 0 && indice < 7) {
                        r.puntosPorDia[indice] += p.getPoints();
                    }

                    int dia = diaDelAno(t);
                    if (!diasVistos.contains(dia)) diasVistos.add(dia);

                    String motivo = p.getReason() == null ? "" : p.getReason().toLowerCase();
                    if (motivo.contains("sesion") || motivo.contains("sesión")) {
                        r.sesionesRegistradas++;
                    }
                } else if (t >= inicioAnterior && t < inicioSemana) {
                    r.puntosSemanaAnterior += p.getPoints();
                }
            }
        }
        r.diasActivos = diasVistos.size();

        if (misIntercambios != null) {
            for (Exchange e : misIntercambios) {
                if (e == null) continue;
                if (Exchange.STATUS_IN_PROGRESS.equals(e.getStatus())
                        || Exchange.STATUS_UPCOMING.equals(e.getStatus())) {
                    r.intercambiosActivos++;
                }
                if (Exchange.STATUS_COMPLETED.equals(e.getStatus())
                        && e.getUpdatedAt() >= inicioSemana) {
                    r.intercambiosCerrados++;
                }
            }
        }
        return r;
    }

    private static int diaDelAno(long millis) {
        Calendar c = Calendar.getInstance();
        c.setTimeInMillis(millis);
        return c.get(Calendar.YEAR) * 1000 + c.get(Calendar.DAY_OF_YEAR);
    }

    /** Etiquetas de los 7 dias, de mas antiguo a hoy. */
    public static String[] etiquetasDias(long ahora) {
        String[] nombres = {"D", "L", "M", "X", "J", "V", "S"};
        String[] out = new String[7];
        Calendar c = Calendar.getInstance();
        for (int i = 0; i < 7; i++) {
            c.setTimeInMillis(ahora - (6L - i) * DIA);
            out[i] = nombres[c.get(Calendar.DAY_OF_WEEK) - 1];
        }
        return out;
    }
}
