// Restaura la acentuacion espanola en los textos de wireframes.js.
const fs = require('fs');
const path = process.argv[2];
let s = fs.readFileSync(path, 'utf8');

const WORDS = {
  sesion: 'sesión', Sesion: 'Sesión',
  contrasena: 'contraseña', Contrasena: 'Contraseña',
  Unete: 'Únete', electronico: 'electrónico', Registrate: 'Regístrate',
  reputacion: 'reputación', Reputacion: 'Reputación',
  Diseno: 'Diseño', diseno: 'diseño', Grafico: 'Gráfico',
  ensena: 'enseña', Ensena: 'Enseña', ensenas: 'enseñas', Ensenas: 'Enseñas',
  Ensenaste: 'Enseñaste', Ensenadas: 'Enseñadas', Enseno: 'Enseño',
  enseno: 'enseñó', ensenanza: 'enseñanza',
  Programacion: 'Programación', Basico: 'Básico', Ingles: 'Inglés',
  categoria: 'categoría', Categoria: 'Categoría', minima: 'mínima',
  Ilustracion: 'Ilustración', pagina: 'página', paginas: 'páginas',
  boton: 'botón', dias: 'días', Dias: 'Días',
  Redaccion: 'Redacción', Disenador: 'Diseñador', Aceptacion: 'Aceptación',
  Descripcion: 'Descripción', Validacion: 'Validación', validacion: 'validación',
  Autoevaluacion: 'Autoevaluación', autoevaluacion: 'autoevaluación',
  academica: 'académica', certificacion: 'certificación',
  calificacion: 'calificación', Comunicacion: 'Comunicación',
  Catalogo: 'Catálogo', Proximos: 'Próximos',
  movil: 'móvil', Moviles: 'Móviles', Ingenieria: 'Ingeniería',
  navegacion: 'navegación', codigo: 'código',
  automaticamente: 'automáticamente', despues: 'después', rapidos: 'rápidos',
  busqueda: 'búsqueda', calculo: 'cálculo', publico: 'público',
  Pestanas: 'Pestañas', modulos: 'módulos', academicos: 'académicos',
  Publicacion: 'Publicación', cumplio: 'cumplió', acepto: 'aceptó',
  confirmacion: 'confirmación', Rediseno: 'Rediseño', Titulo: 'Título',
  sabado: 'sábado', Sab: 'Sáb', Envia: 'Envía',
  Mia: 'Mía', Cesar: 'César', Andres: 'Andrés', Jose: 'José',
  Zacarias: 'Zacarías', Fabian: 'Fabián', Leguia: 'Leguía', Bendezu: 'Bendezú',
  Que: 'Qué', Como: 'Cómo'
};

for (const [k, v] of Object.entries(WORDS)) {
  s = s.replace(new RegExp('\\b' + k + '\\b', 'g'), v);
}

const PHRASES = [
  ['Define que se aprende y que se ofrece', 'Define qué se aprende y qué se ofrece'],
  ['Registra que practicaste y que lograste', 'Registra qué practicaste y qué lograste'],
  ['Tu buscas', 'Tú buscas'],
  ['Tu enseñas', 'Tú enseñas'],
  ['Tu aprendes', 'Tú aprendes'],
  ["'Olvidaste tu contraseña?'", "'¿Olvidaste tu contraseña?'"],
  ["'No tienes cuenta? Regístrate'", "'¿No tienes cuenta? Regístrate'"],
  ["'Ya tienes cuenta? Inicia sesión'", "'¿Ya tienes cuenta? Inicia sesión'"],
  ["'Qué quieres aprender hoy?'", "'¿Qué quieres aprender hoy?'"],
  ["'Por qué son compatibles?'", "'¿Por qué son compatibles?'"],
  ["'Cómo fue la experiencia?'", "'¿Cómo fue la experiencia?'"],
  ["'Nos vemos el sábado?'", "'¿Nos vemos el sábado?'"],
  ["'Hola César! Cuando empezamos?'", "'¡Hola César! ¿Cuándo empezamos?'"],
  ["'Hola Ana, te parece el sábado 10am?'", "'Hola Ana, ¿te parece el sábado 10am?'"],
  ["'Listo, gracias!'", "'¡Listo, gracias!'"]
];

for (const [a, b] of PHRASES) s = s.split(a).join(b);

fs.writeFileSync(path, s, 'utf8');
console.log('tildes aplicadas');
