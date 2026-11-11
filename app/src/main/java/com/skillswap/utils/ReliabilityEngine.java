package com.skillswap.utils;

import com.skillswap.model.User;

import java.util.ArrayList;
import java.util.List;

/**
 * INNOVACION 8 - Indice de confiabilidad.
 *
 * La reputacion (estrellas) dice si enseñas bien. Esto dice algo distinto:
 * si se puede contar contigo. Son cosas diferentes y por eso se calculan
 * aparte — alguien puede explicar de maravilla y aun asi dejar intercambios
 * a medias.
 *
 * Se obtiene de hechos ya registrados, no de opiniones:
 *   · intercambios cerrados frente a intercambios abandonados
 *   · puntualidad promedio recibida en las calificaciones
 *   · contratos aceptados (compromiso formal)
 *   · experiencia acumulada
 *
 * NO es una nota academica ni un historial crediticio: solo orienta a quien
 * esta decidiendo con quien intercambiar.
 */
public final class ReliabilityEngine {

    // Pesos sobre 100. Suman 100.
    private static final int P_CUMPLIMIENTO = 45;
    private static final int P_PUNTUALIDAD  = 25;
    private static final int P_COMPROMISO   = 15;
    private static final int P_EXPERIENCIA  = 15;

    /** A partir de aqui se considera un perfil fiable. */
    public static final int UMBRAL_FIABLE = 70;

    /** Por debajo de este numero de intercambios no hay datos suficientes. */
    private static final int MINIMO_PARA_CALCULAR = 1;

    private ReliabilityEngine() {
    }

    /** Resultado con el desglose, para poder explicarlo en pantalla. */
    public static class Resultado {
        private final int puntaje;
        private final boolean suficientesDatos;
        private final List<String> motivos = new ArrayList<>();

        Resultado(int puntaje, boolean suficientesDatos) {
            this.puntaje = puntaje;
            this.suficientesDatos = suficientesDatos;
        }

        public int getPuntaje() { return puntaje; }
        public boolean tieneSuficientesDatos() { return suficientesDatos; }
        public List<String> getMotivos() { return motivos; }
        public boolean esFiable() { return suficientesDatos && puntaje >= UMBRAL_FIABLE; }

        public String getEtiqueta() {
            if (!suficientesDatos) return "Sin historial";
            if (puntaje >= 85) return "Muy confiable";
            if (puntaje >= UMBRAL_FIABLE) return "Confiable";
            if (puntaje >= 50) return "En construcción";
            return "Historial irregular";
        }
    }

    /**
     * Calcula el indice.
     *
     * @param user            el estudiante
     * @param completados     intercambios que llegaron a COMPLETADO
     * @param abandonados     intercambios CANCELADOS
     * @param puntualidadMedia promedio de 1 a 5 recibido en puntualidad (0 si no hay)
     * @param contratosFirmados cuantos contratos de aprendizaje acepto
     */
    public static Resultado calcular(User user, int completados, int abandonados,
                                     double puntualidadMedia, int contratosFirmados) {
        int totalCerrados = completados + abandonados;

        if (user == null || totalCerrados < MINIMO_PARA_CALCULAR) {
            Resultado r = new Resultado(0, false);
            r.motivos.add("Todavía no tiene intercambios cerrados");
            return r;
        }

        double puntos = 0;

        // 1. Cumplimiento: que termine lo que empieza.
        double ratio = (double) completados / totalCerrados;
        puntos += ratio * P_CUMPLIMIENTO;

        // 2. Puntualidad declarada por sus compañeros.
        if (puntualidadMedia > 0) {
            puntos += (puntualidadMedia / 5.0) * P_PUNTUALIDAD;
        } else {
            // Sin datos no se premia ni se castiga: se da la mitad.
            puntos += P_PUNTUALIDAD / 2.0;
        }

        // 3. Compromiso: firmar el contrato antes de empezar.
        double compromiso = completados == 0
                ? 0 : Math.min(1.0, (double) contratosFirmados / completados);
        puntos += compromiso * P_COMPROMISO;

        // 4. Experiencia: se satura a los 10 intercambios.
        double experiencia = Math.min(1.0, completados / 10.0);
        puntos += experiencia * P_EXPERIENCIA;

        int total = (int) Math.round(Math.max(0, Math.min(100, puntos)));
        Resultado r = new Resultado(total, true);

        // Motivos legibles, en orden de importancia.
        // El singular y el plural se arman aqui porque este motor es Java puro:
        // no puede usar los <plurals> de Android sin arrastrar un Context.
        if (abandonados == 0 && completados > 0) {
            r.motivos.add(completados == 1
                    ? "Completó el único intercambio que empezó"
                    : "Completó los " + completados + " intercambios que empezó");
        } else {
            r.motivos.add(completados + " de " + totalCerrados + " intercambios completados");
        }
        if (puntualidadMedia > 0) {
            r.motivos.add(String.format(java.util.Locale.getDefault(),
                    "Puntualidad %.1f de 5", puntualidadMedia));
        }
        if (contratosFirmados > 0) {
            r.motivos.add(contratosFirmados == 1
                    ? "1 contrato de aprendizaje firmado"
                    : contratosFirmados + " contratos de aprendizaje firmados");
        }
        if (completados < 3) {
            r.motivos.add("Historial corto todavía");
        }
        return r;
    }

    /** Version corta cuando solo se tienen los contadores del perfil. */
    public static Resultado calcularRapido(User user) {
        if (user == null) return new Resultado(0, false);
        return calcular(user, user.getExchangesCount(), 0,
                user.getTotalRatings() > 0 ? user.getReputation() : 0,
                user.getExchangesCount());
    }
}
