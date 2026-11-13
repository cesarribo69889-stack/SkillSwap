package com.skillswap;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import com.skillswap.model.MatchReason;
import com.skillswap.model.MatchResult;
import com.skillswap.model.User;
import com.skillswap.model.UserSkill;
import com.skillswap.utils.Constants;
import com.skillswap.utils.SkillMatchEngine;

import org.junit.Test;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Verifica que el porcentaje de SkillMatch se calcule con reglas reales
 * y no de forma aleatoria.
 */
public class SkillMatchEngineTest {

    // ------------------------------------------------------------- helpers

    private UserSkill skill(String name, String level, String type) {
        return new UserSkill(name.toLowerCase(), name, "Programación", level, type);
    }

    private User user(String uid, String firstName) {
        User u = new User();
        u.setUid(uid);
        u.setFirstName(firstName);
        u.setLastName("Apellido");
        u.setProfileCompleted(true);   // HU06: rank() descarta los incompletos
        u.setModality(Constants.MODALITY_VIRTUAL);
        u.setAvailability(new ArrayList<>(Arrays.asList(
                "Lunes a Viernes - Noche", "Sábados - Mañana")));
        return u;
    }

    /** César: enseña Java (Avanzado), quiere aprender Diseño. */
    private User cesar() {
        User u = user("uid-cesar", "César");
        u.setTeachSkills(new ArrayList<>(Arrays.asList(
                skill("Java", Constants.LEVEL_ADVANCED, UserSkill.TYPE_TEACH))));
        u.setLearnSkills(new ArrayList<>(Arrays.asList(
                skill("Figma", Constants.LEVEL_BASIC, UserSkill.TYPE_LEARN))));
        return u;
    }

    /** Ana: enseña Diseño (Avanzado), quiere aprender Java. Reputación 5.0 */
    private User ana() {
        User u = user("uid-ana", "Ana");
        u.setTeachSkills(new ArrayList<>(Arrays.asList(
                skill("Figma", Constants.LEVEL_ADVANCED, UserSkill.TYPE_TEACH))));
        u.setLearnSkills(new ArrayList<>(Arrays.asList(
                skill("Java", Constants.LEVEL_BASIC, UserSkill.TYPE_LEARN))));
        u.setReputation(5.0);
        u.setTotalRatings(8);
        return u;
    }

    // --------------------------------------------------------------- tests

    /** El caso del enunciado: intercambio recíproco perfecto. */
    @Test
    public void matchReciprocoPerfecto_daPorcentajeAlto() {
        MatchResult r = SkillMatchEngine.calculate(cesar(), ana());

        assertTrue("Se esperaba >= 90 %, se obtuvo " + r.getScore(), r.getScore() >= 90);
        assertTrue("Debe marcarse como mutuo", r.isMutual());
        assertEquals(1, r.getTheyTeachYouWant().size());
        assertEquals("Figma", r.getTheyTeachYouWant().get(0));
        assertEquals(1, r.getYouTeachTheyWant().size());
        assertEquals("Java", r.getYouTeachTheyWant().get(0));
    }

    /** Sin habilidades complementarias el resultado debe ser 0, no un azar. */
    @Test
    public void sinHabilidadesComplementarias_daCero() {
        User otro = user("uid-otro", "Luis");
        otro.setTeachSkills(new ArrayList<>(Arrays.asList(
                skill("Excel", Constants.LEVEL_ADVANCED, UserSkill.TYPE_TEACH))));
        otro.setLearnSkills(new ArrayList<>(Arrays.asList(
                skill("Oratoria", Constants.LEVEL_BASIC, UserSkill.TYPE_LEARN))));

        MatchResult r = SkillMatchEngine.calculate(cesar(), otro);
        assertEquals(0, r.getScore());
        assertFalse(r.isMutual());
    }

    /** El algoritmo es determinista: mismas entradas, mismo resultado. */
    @Test
    public void esDeterminista_noUsaAzar() {
        int first = SkillMatchEngine.calculate(cesar(), ana()).getScore();
        for (int i = 0; i < 25; i++) {
            assertEquals(first, SkillMatchEngine.calculate(cesar(), ana()).getScore());
        }
    }

    /** Un match de una sola dirección puntúa menos que uno recíproco. */
    @Test
    public void matchUnidireccional_puntuaMenosQueReciproco() {
        User soloEnsena = user("uid-solo", "Marta");
        soloEnsena.setTeachSkills(new ArrayList<>(Arrays.asList(
                skill("Figma", Constants.LEVEL_ADVANCED, UserSkill.TYPE_TEACH))));
        soloEnsena.setLearnSkills(new ArrayList<UserSkill>());
        soloEnsena.setReputation(5.0);
        soloEnsena.setTotalRatings(8);

        int unidireccional = SkillMatchEngine.calculate(cesar(), soloEnsena).getScore();
        int reciproco = SkillMatchEngine.calculate(cesar(), ana()).getScore();

        assertTrue(unidireccional > 0);
        assertTrue("El recíproco debe puntuar más", reciproco > unidireccional);
    }

    /** Un profesor avanzado debe puntuar más que uno básico. */
    @Test
    public void nivelAvanzado_puntuaMasQueBasico() {
        User avanzada = ana();

        User basica = ana();
        basica.setTeachSkills(new ArrayList<>(Arrays.asList(
                skill("Figma", Constants.LEVEL_BASIC, UserSkill.TYPE_TEACH))));

        int conAvanzado = SkillMatchEngine.calculate(cesar(), avanzada).getScore();
        int conBasico = SkillMatchEngine.calculate(cesar(), basica).getScore();

        assertTrue("Avanzado (" + conAvanzado + ") debe superar a básico (" + conBasico + ")",
                conAvanzado > conBasico);
    }

    /** Modalidades incompatibles deben restar puntos. */
    @Test
    public void modalidadIncompatible_restaPuntos() {
        User presencial = ana();
        presencial.setModality(Constants.MODALITY_PRESENCIAL);

        User yoVirtual = cesar();
        yoVirtual.setModality(Constants.MODALITY_VIRTUAL);

        int compatible = SkillMatchEngine.calculate(yoVirtual, ana()).getScore();
        int incompatible = SkillMatchEngine.calculate(yoVirtual, presencial).getScore();

        assertTrue("Incompatible debe puntuar menos", incompatible < compatible);
    }

    /** Sin horarios en común se pierde el peso de disponibilidad. */
    @Test
    public void sinHorariosEnComun_restaPuntos() {
        User otraAgenda = ana();
        otraAgenda.setAvailability(new ArrayList<>(Arrays.asList("Domingos - Tarde")));

        int conHorarios = SkillMatchEngine.calculate(cesar(), ana()).getScore();
        int sinHorarios = SkillMatchEngine.calculate(cesar(), otraAgenda).getScore();

        assertTrue("Sin horarios comunes debe puntuar menos", sinHorarios < conHorarios);
    }

    /** El match debe explicarse con razones legibles. */
    @Test
    public void generaExplicacionDelMatch() {
        MatchResult r = SkillMatchEngine.calculate(cesar(), ana());
        List<MatchReason> razones = r.getReasons();

        assertTrue("Debe haber varias razones", razones.size() >= 4);

        boolean anaEnsena = false;
        boolean tuEnsenas = false;
        for (MatchReason reason : razones) {
            if (reason.getText().contains("Ana enseña Figma")) anaEnsena = true;
            if (reason.getText().contains("Tú enseñas Java")) tuEnsenas = true;
        }
        assertTrue("Falta la razón 'Ana enseña Figma'", anaEnsena);
        assertTrue("Falta la razón 'Tú enseñas Java'", tuEnsenas);
    }

    /** El ranking ordena de mayor a menor compatibilidad y excluye los ceros. */
    @Test
    public void rank_ordenaYDescartaSinMatch() {
        User sinMatch = user("uid-nada", "Luis");
        sinMatch.setTeachSkills(new ArrayList<>(Arrays.asList(
                skill("Excel", Constants.LEVEL_ADVANCED, UserSkill.TYPE_TEACH))));

        User parcial = user("uid-parcial", "Marta");
        parcial.setTeachSkills(new ArrayList<>(Arrays.asList(
                skill("Figma", Constants.LEVEL_BASIC, UserSkill.TYPE_TEACH))));

        List<MatchResult> ranking = SkillMatchEngine.rank(cesar(),
                Arrays.asList(sinMatch, parcial, ana()));

        assertEquals("Los que dan 0 deben descartarse", 2, ranking.size());
        assertEquals("uid-ana", ranking.get(0).getUser().getUid());
        assertTrue(ranking.get(0).getScore() >= ranking.get(1).getScore());
    }

    /**
     * HU06: un perfil incompleto no debe aparecer en los resultados, aunque
     * sus habilidades sean perfectamente complementarias.
     */
    @Test
    public void perfilIncompletoNoApareceEnLosResultados() {
        User incompleto = ana();
        incompleto.setProfileCompleted(false);

        List<MatchResult> ranking = SkillMatchEngine.rank(cesar(), Arrays.asList(incompleto));

        assertEquals("Un perfil incompleto se descarta aunque encaje al 90 % o mas",
                0, ranking.size());
    }

    @Test
    public void perfilCompletoSiApareceEnLosResultados() {
        List<MatchResult> ranking = SkillMatchEngine.rank(cesar(), Arrays.asList(ana()));

        assertEquals(1, ranking.size());
    }

    /** Nunca debe salirse del rango 0-100. */
    @Test
    public void scoreSiempreEntre0y100() {
        MatchResult r = SkillMatchEngine.calculate(cesar(), ana());
        assertTrue(r.getScore() >= 0 && r.getScore() <= 100);
    }
}
