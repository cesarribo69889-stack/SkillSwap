package com.skillswap;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import com.skillswap.model.MatchResult;
import com.skillswap.model.User;
import com.skillswap.repository.SafetyRepository;

import org.junit.Test;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;

/** Reportar y bloquear: la parte que no depende de Firebase. */
public class SafetyRepositoryTest {

    private static MatchResult resultado(String uid) {
        User u = new User();
        u.setUid(uid);
        MatchResult m = new MatchResult();
        m.setUser(u);
        return m;
    }

    @Test
    public void sinBloqueados_quitaALosBloqueados() {
        List<MatchResult> todos = Arrays.asList(resultado("a"), resultado("b"), resultado("c"));
        List<MatchResult> visibles = SafetyRepository.sinBloqueados(todos,
                new HashSet<>(Arrays.asList("b")));
        assertEquals(2, visibles.size());
        assertEquals("a", visibles.get(0).getUser().getUid());
        assertEquals("c", visibles.get(1).getUser().getUid());
    }

    @Test
    public void sinBloqueados_sinBloqueosDevuelveTodo() {
        List<MatchResult> todos = Arrays.asList(resultado("a"), resultado("b"));
        assertEquals(2, SafetyRepository.sinBloqueados(todos, new HashSet<String>()).size());
        assertEquals(2, SafetyRepository.sinBloqueados(todos, null).size());
    }

    @Test
    public void sinBloqueados_listaNulaDevuelveListaVacia() {
        assertTrue(SafetyRepository.sinBloqueados(null, new HashSet<>(Arrays.asList("a")))
                .isEmpty());
    }

    @Test
    public void sinBloqueados_noModificaLaListaOriginal() {
        List<MatchResult> todos = new ArrayList<>(Arrays.asList(resultado("a"), resultado("b")));
        SafetyRepository.sinBloqueados(todos, new HashSet<>(Arrays.asList("a")));
        assertEquals(2, todos.size());
    }

    @Test
    public void idDeBloqueo_unePorBloqueadorYBloqueado() {
        assertEquals("yo__otro", SafetyRepository.idDeBloqueo("yo", "otro"));
    }

    @Test
    public void motivosDeReporte_noEstanVacios() {
        assertTrue(SafetyRepository.MOTIVOS.length >= 3);
        for (String motivo : SafetyRepository.MOTIVOS) {
            assertTrue(motivo != null && !motivo.trim().isEmpty());
        }
    }
}
