package com.skillswap.local;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import com.skillswap.local.CacheEntities.CoincidenciaCache;
import com.skillswap.local.CacheEntities.HabilidadCache;
import com.skillswap.local.CacheEntities.PerfilCache;
import com.skillswap.model.MatchResult;
import com.skillswap.model.User;
import com.skillswap.model.UserSkill;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * RC1 - Fachada de la cache local.
 *
 * Aisla al resto de la app de Room: nadie fuera de este paquete necesita saber
 * que por debajo hay SQLite. Todas las operaciones salen del hilo principal
 * con un executor propio, y los resultados vuelven al hilo de la interfaz.
 *
 * El flujo de lectura que describe el informe es: primero se muestra lo que
 * hay guardado y, si hay conexion, se actualiza desde Firestore y se vuelve
 * a guardar aqui.
 */
public final class LocalCache {

    public interface Callback<T> {
        void onResult(T data);
    }

    private static final ExecutorService IO = Executors.newSingleThreadExecutor();
    private static final Handler MAIN = new Handler(Looper.getMainLooper());

    private LocalCache() {
    }

    private static CacheDao dao(Context context) {
        return SkillSwapDatabase.get(context).cacheDao();
    }

    // ------------------------------------------------------------- perfil

    /** Guarda el perfil y sus habilidades tras leerlos de Firestore. */
    public static void guardarPerfil(final Context context, final User user) {
        if (context == null || user == null || user.getUid() == null) return;
        final Context app = context.getApplicationContext();

        IO.execute(() -> {
            try {
                PerfilCache p = new PerfilCache(user.getUid(), user.getFullName(),
                        user.getUniversity(), user.getCareer(), user.getCycle(),
                        user.getPhotoUrl());
                dao(app).guardarPerfil(p);

                List<HabilidadCache> habilidades = new ArrayList<>();
                agregar(habilidades, user.getUid(), user.getTeachSkills(), "TEACH");
                agregar(habilidades, user.getUid(), user.getLearnSkills(), "LEARN");

                dao(app).borrarHabilidadesDe(user.getUid());
                if (!habilidades.isEmpty()) {
                    dao(app).guardarHabilidades(habilidades);
                }
            } catch (Exception e) {
                // La cache nunca debe tumbar la app.
            }
        });
    }

    private static void agregar(List<HabilidadCache> destino, String uid,
                                List<UserSkill> skills, String tipo) {
        if (skills == null) return;
        for (UserSkill s : skills) {
            if (s == null || s.getName() == null) continue;
            destino.add(new HabilidadCache(uid, s.getName(), s.getCategory(),
                    s.getLevel(), tipo));
        }
    }

    /** Devuelve el perfil guardado, o null si todavia no hay nada. */
    public static void leerPerfil(final Context context, final String uid,
                                  final Callback<PerfilCache> callback) {
        final Context app = context.getApplicationContext();
        IO.execute(() -> {
            PerfilCache p = null;
            try {
                p = dao(app).perfilDe(uid);
            } catch (Exception ignored) {
            }
            final PerfilCache resultado = p;
            MAIN.post(() -> callback.onResult(resultado));
        });
    }

    public static void leerHabilidades(final Context context, final String uid,
                                       final Callback<List<HabilidadCache>> callback) {
        final Context app = context.getApplicationContext();
        IO.execute(() -> {
            List<HabilidadCache> lista = new ArrayList<>();
            try {
                List<HabilidadCache> r = dao(app).habilidadesDe(uid);
                if (r != null) lista.addAll(r);
            } catch (Exception ignored) {
            }
            MAIN.post(() -> callback.onResult(lista));
        });
    }

    // ------------------------------------------------------ coincidencias

    /** Guarda las ultimas coincidencias mostradas en Explorar. */
    public static void guardarCoincidencias(final Context context,
                                            final List<MatchResult> matches) {
        if (context == null || matches == null) return;
        final Context app = context.getApplicationContext();
        final List<MatchResult> copia = new ArrayList<>(matches);

        IO.execute(() -> {
            try {
                List<CoincidenciaCache> filas = new ArrayList<>();
                for (MatchResult m : copia) {
                    User u = m.getUser();
                    if (u == null || u.getUid() == null) continue;
                    filas.add(new CoincidenciaCache(u.getUid(), u.getFullName(),
                            u.getCareer(), u.getPhotoUrl(),
                            primeraHabilidad(u), m.getScore()));
                }
                dao(app).borrarCoincidencias();
                if (!filas.isEmpty()) dao(app).guardarCoincidencias(filas);
            } catch (Exception ignored) {
            }
        });
    }

    private static String primeraHabilidad(User u) {
        if (u.getTeachSkills() == null || u.getTeachSkills().isEmpty()) return "";
        UserSkill s = u.getTeachSkills().get(0);
        return s == null || s.getName() == null ? "" : s.getName();
    }

    public static void leerCoincidencias(final Context context,
                                         final Callback<List<CoincidenciaCache>> callback) {
        final Context app = context.getApplicationContext();
        IO.execute(() -> {
            List<CoincidenciaCache> lista = new ArrayList<>();
            try {
                List<CoincidenciaCache> r = dao(app).coincidencias();
                if (r != null) lista.addAll(r);
            } catch (Exception ignored) {
            }
            MAIN.post(() -> callback.onResult(lista));
        });
    }

    // ---------------------------------------------------------- limpieza

    /** Al cerrar sesion no debe quedar rastro del usuario en el telefono. */
    public static void limpiar(final Context context) {
        if (context == null) return;
        final Context app = context.getApplicationContext();
        IO.execute(() -> {
            try {
                dao(app).borrarPerfiles();
                dao(app).borrarCoincidencias();
            } catch (Exception ignored) {
            }
        });
    }
}
