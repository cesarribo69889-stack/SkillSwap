package com.skillswap.utils;

import com.skillswap.model.PassportEntry;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * INNOVACION 9 - Ruta de aprendizaje.
 *
 * Una habilidad rara vez se aprende sola. "Android" sin "Java" delante es
 * perder el tiempo. Esto define rutas con prerrequisitos y marca en que
 * punto va el estudiante usando lo que ya registro en su Pasaporte.
 *
 * El catalogo es fijo y esta en el codigo a proposito: es conocimiento del
 * dominio (que va antes de que), no un dato que cada usuario deba inventar.
 *
 * AVISO: una ruta es una sugerencia de estudio, NO un plan curricular ni
 * una equivalencia academica.
 */
public final class LearningPathEngine {

    private LearningPathEngine() {
    }

    /** Un paso dentro de la ruta. */
    public static class Paso {
        private final String habilidad;
        private final String porQue;
        private boolean completado;
        private boolean enCurso;

        Paso(String habilidad, String porQue) {
            this.habilidad = habilidad;
            this.porQue = porQue;
        }

        public String getHabilidad() { return habilidad; }
        public String getPorQue() { return porQue; }
        public boolean estaCompletado() { return completado; }
        public boolean estaEnCurso() { return enCurso; }
    }

    /** Una ruta completa con su progreso. */
    public static class Ruta {
        private final String nombre;
        private final String descripcion;
        private final List<Paso> pasos = new ArrayList<>();

        Ruta(String nombre, String descripcion) {
            this.nombre = nombre;
            this.descripcion = descripcion;
        }

        public String getNombre() { return nombre; }
        public String getDescripcion() { return descripcion; }
        public List<Paso> getPasos() { return pasos; }

        public int getCompletados() {
            int n = 0;
            for (Paso p : pasos) if (p.completado) n++;
            return n;
        }

        public int getProgreso() {
            return pasos.isEmpty() ? 0 : getCompletados() * 100 / pasos.size();
        }

        /** El primer paso que falta, o null si la ruta esta terminada. */
        public Paso siguientePaso() {
            for (Paso p : pasos) if (!p.completado) return p;
            return null;
        }

        public boolean estaTerminada() {
            return !pasos.isEmpty() && getCompletados() == pasos.size();
        }
    }

    /** Catalogo de rutas: nombre -> (descripcion, pasos en orden). */
    private static Map<String, Ruta> catalogo() {
        Map<String, Ruta> rutas = new LinkedHashMap<>();

        rutas.put("android", ruta("Desarrollo Android",
                "De los fundamentos de programación a publicar una app",
                new String[][]{
                        {"Java", "La base del lenguaje: tipos, clases y objetos"},
                        {"POO", "Herencia y encapsulamiento antes de tocar el SDK"},
                        {"XML", "Las interfaces de Android se definen en XML"},
                        {"Android", "Actividades, fragmentos y ciclo de vida"},
                        {"Firebase", "Backend sin servidor para tu primera app real"}
                }));

        rutas.put("diseno", ruta("Diseño de interfaces",
                "Del boceto en papel al prototipo navegable",
                new String[][]{
                        {"Wireframes", "Estructurar antes de decorar"},
                        {"Figma", "La herramienta estándar en la industria"},
                        {"Material Design", "El sistema de diseño de Android"},
                        {"Prototipado", "Conectar pantallas y validar con usuarios"}
                }));

        rutas.put("datos", ruta("Bases de datos",
                "Guardar y consultar información de forma ordenada",
                new String[][]{
                        {"SQL", "Consultas, joins y normalización"},
                        {"Modelado", "Diseñar el esquema antes de escribir código"},
                        {"Firestore", "Bases de datos NoSQL orientadas a documentos"}
                }));

        rutas.put("web", ruta("Desarrollo web",
                "Construir tu primera página y darle vida",
                new String[][]{
                        {"HTML", "La estructura del contenido"},
                        {"CSS", "Presentación y diseño responsivo"},
                        {"JavaScript", "Interactividad en el navegador"},
                        {"React", "Componentes reutilizables"}
                }));

        rutas.put("ingles", ruta("Inglés técnico",
                "Leer documentación y defender tu trabajo en inglés",
                new String[][]{
                        {"Inglés", "Base gramatical y vocabulario general"},
                        {"Lectura técnica", "Entender documentación sin traductor"},
                        {"Conversación", "Explicar lo que haces en voz alta"}
                }));

        return rutas;
    }

    private static Ruta ruta(String nombre, String descripcion, String[][] pasos) {
        Ruta r = new Ruta(nombre, descripcion);
        for (String[] p : pasos) r.pasos.add(new Paso(p[0], p[1]));
        return r;
    }

    /**
     * Devuelve todas las rutas con el progreso del estudiante marcado.
     *
     * Un paso cuenta como completado si en el Pasaporte existe una entrada
     * con esa habilidad (aprendida, enseñada o practicada). Se compara sin
     * distinguir mayusculas ni tildes.
     */
    public static List<Ruta> rutasDe(List<PassportEntry> pasaporte) {
        List<String> dominadas = new ArrayList<>();
        if (pasaporte != null) {
            for (PassportEntry e : pasaporte) {
                if (e.getSkillName() != null) {
                    dominadas.add(normalizar(e.getSkillName()));
                }
            }
        }

        List<Ruta> resultado = new ArrayList<>(catalogo().values());
        for (Ruta r : resultado) {
            // "En curso" marca UN solo paso por ruta: el primero pendiente.
            // Si se marcara cualquier pendiente cuyo anterior este hecho,
            // una ruta con huecos mostraria varias flechas a la vez y daria
            // la impresion de que hay varios pasos actuales.
            boolean yaMarcado = false;
            for (Paso p : r.pasos) {
                p.completado = dominadas.contains(normalizar(p.habilidad));
                if (!p.completado && !yaMarcado) {
                    p.enCurso = true;
                    yaMarcado = true;
                } else {
                    p.enCurso = false;
                }
            }
        }
        return resultado;
    }

    /** La ruta en la que el estudiante va mas avanzado sin haberla terminado. */
    public static Ruta rutaRecomendada(List<PassportEntry> pasaporte) {
        Ruta mejor = null;
        for (Ruta r : rutasDe(pasaporte)) {
            if (r.estaTerminada()) continue;
            if (mejor == null || r.getProgreso() > mejor.getProgreso()) mejor = r;
        }
        return mejor;
    }

    /** Las habilidades que convendria buscar ahora mismo en Explorar. */
    public static List<String> siguientesHabilidades(List<PassportEntry> pasaporte) {
        List<String> sugerencias = new ArrayList<>();
        for (Ruta r : rutasDe(pasaporte)) {
            if (r.getCompletados() == 0 || r.estaTerminada()) continue;
            Paso p = r.siguientePaso();
            if (p != null && !sugerencias.contains(p.getHabilidad())) {
                sugerencias.add(p.getHabilidad());
            }
        }
        return sugerencias;
    }

    static String normalizar(String s) {
        if (s == null) return "";
        String r = s.toLowerCase().trim();
        r = r.replace('á', 'a').replace('é', 'e').replace('í', 'i')
             .replace('ó', 'o').replace('ú', 'u').replace('ñ', 'n');
        return r;
    }

    /** Nombres de las rutas disponibles, para listarlas. */
    public static List<String> nombresDeRutas() {
        List<String> n = new ArrayList<>();
        for (Ruta r : catalogo().values()) n.add(r.getNombre());
        return n;
    }

    /** Util para las pruebas. */
    public static int totalRutas() {
        return catalogo().size();
    }

    static List<String> habilidadesDe(String claveRuta) {
        Ruta r = catalogo().get(claveRuta);
        if (r == null) return new ArrayList<>();
        List<String> h = new ArrayList<>();
        for (Paso p : r.pasos) h.add(p.getHabilidad());
        return h;
    }

    static List<String> clavesRuta() {
        return new ArrayList<>(Arrays.asList("android", "diseno", "datos", "web", "ingles"));
    }
}
