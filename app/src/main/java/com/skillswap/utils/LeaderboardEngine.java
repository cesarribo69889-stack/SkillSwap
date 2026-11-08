package com.skillswap.utils;

import com.skillswap.model.User;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * INNOVACION 10 - Tabla de lideres.
 *
 * Ordena a los estudiantes por SkillPoints y permite acotar el ranking a
 * la propia universidad o carrera, que es donde la comparacion motiva de
 * verdad: competir con tu salon, no con desconocidos.
 *
 * Detalles que importan:
 *   · Los empates comparten posicion (dos primeros, luego el tercero es 3.º).
 *   · Siempre se calcula la posicion del usuario actual, aunque no entre
 *     en los primeros puestos, para que nunca vea una tabla sin si mismo.
 *   · Se excluye a quien no tiene puntos: aparecer con 0 no motiva a nadie.
 *
 * AVISO: los SkillPoints son reconocimiento dentro de la app. Esta tabla no
 * representa rendimiento academico.
 */
public final class LeaderboardEngine {

    public static final int AMBITO_TODOS      = 0;
    public static final int AMBITO_UNIVERSIDAD = 1;
    public static final int AMBITO_CARRERA     = 2;

    private LeaderboardEngine() {
    }

    /** Una fila de la tabla. */
    public static class Puesto {
        private final int posicion;
        private final User usuario;
        private final boolean esYo;

        Puesto(int posicion, User usuario, boolean esYo) {
            this.posicion = posicion;
            this.usuario = usuario;
            this.esYo = esYo;
        }

        public int getPosicion() { return posicion; }
        public User getUsuario() { return usuario; }
        public boolean esElUsuarioActual() { return esYo; }

        /** Medalla para los tres primeros. */
        public String getMedalla() {
            switch (posicion) {
                case 1:  return "🥇";
                case 2:  return "🥈";
                case 3:  return "🥉";
                default: return String.valueOf(posicion);
            }
        }
    }

    /** La tabla completa mas la posicion del usuario actual. */
    public static class Tabla {
        private final List<Puesto> puestos = new ArrayList<>();
        private int miPosicion = 0;
        private int totalParticipantes = 0;

        public List<Puesto> getPuestos() { return puestos; }
        public int getMiPosicion() { return miPosicion; }
        public int getTotalParticipantes() { return totalParticipantes; }
        public boolean estoyEnLaTabla() { return miPosicion > 0; }

        public String resumenPersonal() {
            if (miPosicion <= 0) return "Completa un intercambio para entrar en la tabla";
            if (miPosicion == 1) return "Vas primero 🥇";
            return "Vas en el puesto " + miPosicion + " de " + totalParticipantes;
        }
    }

    /**
     * Construye la tabla.
     *
     * @param todos    todos los estudiantes leidos de Firestore
     * @param yo       el usuario actual (puede ser null)
     * @param ambito   AMBITO_TODOS, AMBITO_UNIVERSIDAD o AMBITO_CARRERA
     * @param limite   cuantos puestos devolver como maximo
     */
    public static Tabla construir(List<User> todos, User yo, int ambito, int limite) {
        Tabla tabla = new Tabla();
        if (todos == null || todos.isEmpty()) return tabla;

        // 1. Filtrar por ambito y descartar a quien no tiene puntos.
        List<User> candidatos = new ArrayList<>();
        for (User u : todos) {
            if (u == null || u.getSkillPoints() <= 0) continue;
            if (!entraEnAmbito(u, yo, ambito)) continue;
            candidatos.add(u);
        }
        if (candidatos.isEmpty()) return tabla;

        // 2. Ordenar: mas puntos primero; a igualdad, mas intercambios; luego nombre.
        Collections.sort(candidatos, new Comparator<User>() {
            @Override
            public int compare(User a, User b) {
                int p = Integer.compare(b.getSkillPoints(), a.getSkillPoints());
                if (p != 0) return p;
                int e = Integer.compare(b.getExchangesCount(), a.getExchangesCount());
                if (e != 0) return e;
                return seguro(a.getFullName()).compareToIgnoreCase(seguro(b.getFullName()));
            }
        });

        tabla.totalParticipantes = candidatos.size();
        String miUid = yo == null ? null : yo.getUid();

        // 3. Asignar posiciones con empates compartidos.
        int posicion = 0;
        int anteriorPuntos = Integer.MIN_VALUE;
        for (int i = 0; i < candidatos.size(); i++) {
            User u = candidatos.get(i);
            if (u.getSkillPoints() != anteriorPuntos) {
                posicion = i + 1;
                anteriorPuntos = u.getSkillPoints();
            }
            boolean esYo = miUid != null && miUid.equals(u.getUid());
            if (esYo) tabla.miPosicion = posicion;

            if (tabla.puestos.size() < limite) {
                tabla.puestos.add(new Puesto(posicion, u, esYo));
            }
        }

        // 4. Si el usuario quedo fuera del corte, se anade al final para que se vea.
        if (tabla.miPosicion > limite && yo != null) {
            tabla.puestos.add(new Puesto(tabla.miPosicion, yo, true));
        }
        return tabla;
    }

    private static boolean entraEnAmbito(User u, User yo, int ambito) {
        if (ambito == AMBITO_TODOS || yo == null) return true;
        if (ambito == AMBITO_UNIVERSIDAD) {
            return igual(u.getUniversity(), yo.getUniversity());
        }
        if (ambito == AMBITO_CARRERA) {
            return igual(u.getUniversity(), yo.getUniversity())
                    && igual(u.getCareer(), yo.getCareer());
        }
        return true;
    }

    private static boolean igual(String a, String b) {
        return seguro(a).equalsIgnoreCase(seguro(b));
    }

    private static String seguro(String s) {
        return s == null ? "" : s.trim();
    }

    public static String nombreDeAmbito(int ambito) {
        switch (ambito) {
            case AMBITO_UNIVERSIDAD: return "Mi universidad";
            case AMBITO_CARRERA:     return "Mi carrera";
            default:                 return "Todos";
        }
    }
}
