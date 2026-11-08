package com.skillswap.utils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * INNOVACION 7 - Coincidencia de horarios.
 *
 * Cruza los bloques de disponibilidad de dos estudiantes y propone franjas
 * concretas en las que ambos pueden. No usa azar ni servicios externos: es
 * una interseccion de conjuntos sobre los bloques que cada uno eligio en su
 * perfil ("Lunes a Viernes - Noche", "Sabados - Manana", ...).
 *
 * El problema que resuelve: hasta ahora dos estudiantes compatibles tenian
 * que negociar el horario por chat. Esto les da el punto de partida.
 */
public final class ScheduleMatcher {

    /** Dias que abarca cada etiqueta de bloque. */
    private static final String[] DIAS_SEMANA =
            {"Lunes", "Martes", "Miércoles", "Jueves", "Viernes"};
    private static final String[] DIAS_FINDE = {"Sábado", "Domingo"};

    /** Hora sugerida de inicio segun la franja del dia. */
    private static final int HORA_MANANA = 9;
    private static final int HORA_TARDE  = 15;
    private static final int HORA_NOCHE  = 19;

    private ScheduleMatcher() {
    }

    /** Una franja concreta en la que ambos coinciden. */
    public static class Franja {
        private final String dia;
        private final String momento;
        private final int horaInicio;

        public Franja(String dia, String momento, int horaInicio) {
            this.dia = dia;
            this.momento = momento;
            this.horaInicio = horaInicio;
        }

        public String getDia() { return dia; }
        public String getMomento() { return momento; }
        public int getHoraInicio() { return horaInicio; }

        /** "Martes 19:00 - 20:00" para una sesion de 60 minutos. */
        public String etiqueta(int minutos) {
            int fin = horaInicio + Math.max(1, (int) Math.ceil(minutos / 60.0));
            return String.format("%s %02d:00 - %02d:00", dia, horaInicio, fin);
        }

        @Override
        public String toString() {
            return dia + " " + momento;
        }
    }

    /**
     * Devuelve las franjas en las que ambos estudiantes pueden, ordenadas de
     * lunes a domingo. Lista vacia si no coinciden en nada.
     */
    public static List<Franja> coincidencias(List<String> bloquesA, List<String> bloquesB) {
        List<Franja> resultado = new ArrayList<>();
        if (bloquesA == null || bloquesB == null) return resultado;

        for (String a : bloquesA) {
            for (String b : bloquesB) {
                if (!mismoMomento(a, b)) continue;

                List<String> dias = diasComunes(a, b);
                String momento = momentoDe(a);
                int hora = horaDe(momento);

                for (String dia : dias) {
                    if (!yaEsta(resultado, dia, momento)) {
                        resultado.add(new Franja(dia, momento, hora));
                    }
                }
            }
        }

        Collections.sort(resultado, new Comparator<Franja>() {
            @Override
            public int compare(Franja x, Franja y) {
                int d = indiceDia(x.dia) - indiceDia(y.dia);
                return d != 0 ? d : x.horaInicio - y.horaInicio;
            }
        });
        return resultado;
    }

    /** Resumen legible para mostrar en el perfil del otro estudiante. */
    public static String resumen(List<String> bloquesA, List<String> bloquesB) {
        List<Franja> f = coincidencias(bloquesA, bloquesB);
        if (f.isEmpty()) return "Sin horarios en común";
        if (f.size() == 1) return "Coinciden: " + f.get(0);

        StringBuilder sb = new StringBuilder("Coinciden en ");
        sb.append(f.size()).append(" franjas · ").append(f.get(0));
        return sb.toString();
    }

    /** Cuantas franjas comparten. Lo usa el SkillMatch para la disponibilidad. */
    public static int cuantasCoinciden(List<String> bloquesA, List<String> bloquesB) {
        return coincidencias(bloquesA, bloquesB).size();
    }

    // ------------------------------------------------------------------ util

    private static boolean yaEsta(List<Franja> lista, String dia, String momento) {
        for (Franja f : lista) {
            if (f.dia.equals(dia) && f.momento.equals(momento)) return true;
        }
        return false;
    }

    private static boolean mismoMomento(String a, String b) {
        return momentoDe(a).equals(momentoDe(b)) && !diasComunes(a, b).isEmpty();
    }

    /** "Mañana", "Tarde" o "Noche" a partir de la etiqueta del bloque. */
    private static String momentoDe(String bloque) {
        String s = normalizar(bloque);
        if (s.contains("manana")) return "Mañana";
        if (s.contains("tarde")) return "Tarde";
        if (s.contains("noche")) return "Noche";
        return "Día";
    }

    private static int horaDe(String momento) {
        switch (momento) {
            case "Mañana": return HORA_MANANA;
            case "Tarde":  return HORA_TARDE;
            case "Noche":  return HORA_NOCHE;
            default:       return HORA_TARDE;
        }
    }

    private static List<String> diasComunes(String a, String b) {
        List<String> da = diasDe(a);
        List<String> db = diasDe(b);
        List<String> comunes = new ArrayList<>();
        for (String d : da) {
            if (db.contains(d)) comunes.add(d);
        }
        return comunes;
    }

    /** Expande "Lunes a Viernes" a los cinco dias; "Sabados" a sabado. */
    private static List<String> diasDe(String bloque) {
        String s = normalizar(bloque);
        List<String> dias = new ArrayList<>();

        if (s.contains("lunes a viernes") || s.contains("entre semana")) {
            Collections.addAll(dias, DIAS_SEMANA);
            return dias;
        }
        if (s.contains("fin de semana")) {
            Collections.addAll(dias, DIAS_FINDE);
            return dias;
        }

        if (s.contains("lunes"))     dias.add("Lunes");
        if (s.contains("martes"))    dias.add("Martes");
        if (s.contains("miercoles")) dias.add("Miércoles");
        if (s.contains("jueves"))    dias.add("Jueves");
        if (s.contains("viernes"))   dias.add("Viernes");
        if (s.contains("sabado"))    dias.add("Sábado");
        if (s.contains("domingo"))   dias.add("Domingo");
        return dias;
    }

    private static int indiceDia(String dia) {
        switch (dia) {
            case "Lunes":     return 0;
            case "Martes":    return 1;
            case "Miércoles": return 2;
            case "Jueves":    return 3;
            case "Viernes":   return 4;
            case "Sábado":    return 5;
            case "Domingo":   return 6;
            default:          return 7;
        }
    }

    /** Minusculas y sin tildes, para comparar sin sorpresas. */
    private static String normalizar(String s) {
        if (s == null) return "";
        String r = s.toLowerCase();
        r = r.replace('á', 'a').replace('é', 'e').replace('í', 'i')
             .replace('ó', 'o').replace('ú', 'u').replace('ñ', 'n');
        return r;
    }
}
