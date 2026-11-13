package com.skillswap.local;

import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;

import com.skillswap.local.CacheEntities.CoincidenciaCache;
import com.skillswap.local.CacheEntities.HabilidadCache;
import com.skillswap.local.CacheEntities.PerfilCache;

import java.util.List;

/**
 * RC1 - Acceso a las tablas locales.
 *
 * Todos los metodos son sincronos a proposito: quien llama ya esta en un hilo
 * de fondo (ver {@link LocalCache}). Room lanzaria una excepcion si alguno se
 * ejecutara en el hilo principal, lo que sirve de red de seguridad.
 */
@Dao
public interface CacheDao {

    // ----------------------------------------------------------- perfil
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void guardarPerfil(PerfilCache perfil);

    @Query("SELECT * FROM perfil_cache WHERE uid = :uid LIMIT 1")
    PerfilCache perfilDe(String uid);

    // ------------------------------------------------------- habilidades
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void guardarHabilidades(List<HabilidadCache> habilidades);

    @Query("SELECT * FROM habilidad_cache WHERE uid = :uid ORDER BY tipo, nombre")
    List<HabilidadCache> habilidadesDe(String uid);

    @Query("DELETE FROM habilidad_cache WHERE uid = :uid")
    void borrarHabilidadesDe(String uid);

    // ------------------------------------------------------ coincidencias
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void guardarCoincidencias(List<CoincidenciaCache> coincidencias);

    @Query("SELECT * FROM coincidencia_cache ORDER BY puntaje DESC")
    List<CoincidenciaCache> coincidencias();

    @Query("DELETE FROM coincidencia_cache")
    void borrarCoincidencias();

    // --------------------------------------------------------- limpieza
    /** Al cerrar sesion no debe quedar nada del usuario en el telefono. */
    @Query("DELETE FROM perfil_cache")
    void borrarPerfiles();
}
