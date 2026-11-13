package com.skillswap.local;

import android.content.Context;

import androidx.room.Database;
import androidx.room.Room;
import androidx.room.RoomDatabase;

import com.skillswap.local.CacheEntities.CoincidenciaCache;
import com.skillswap.local.CacheEntities.HabilidadCache;
import com.skillswap.local.CacheEntities.PerfilCache;

/**
 * RC1 - Base de datos local SQLite gestionada con Room.
 *
 * Es solo cache: si el esquema cambia se descarta y se vuelve a llenar desde
 * Firestore, por eso se usa fallbackToDestructiveMigration() en lugar de
 * escribir migraciones. Perder esta base no pierde informacion del usuario.
 */
@Database(
        entities = {PerfilCache.class, HabilidadCache.class, CoincidenciaCache.class},
        version = 1,
        exportSchema = false)
public abstract class SkillSwapDatabase extends RoomDatabase {

    private static volatile SkillSwapDatabase instancia;

    public abstract CacheDao cacheDao();

    public static SkillSwapDatabase get(Context context) {
        if (instancia == null) {
            synchronized (SkillSwapDatabase.class) {
                if (instancia == null) {
                    instancia = Room.databaseBuilder(
                                    context.getApplicationContext(),
                                    SkillSwapDatabase.class,
                                    "skillswap_cache.db")
                            .fallbackToDestructiveMigration()
                            .build();
                }
            }
        }
        return instancia;
    }
}
