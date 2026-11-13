package com.skillswap;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import com.skillswap.model.Exchange;
import com.skillswap.model.ExploreFilter;
import com.skillswap.model.MatchResult;
import com.skillswap.model.PassportEntry;
import com.skillswap.model.Rating;
import com.skillswap.model.Skill;
import com.skillswap.model.User;
import com.skillswap.model.UserSkill;
import com.skillswap.repository.MatchRepository;
import com.skillswap.repository.PassportRepository;
import com.skillswap.repository.UserRepository;
import com.skillswap.utils.Constants;
import com.skillswap.utils.DateUtils;
import com.skillswap.utils.SkillCatalog;
import com.skillswap.utils.Validators;

import org.junit.Test;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/** Lógica de negocio que no depende de Android ni de Firebase. */
public class CoreLogicTest {

    // ==================================================== SkillCatalog

    @Test
    public void catalogo_tieneLasSeisCategoriasDelEnunciado() {
        List<String> categorias = SkillCatalog.getCategories();
        assertEquals(6, categorias.size());
        assertTrue(categorias.contains(Constants.CAT_PROGRAMMING));
        assertTrue(categorias.contains(Constants.CAT_DESIGN));
        assertTrue(categorias.contains(Constants.CAT_LANGUAGES));
        assertTrue(categorias.contains(Constants.CAT_ACADEMIC));
        assertTrue(categorias.contains(Constants.CAT_MULTIMEDIA));
        assertTrue(categorias.contains(Constants.CAT_OTHERS));
    }

    @Test
    public void catalogo_contieneLasHabilidadesPedidas() {
        List<String> todas = SkillCatalog.getAllSkillNames();
        for (String esperada : new String[]{"Java", "Python", "JavaScript", "SQL", "HTML/CSS",
                "Photoshop", "Illustrator", "Figma", "Canva",
                "Inglés", "Portugués", "Francés",
                "Matemática", "Física", "Estadística",
                "Edición de video", "Fotografía", "Animación",
                "Excel", "Oratoria", "Marketing", "Música"}) {
            assertTrue("Falta la habilidad: " + esperada, todas.contains(esperada));
        }
        assertEquals(22, todas.size());
    }

    @Test
    public void catalogo_sinIdsDuplicados() {
        Set<String> ids = new HashSet<>();
        for (Skill s : SkillCatalog.getAllSkills()) {
            assertTrue("Id duplicado: " + s.getId(), ids.add(s.getId()));
            assertFalse(s.getCategory().isEmpty());
        }
    }

    @Test
    public void categoriaDeUnaHabilidad() {
        assertEquals(Constants.CAT_PROGRAMMING, SkillCatalog.categoryOf("Java"));
        assertEquals(Constants.CAT_DESIGN, SkillCatalog.categoryOf("Figma"));
        assertEquals(Constants.CAT_LANGUAGES, SkillCatalog.categoryOf("Inglés"));
        assertEquals("Mayúsculas/minúsculas no deben importar",
                Constants.CAT_PROGRAMMING, SkillCatalog.categoryOf("java"));
        assertEquals("Una habilidad libre cae en Otros",
                Constants.CAT_OTHERS, SkillCatalog.categoryOf("Malabarismo"));
    }

    @Test
    public void slug_quitaTildesYEspacios() {
        assertEquals("java", SkillCatalog.slug("Java"));
        assertEquals("ingles", SkillCatalog.slug("Inglés"));
        assertEquals("matematica", SkillCatalog.slug("Matemática"));
        assertEquals("edicion_de_video", SkillCatalog.slug("Edición de video"));
        assertEquals("html_css", SkillCatalog.slug("HTML/CSS"));
    }

    // ==================================================== UserSkill

    @Test
    public void nivelNumerico() {
        assertEquals(1, new UserSkill("x", "X", "C", Constants.LEVEL_BASIC,
                UserSkill.TYPE_TEACH).getLevelValue());
        assertEquals(2, new UserSkill("x", "X", "C", Constants.LEVEL_INTERMEDIATE,
                UserSkill.TYPE_TEACH).getLevelValue());
        assertEquals(3, new UserSkill("x", "X", "C", Constants.LEVEL_ADVANCED,
                UserSkill.TYPE_TEACH).getLevelValue());
    }

    @Test
    public void claveDeHabilidad_esCaseInsensitive() {
        UserSkill a = new UserSkill("java", "Java", "C", Constants.LEVEL_BASIC,
                UserSkill.TYPE_TEACH);
        UserSkill b = new UserSkill("java", "JAVA", "C", Constants.LEVEL_BASIC,
                UserSkill.TYPE_LEARN);
        assertEquals(a.getKey(), b.getKey());
        assertTrue(a.isTeach());
        assertFalse(b.isTeach());
    }

    // ==================================================== User

    @Test
    public void datosDerivadosDelUsuario() {
        User u = new User("uid", "César Andrés", "Ribo Castro", "c@test.com");
        assertEquals("César Andrés Ribo Castro", u.getFullName());
        assertEquals("Sólo el primer nombre", "César", u.getShortName());
        assertEquals("CR", u.getInitials());

        u.setCareer("Ingeniería de Sistemas");
        u.setCycle("Ciclo VI");
        assertEquals("Ingeniería de Sistemas · Ciclo VI", u.getAcademicLine());
    }

    @Test
    public void perfilCompleto_exigeTodosLosCampos() {
        User u = new User("uid", "Ana", "Pérez", "a@test.com");
        assertFalse(UserRepository.isProfileComplete(u));

        u.setUniversity("UNMSM");
        u.setCareer("Diseño");
        u.setModality(Constants.MODALITY_VIRTUAL);
        assertFalse("Sin habilidades no está completo", UserRepository.isProfileComplete(u));

        u.setTeachSkills(new ArrayList<>(Arrays.asList(
                new UserSkill("figma", "Figma", "Diseño",
                        Constants.LEVEL_ADVANCED, UserSkill.TYPE_TEACH))));
        u.setLearnSkills(new ArrayList<>(Arrays.asList(
                new UserSkill("java", "Java", "Programación",
                        Constants.LEVEL_BASIC, UserSkill.TYPE_LEARN))));

        // HU06: con todo lo demás pero SIN ciclo, el perfil sigue incompleto.
        assertFalse("Sin ciclo no está completo", UserRepository.isProfileComplete(u));

        u.setCycle("Ciclo VI");
        assertTrue(UserRepository.isProfileComplete(u));
    }

    // ==================================================== Exchange

    @Test
    public void intercambio_resuelveQuienEnsenaQue() {
        Exchange ex = new Exchange();
        ex.setUserAId("uid-a");
        ex.setUserAName("César");
        ex.setUserBId("uid-b");
        ex.setUserBName("Ana");
        ex.setSkillFromA("Java");    // A enseña Java
        ex.setSkillFromB("Figma");   // B enseña Figma

        assertEquals("Java", ex.getSkillITeach("uid-a"));
        assertEquals("Figma", ex.getSkillILearn("uid-a"));
        assertEquals("Ana", ex.getPartnerName("uid-a"));

        assertEquals("Figma", ex.getSkillITeach("uid-b"));
        assertEquals("Java", ex.getSkillILearn("uid-b"));
        assertEquals("César", ex.getPartnerName("uid-b"));
        assertEquals("uid-a", ex.getPartnerId("uid-b"));
    }

    @Test
    public void intercambio_confirmacionIndependientePorParticipante() {
        Exchange ex = new Exchange();
        ex.setUserAId("uid-a");
        ex.setUserBId("uid-b");

        ex.setCompletedByA(true);
        assertTrue(ex.hasCompleted("uid-a"));
        assertFalse("B aún no confirmó", ex.hasCompleted("uid-b"));

        ex.setRatedByB(true);
        assertTrue(ex.hasRated("uid-b"));
        assertFalse(ex.hasRated("uid-a"));
    }

    // ==================================================== Rating

    @Test
    public void calificacion_promediaLosCuatroCriterios() {
        Rating r = new Rating();
        r.setStars(5f);
        r.setPunctuality(4f);
        r.setCommunication(5f);
        r.setTeaching(4f);
        assertEquals(4.5f, r.getOverall(), 0.001f);
    }

    // ==================================================== Pasaporte

    @Test
    public void pasaporte_nivelSegunIntercambios() {
        assertEquals(Constants.LEVEL_BASIC, PassportRepository.levelFor(0));
        assertEquals(Constants.LEVEL_BASIC, PassportRepository.levelFor(1));
        assertEquals(Constants.LEVEL_INTERMEDIATE, PassportRepository.levelFor(2));
        assertEquals(Constants.LEVEL_INTERMEDIATE, PassportRepository.levelFor(4));
        assertEquals(Constants.LEVEL_ADVANCED, PassportRepository.levelFor(5));
        assertEquals(Constants.LEVEL_ADVANCED, PassportRepository.levelFor(50));
    }

    @Test
    public void pasaporte_progresoTopeEn100() {
        assertEquals(0, PassportRepository.progressFor(0));
        assertEquals(40, PassportRepository.progressFor(2));
        assertEquals(100, PassportRepository.progressFor(5));
        assertEquals("No debe pasar de 100", 100, PassportRepository.progressFor(30));
    }

    @Test
    public void pasaporte_idEsEstable() {
        String id = PassportRepository.entryId("uid", "Java", PassportEntry.ROLE_TAUGHT);
        assertEquals(id, PassportRepository.entryId("uid", "Java", PassportEntry.ROLE_TAUGHT));
        assertFalse(id.equals(
                PassportRepository.entryId("uid", "Java", PassportEntry.ROLE_LEARNED)));
    }

    // ==================================================== Match id

    @Test
    public void idDeMatch_esElMismoEnAmbosSentidos() {
        assertEquals(MatchRepository.buildMatchId("aaa", "bbb"),
                MatchRepository.buildMatchId("bbb", "aaa"));
    }

    // ==================================================== Filtros

    private MatchResult matchDe(User u, int score) {
        MatchResult m = new MatchResult();
        m.setUser(u);
        m.setScore(score);
        return m;
    }

    private User estudiante(String nombre, String uni, String skill, String nivel) {
        User u = new User("uid-" + nombre, nombre, "Test", nombre + "@t.com");
        u.setUniversity(uni);
        u.setCareer("Ingeniería");
        u.setModality(Constants.MODALITY_VIRTUAL);
        u.setTeachSkills(new ArrayList<>(Arrays.asList(
                new UserSkill(SkillCatalog.slug(skill), skill,
                        SkillCatalog.categoryOf(skill), nivel, UserSkill.TYPE_TEACH))));
        return u;
    }

    @Test
    public void filtro_porHabilidad() {
        List<MatchResult> data = Arrays.asList(
                matchDe(estudiante("Ana", "UNMSM", "Figma", Constants.LEVEL_ADVANCED), 90),
                matchDe(estudiante("Luis", "PUCP", "Java", Constants.LEVEL_BASIC), 70));

        ExploreFilter f = new ExploreFilter();
        f.setSkill("Java");
        List<MatchResult> out = MatchRepository.applyFilters(data, f);

        assertEquals(1, out.size());
        assertEquals("Luis", out.get(0).getUser().getFirstName());
    }

    @Test
    public void filtro_porCompatibilidadMinima() {
        List<MatchResult> data = Arrays.asList(
                matchDe(estudiante("Ana", "UNMSM", "Figma", Constants.LEVEL_ADVANCED), 90),
                matchDe(estudiante("Luis", "PUCP", "Java", Constants.LEVEL_BASIC), 45));

        ExploreFilter f = new ExploreFilter();
        f.setMinCompatibility(80);
        assertEquals(1, MatchRepository.applyFilters(data, f).size());
    }

    @Test
    public void filtro_busquedaPorTextoLibre() {
        List<MatchResult> data = Arrays.asList(
                matchDe(estudiante("Ana", "UNMSM", "Figma", Constants.LEVEL_ADVANCED), 90),
                matchDe(estudiante("Luis", "PUCP", "Java", Constants.LEVEL_BASIC), 70));

        ExploreFilter f = new ExploreFilter();
        f.setQuery("figma");
        assertEquals(1, MatchRepository.applyFilters(data, f).size());

        f.setQuery("pucp");
        assertEquals(1, MatchRepository.applyFilters(data, f).size());

        f.setQuery("nadaquever");
        assertEquals(0, MatchRepository.applyFilters(data, f).size());
    }

    @Test
    public void filtro_contadorYLimpieza() {
        ExploreFilter f = new ExploreFilter();
        assertTrue(f.isEmpty());

        f.setCategory(Constants.CAT_DESIGN);
        f.setLevel(Constants.LEVEL_ADVANCED);
        f.setMinCompatibility(60);
        assertEquals(3, f.activeCount());
        assertFalse(f.isEmpty());

        f.clearFilters();
        assertEquals(0, f.activeCount());
    }

    // ==================================================== Validators

    @Test
    public void validarNombre() {
        assertNull(Validators.validateName("César"));
        assertNull(Validators.validateName("María José"));
        assertNotNull("Vacío no vale", Validators.validateName(""));
        assertNotNull("Una letra no vale", Validators.validateName("C"));
        assertNotNull("Con números no vale", Validators.validateName("Cesar123"));
    }

    @Test
    public void validarPassword_exigeLetrasYNumeros() {
        assertNull(Validators.validatePassword("prueba123"));
        assertNotNull("Muy corta", Validators.validatePassword("ab1"));
        assertNotNull("Sólo letras", Validators.validatePassword("solamente"));
        assertNotNull("Sólo números", Validators.validatePassword("12345678"));
        assertNotNull("Vacía", Validators.validatePassword(""));
    }

    @Test
    public void validarConfirmacionDePassword() {
        assertNull(Validators.validateConfirmPassword("prueba123", "prueba123"));
        assertNotNull(Validators.validateConfirmPassword("prueba123", "otra456"));
        assertNotNull(Validators.validateConfirmPassword("prueba123", ""));
    }

    @Test
    public void validarRangoNumerico() {
        assertNull(Validators.validateIntRange("3", 1, 20, "Sesiones"));
        assertNotNull(Validators.validateIntRange("0", 1, 20, "Sesiones"));
        assertNotNull(Validators.validateIntRange("21", 1, 20, "Sesiones"));
        assertNotNull(Validators.validateIntRange("abc", 1, 20, "Sesiones"));
        assertNotNull(Validators.validateIntRange("", 1, 20, "Sesiones"));
    }

    @Test
    public void validarLongitudMinima() {
        assertNull(Validators.validateMinLength("Universidad Nacional", 3, "La universidad"));
        assertNotNull(Validators.validateMinLength("ab", 3, "La universidad"));
        assertTrue(Validators.isEmpty("   "));
        assertTrue(Validators.isEmpty(null));
    }

    // ==================================================== DateUtils

    @Test
    public void tiempoRelativo() {
        long ahora = System.currentTimeMillis();
        assertEquals("ahora", DateUtils.timeAgo(ahora));
        assertTrue(DateUtils.timeAgo(ahora - 5 * 60_000L).startsWith("hace 5 min"));
        assertTrue(DateUtils.timeAgo(ahora - 2 * 3_600_000L).contains("2 horas"));
        assertTrue(DateUtils.timeAgo(ahora - 3 * 86_400_000L).contains("3 días"));
        assertEquals("", DateUtils.timeAgo(0));
    }

    @Test
    public void esHoyYEsAyer() {
        long ahora = System.currentTimeMillis();
        assertTrue(DateUtils.isToday(ahora));
        assertFalse(DateUtils.isToday(ahora - 2 * 86_400_000L));
        assertTrue(DateUtils.sameDay(ahora, ahora + 1000));
    }

    @Test
    public void diasRestantesDeUnReto() {
        assertEquals("Finalizado", DateUtils.daysLeft(System.currentTimeMillis() - 1000));
        String enTresDias = DateUtils.daysLeft(DateUtils.plusDays(3));
        assertTrue(enTresDias, enTresDias.contains("día"));
    }

    @Test
    public void sumarDias_devuelveFuturo() {
        assertTrue(DateUtils.plusDays(7) > System.currentTimeMillis());
    }
}
