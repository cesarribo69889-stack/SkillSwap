package com.skillswap.webservice;

import com.google.gson.annotations.SerializedName;

import java.util.List;

import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.Query;

/**
 * RC2 - Servicio REST (JSON).
 *
 * API publica de universidades (Hipolabs). Se usa para sugerir el nombre de
 * la universidad mientras el estudiante completa su perfil (HU06), de modo
 * que no tenga que escribirlo entero ni se llene la base de variantes del
 * mismo nombre.
 *
 * Ejemplo de peticion:
 *   GET http://universities.hipolabs.com/search?country=Peru&name=norte
 */
public interface UniversityApi {

    @GET("search")
    Call<List<UniversidadDto>> buscar(@Query("country") String pais,
                                      @Query("name") String nombre);

    /** Lo que devuelve el servicio; solo se leen los campos que se usan. */
    class UniversidadDto {

        @SerializedName("name")
        public String nombre;

        @SerializedName("country")
        public String pais;

        @SerializedName("alpha_two_code")
        public String codigoPais;

        @SerializedName("domains")
        public List<String> dominios;

        @Override
        public String toString() {
            return nombre == null ? "" : nombre;
        }
    }
}
