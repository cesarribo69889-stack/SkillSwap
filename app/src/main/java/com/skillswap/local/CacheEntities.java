package com.skillswap.local;

import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.Ignore;
import androidx.room.PrimaryKey;

/**
 * RC1 - Tablas locales en SQLite (Room).
 *
 * Firebase sigue siendo la informacion oficial; esto es solo una copia en el
 * telefono para que la app se pueda abrir sin conexion. Por eso ninguna
 * entidad guarda datos sensibles ni se usa como fuente de verdad.
 *
 * Las tres tablas son las de la Tabla 8 del informe.
 */
public final class CacheEntities {

    private CacheEntities() {
    }

    /** Datos del perfil del usuario que inicio sesion. */
    @Entity(tableName = "perfil_cache")
    public static class PerfilCache {

        @PrimaryKey
        @NonNull
        public String uid = "";

        public String nombre = "";
        public String universidad = "";
        public String carrera = "";
        public String ciclo = "";
        public String foto = "";
        public String pais = "";
        public String idioma = "";
        public long actualizado = 0L;

        public PerfilCache() {
        }

        @Ignore
        public PerfilCache(@NonNull String uid, String nombre, String universidad,
                           String carrera, String ciclo, String foto) {
            this.uid = uid;
            this.nombre = nombre;
            this.universidad = universidad;
            this.carrera = carrera;
            this.ciclo = ciclo;
            this.foto = foto;
            this.actualizado = System.currentTimeMillis();
        }
    }

    /** Habilidades que el usuario ensena o quiere aprender. */
    @Entity(tableName = "habilidad_cache")
    public static class HabilidadCache {

        /** uid + "__" + nombre + "__" + tipo, para no duplicar. */
        @PrimaryKey
        @NonNull
        public String id = "";

        public String uid = "";
        public String nombre = "";
        public String categoria = "";
        public String nivel = "";
        /** TEACH o LEARN. */
        public String tipo = "";
        public long actualizado = 0L;

        public HabilidadCache() {
        }

        @Ignore
        public HabilidadCache(String uid, String nombre, String categoria,
                              String nivel, String tipo) {
            this.uid = uid;
            this.nombre = nombre;
            this.categoria = categoria;
            this.nivel = nivel;
            this.tipo = tipo;
            this.id = uid + "__" + nombre + "__" + tipo;
            this.actualizado = System.currentTimeMillis();
        }
    }

    /** Ultimos estudiantes sugeridos por el SkillMatch. */
    @Entity(tableName = "coincidencia_cache")
    public static class CoincidenciaCache {

        @PrimaryKey
        @NonNull
        public String uid = "";

        public String nombre = "";
        public String carrera = "";
        public String foto = "";
        public String ensena = "";
        public int puntaje = 0;
        public long actualizado = 0L;

        public CoincidenciaCache() {
        }

        @Ignore
        public CoincidenciaCache(@NonNull String uid, String nombre, String carrera,
                                 String foto, String ensena, int puntaje) {
            this.uid = uid;
            this.nombre = nombre;
            this.carrera = carrera;
            this.foto = foto;
            this.ensena = ensena;
            this.puntaje = puntaje;
            this.actualizado = System.currentTimeMillis();
        }
    }
}
