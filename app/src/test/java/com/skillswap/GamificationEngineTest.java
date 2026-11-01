package com.skillswap;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import com.skillswap.model.Badge;
import com.skillswap.model.SkillPointsAccount;
import com.skillswap.utils.Constants;
import com.skillswap.utils.GamificationEngine;

import org.junit.Test;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * INNOVACION 4 - SkillPoints.
 * Verifica niveles, umbrales, progreso e insignias.
 */
public class GamificationEngineTest {

    // ------------------------------------------------------------- niveles

    @Test
    public void nivelesSegunUmbrales() {
        assertEquals(GamificationEngine.LEVEL_BEGINNER, GamificationEngine.levelNameFor(0));
        assertEquals(GamificationEngine.LEVEL_BEGINNER, GamificationEngine.levelNameFor(99));
        assertEquals(GamificationEngine.LEVEL_COLLABORATOR, GamificationEngine.levelNameFor(100));
        assertEquals(GamificationEngine.LEVEL_COLLABORATOR, GamificationEngine.levelNameFor(299));
        assertEquals(GamificationEngine.LEVEL_MENTOR, GamificationEngine.levelNameFor(300));
        assertEquals(GamificationEngine.LEVEL_MENTOR, GamificationEngine.levelNameFor(699));
        assertEquals(GamificationEngine.LEVEL_MASTER, GamificationEngine.levelNameFor(700));
        assertEquals(GamificationEngine.LEVEL_MASTER, GamificationEngine.levelNameFor(99999));
    }

    @Test
    public void indiceDeNivelEsCoherente() {
        assertEquals(0, GamificationEngine.levelIndexFor(50));
        assertEquals(1, GamificationEngine.levelIndexFor(150));
        assertEquals(2, GamificationEngine.levelIndexFor(400));
        assertEquals(3, GamificationEngine.levelIndexFor(1000));
    }

    @Test
    public void siguienteUmbral_esCeroEnElMaximo() {
        assertEquals(100, GamificationEngine.nextLevelThreshold(0));
        assertEquals(300, GamificationEngine.nextLevelThreshold(100));
        assertEquals(700, GamificationEngine.nextLevelThreshold(300));
        assertEquals("En SkillMaster ya no hay siguiente nivel",
                0, GamificationEngine.nextLevelThreshold(800));
    }

    // ------------------------------------------------------------ progreso

    @Test
    public void progresoDentroDelNivel() {
        assertEquals(0, GamificationEngine.levelProgress(0));
        assertEquals(50, GamificationEngine.levelProgress(50));
        assertEquals(0, GamificationEngine.levelProgress(100));
        assertEquals(50, GamificationEngine.levelProgress(200));
        assertEquals(100, GamificationEngine.levelProgress(1000));
    }

    @Test
    public void progresoSiempreEntre0y100() {
        for (int p = 0; p <= 1200; p += 7) {
            int progress = GamificationEngine.levelProgress(p);
            assertTrue("Progreso fuera de rango en " + p, progress >= 0 && progress <= 100);
        }
    }

    // --------------------------------------------------------- aplicar pts

    @Test
    public void sumarPuntos_actualizaNivelYUmbral() {
        SkillPointsAccount acc = new SkillPointsAccount("uid");

        acc = GamificationEngine.applyPoints(acc, Constants.POINTS_EXCHANGE_COMPLETED);
        assertEquals(20, acc.getPoints());
        assertEquals(GamificationEngine.LEVEL_BEGINNER, acc.getLevel());

        // 4 intercambios más (80 pts) -> 100 -> Colaborador
        for (int i = 0; i < 4; i++) {
            acc = GamificationEngine.applyPoints(acc, Constants.POINTS_EXCHANGE_COMPLETED);
        }
        assertEquals(100, acc.getPoints());
        assertEquals(GamificationEngine.LEVEL_COLLABORATOR, acc.getLevel());
        assertEquals(1, acc.getLevelIndex());
        assertEquals(300, acc.getPointsForNextLevel());
    }

    @Test
    public void puntosNuncaBajanDeCero() {
        SkillPointsAccount acc = new SkillPointsAccount("uid");
        acc = GamificationEngine.applyPoints(acc, 10);
        acc = GamificationEngine.applyPoints(acc, -50);
        assertEquals(0, acc.getPoints());
        assertEquals(GamificationEngine.LEVEL_BEGINNER, acc.getLevel());
    }

    @Test
    public void aceptaCuentaNula() {
        SkillPointsAccount acc = GamificationEngine.applyPoints(null, 25);
        assertNotNull(acc);
        assertEquals(25, acc.getPoints());
    }

    /** Los valores de la tabla del enunciado. */
    @Test
    public void tablaDePuntosDelEnunciado() {
        assertEquals(20, Constants.POINTS_EXCHANGE_COMPLETED);
        assertEquals(5, Constants.POINTS_GOOD_RATING);
    }

    // ------------------------------------------------------------ badges

    @Test
    public void catalogoDeInsignias_sinCodigosDuplicados() {
        List<Badge> badges = GamificationEngine.catalog();
        assertEquals(8, badges.size());

        Set<String> codes = new HashSet<>();
        for (Badge b : badges) {
            assertTrue("Código duplicado: " + b.getCode(), codes.add(b.getCode()));
            assertFalse("Insignia sin nombre", b.getName().isEmpty());
            assertFalse("Insignia sin descripción", b.getDescription().isEmpty());
            assertFalse("Las insignias del catálogo nacen bloqueadas", b.isUnlocked());
        }
    }

    @Test
    public void buscarInsignia_porCodigo() {
        Badge b = GamificationEngine.findInCatalog(GamificationEngine.BADGE_FIRST_SWAP);
        assertNotNull(b);
        assertEquals("Primer intercambio", b.getName());
        assertNull(GamificationEngine.findInCatalog("CODIGO_QUE_NO_EXISTE"));
    }
}
