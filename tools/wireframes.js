// Genera el PDF de wireframes de SkillSwap a partir de las pantallas reales
// implementadas en app/src/main/res/layout.
const fs = require('fs');
const SVG = process.argv[2] === '--svg';
const { Doc } = require(SVG ? './svg_backend' : './pdfkit_mini');

// ---------------------------------------------------------------- paleta ---
const INK = [0.13, 0.13, 0.16];
const MUT = [0.45, 0.45, 0.5];
const LINE = [0.72, 0.72, 0.76];
const SOFT = [0.95, 0.95, 0.96];
const BAND = [0.89, 0.89, 0.92];
const ACC = [0.42, 0.30, 0.96];   // #6C4DF6
const ACC_SOFT = [0.90, 0.88, 0.99];

// -------------------------------------------------------------- pantallas ---
const SCREENS = [
  { id: 'P01', name: 'Splash', file: 'activity_splash.xml',
    desc: 'Verifica la sesión activa y redirige.',
    el: [
      { t: 'gap', h: 120 },
      { t: 'logo', s: 'SkillSwap' },
      { t: 'center', s: 'Intercambia habilidades, no dinero', size: 6.5 },
      { t: 'gap', h: 60 },
      { t: 'spinner' }
    ] },

  { id: 'P02', name: 'Onboarding (3 slides)', file: 'activity_onboarding.xml',
    desc: 'ViewPager2 con 3 páginas y botón Omitir.',
    el: [
      { t: 'topright', s: 'Omitir' },
      { t: 'gap', h: 14 },
      { t: 'img', label: 'Ilustración', h: 120 },
      { t: 'gap', h: 10 },
      { t: 'center', s: 'SkillMatch inteligente', size: 10, bold: true },
      { t: 'p', s: 'Calculamos tu compatibilidad real con cada estudiante: habilidades, nivel, horarios, modalidad y reputación.', center: true },
      { t: 'gap', h: 10 },
      { t: 'dots', n: 3, active: 1 },
      { t: 'gap', h: 14 },
      { t: 'btn', label: 'Continuar', primary: true }
    ] },

  { id: 'P03', name: 'Registro', file: 'activity_register.xml',
    desc: 'Firebase Auth. Valida correo y contraseña.',
    el: [
      { t: 'back' },
      { t: 'gap', h: 6 },
      { t: 'title', s: 'Crea tu cuenta' },
      { t: 'sub', s: 'Únete a la comunidad SkillSwap' },
      { t: 'gap', h: 8 },
      { t: 'field', label: 'Nombres' },
      { t: 'field', label: 'Apellidos' },
      { t: 'field', label: 'Correo electrónico' },
      { t: 'field', label: 'Contraseña' },
      { t: 'field', label: 'Confirmar contraseña' },
      { t: 'gap', h: 6 },
      { t: 'btn', label: 'Registrarme', primary: true },
      { t: 'center', s: '¿Ya tienes cuenta? Inicia sesión', size: 6.5 }
    ] },

  { id: 'P04', name: 'Inicio de sesión', file: 'activity_login.xml',
    desc: 'Autentica con correo y contraseña.',
    el: [
      { t: 'gap', h: 24 },
      { t: 'title', s: 'Hola de nuevo' },
      { t: 'sub', s: 'Inicia sesión y sigue intercambiando' },
      { t: 'gap', h: 14 },
      { t: 'field', label: 'Correo electrónico' },
      { t: 'field', label: 'Contraseña' },
      { t: 'right', s: '¿Olvidaste tu contraseña?', size: 6.5 },
      { t: 'gap', h: 10 },
      { t: 'btn', label: 'Iniciar sesión', primary: true },
      { t: 'gap', h: 6 },
      { t: 'center', s: '¿No tienes cuenta? Regístrate', size: 6.5 }
    ] },

  { id: 'P05', name: 'Recuperar contraseña', file: 'activity_forgot_password.xml',
    desc: 'Envía el correo de restablecimiento.',
    el: [
      { t: 'back' },
      { t: 'gap', h: 20 },
      { t: 'title', s: 'Recuperar contraseña' },
      { t: 'sub', s: 'Te enviaremos un enlace para restablecerla' },
      { t: 'gap', h: 14 },
      { t: 'field', label: 'Correo electrónico' },
      { t: 'gap', h: 8 },
      { t: 'btn', label: 'Enviar enlace', primary: true }
    ] },

  { id: 'P06', name: 'Inicio (Home)', file: 'fragment_home.xml',
    desc: 'Resumen: accesos rápidos, matches y retos.',
    el: [
      { t: 'homehead', name: 'César', level: 'Colaborador' },
      { t: 'search', ph: 'Busca una habilidad o estudiante' },
      { t: 'quick4', items: ['Pasaporte', 'Puntos', 'Retos', 'Solicit.'] },
      { t: 'h', s: 'Habilidades populares' },
      { t: 'chips', items: ['Java', 'Inglés', 'Figma', 'Excel'] },
      { t: 'hrow', s: 'Matches para ti', right: 'Ver todo' },
      { t: 'matchcard', name: 'Ana Torres', sub: 'Diseño Gráfico - 6to ciclo', score: '96%' },
      { t: 'h', s: 'Intercambios activos' },
      { t: 'card', title: 'Java  <>  Figma', sub: 'En proceso - 2 de 3 sesiones' },
      { t: 'hrow', s: 'Retos disponibles', right: 'Ver todo' },
      { t: 'card', title: 'Crear una página web en 7 días', sub: '2 de 4 participantes' },
      { t: 'nav', active: 0 }
    ] },

  { id: 'P07', name: 'Explorar estudiantes', file: 'fragment_explore.xml',
    desc: 'Lista de coincidencias con búsqueda y filtros.',
    el: [
      { t: 'gap', h: 6 },
      { t: 'hrow', s: 'Explorar estudiantes', right: '24 result.', big: true },
      { t: 'searchfilter', ph: 'Buscar' },
      { t: 'chips', items: ['Programación', 'Virtual', '+70%'] },
      { t: 'gap', h: 4 },
      { t: 'matchcard', name: 'Ana Torres', sub: 'Enseña Figma - Busca Java', score: '96%' },
      { t: 'matchcard', name: 'Luis Quispe', sub: 'Enseña Inglés - Busca Python', score: '82%' },
      { t: 'matchcard', name: 'Mía Rojas', sub: 'Enseña Excel - Busca Oratoria', score: '74%' },
      { t: 'nav', active: 1 }
    ] },

  { id: 'P08', name: 'Filtros', file: 'sheet_filters.xml',
    desc: 'Bottom sheet de filtros de búsqueda.',
    el: [
      { t: 'sheettop' },
      { t: 'h', s: 'Filtros' },
      { t: 'label', s: 'Categoría' },
      { t: 'chips', items: ['Todas', 'Programación', 'Diseño'] },
      { t: 'label', s: 'Nivel' },
      { t: 'chips', items: ['Básico', 'Intermedio', 'Avanzado'] },
      { t: 'label', s: 'Modalidad' },
      { t: 'chips', items: ['Presencial', 'Virtual', 'Ambas'] },
      { t: 'label', s: 'Compatibilidad mínima' },
      { t: 'slider', value: '70 %' },
      { t: 'gap', h: 8 },
      { t: 'btnrow', left: 'Limpiar', right: 'Aplicar' }
    ] },

  { id: 'P09', name: 'Detalle de coincidencia', file: 'activity_match_detail.xml',
    desc: 'Explica el cálculo del porcentaje SkillMatch.',
    el: [
      { t: 'appbar', title: 'Coincidencia', back: true },
      { t: 'gap', h: 6 },
      { t: 'bigavatar', name: 'Ana Torres', score: '96 % compatible' },
      { t: 'h', s: 'Por que son compatibles?' },
      { t: 'reason', s: 'Ana enseña Diseño' },
      { t: 'reason', s: 'Tú buscas Diseño' },
      { t: 'reason', s: 'Tú enseñas Java' },
      { t: 'reason', s: 'Ana busca Java' },
      { t: 'reason', s: 'Horarios compatibles (3 bloques)' },
      { t: 'reason', s: 'Modalidad compatible (Virtual)' },
      { t: 'note', s: 'Cómo se calcula: habilidades 45 - nivel 20 - disponibilidad 13 - modalidad 12 - reputación 10' },
      { t: 'gap', h: 6 },
      { t: 'btn', label: 'Enviar solicitud', primary: true }
    ] },

  { id: 'P10', name: 'Perfil de otro usuario', file: 'activity_user_profile.xml',
    desc: 'Perfil público con habilidades y reputación.',
    el: [
      { t: 'appbar', title: 'Perfil', back: true },
      { t: 'gap', h: 6 },
      { t: 'bigavatar', name: 'Ana Torres', score: 'Diseño Gráfico - 6to ciclo' },
      { t: 'stat3', items: [['4.8', 'Reputación'], ['7', 'Intercambios'], ['210', 'SkillPoints']] },
      { t: 'label', s: 'Ofrece' },
      { t: 'chips', items: ['Figma', 'Photoshop'] },
      { t: 'label', s: 'Quiere aprender' },
      { t: 'chips', items: ['Java', 'SQL'] },
      { t: 'h', s: 'Calificaciones recibidas' },
      { t: 'card', title: 'Puntual y muy clara explicando', sub: 'Luis Q. - 5.0' },
      { t: 'gap', h: 4 },
      { t: 'btn', label: 'Intercambiar', primary: true }
    ] },

  { id: 'P11', name: 'Enviar solicitud', file: 'activity_send_request.xml',
    desc: 'Define qué se aprende y qué se ofrece.',
    el: [
      { t: 'appbar', title: 'Enviar solicitud', back: true },
      { t: 'gap', h: 4 },
      { t: 'minihead', name: 'Ana Torres', sub: 'Diseño Gráfico', score: '96%' },
      { t: 'label', s: 'Quiero aprender' },
      { t: 'chips', items: ['Figma', 'Photoshop'] },
      { t: 'label', s: 'Puedo ensenar' },
      { t: 'chips', items: ['Java', 'SQL'] },
      { t: 'label', s: 'Modalidad' },
      { t: 'chips', items: ['Presencial', 'Virtual'] },
      { t: 'field', label: 'Horario propuesto' },
      { t: 'area', label: 'Mensaje', h: 34 },
      { t: 'gap', h: 4 },
      { t: 'btn', label: 'Enviar solicitud', primary: true }
    ] },

  { id: 'P12', name: 'Solicitudes', file: 'activity_requests.xml',
    desc: 'Pestañas Recibidas / Enviadas con acciones.',
    el: [
      { t: 'appbar', title: 'Solicitudes', back: true },
      { t: 'tabs', items: ['Recibidas', 'Enviadas'], active: 0 },
      { t: 'gap', h: 4 },
      { t: 'reqcard', name: 'Ana Torres', sub: 'Te ofrece Figma - Quiere Java', state: 'PENDIENTE' },
      { t: 'reqcard', name: 'Luis Quispe', sub: 'Te ofrece Inglés - Quiere Python', state: 'PENDIENTE' },
      { t: 'card', title: 'Mía Rojas', sub: 'ACEPTADA - chat habilitado' }
    ] },

  { id: 'P13', name: 'Mis intercambios', file: 'fragment_exchanges.xml',
    desc: 'Pestañas Próximos / En proceso / Completados.',
    el: [
      { t: 'gap', h: 6 },
      { t: 'hrow', s: 'Mis intercambios', right: 'Solicitudes', big: true },
      { t: 'tabs', items: ['Próximos', 'En proceso', 'Completados'], active: 1 },
      { t: 'gap', h: 4 },
      { t: 'exchcard', name: 'Ana Torres', sub: 'Java  <>  Figma', pct: 66 },
      { t: 'exchcard', name: 'Luis Quispe', sub: 'Python  <>  Inglés', pct: 33 },
      { t: 'nav', active: 2 }
    ] },

  { id: 'P14', name: 'Detalle de intercambio', file: 'activity_exchange_detail.xml',
    desc: 'Progreso, contrato, chat y cierre.',
    el: [
      { t: 'appbar', title: 'Intercambio', back: true },
      { t: 'gap', h: 4 },
      { t: 'minihead', name: 'Ana Torres', sub: 'EN PROCESO', score: '' },
      { t: 'label', s: 'El intercambio' },
      { t: 'row2', l: 'Tú enseñas', r: 'Java' },
      { t: 'row2', l: 'Tú aprendes', r: 'Figma' },
      { t: 'row2', l: 'Modalidad', r: 'Virtual' },
      { t: 'progress', label: 'Progreso', pct: 66, txt: '2 de 3 sesiones' },
      { t: 'rowlink', s: 'Contrato de aprendizaje' },
      { t: 'rowlink', s: 'Registrar actividad' },
      { t: 'rowlink', s: 'Abrir chat' },
      { t: 'gap', h: 4 },
      { t: 'btn', label: 'Marcar como completado', primary: true },
      { t: 'center', s: 'Esperando confirmación de Ana', size: 6 }
    ] },

  { id: 'P15', name: 'Contrato de aprendizaje', file: 'activity_contract.xml',
    desc: 'Acuerdo que ambos deben aceptar.',
    el: [
      { t: 'appbar', title: 'Contrato de aprendizaje', back: true },
      { t: 'note', s: 'Definan juntos el objetivo antes de iniciar' },
      { t: 'area', label: 'Objetivo del intercambio', h: 26 },
      { t: 'field2', l1: 'Sesiones', v1: '3', l2: 'Min/sesión', v2: '60' },
      { t: 'label', s: 'Modalidad' },
      { t: 'chips', items: ['Presencial', 'Virtual'] },
      { t: 'field', label: 'Meta concreta' },
      { t: 'field', label: 'Actividad final' },
      { t: 'label', s: 'Aceptación del acuerdo' },
      { t: 'row2', l: 'César Ricra', r: 'Aceptado' },
      { t: 'row2', l: 'Ana Torres', r: 'Pendiente' },
      { t: 'gap', h: 4 },
      { t: 'btnrow', left: 'Guardar', right: 'Aceptar acuerdo' }
    ] },

  { id: 'P16', name: 'Chats', file: 'fragment_chats.xml',
    desc: 'Conversaciones abiertas por cada intercambio.',
    el: [
      { t: 'gap', h: 6 },
      { t: 'hrow', s: 'Chats', right: '', big: true },
      { t: 'note', s: 'El chat se habilita con cada intercambio aceptado' },
      { t: 'chatrow', name: 'Ana Torres', msg: '¿Nos vemos el sábado?', time: '10:24', unread: '2' },
      { t: 'chatrow', name: 'Luis Quispe', msg: 'Te paso el material', time: 'Ayer', unread: '' },
      { t: 'chatrow', name: 'Mía Rojas', msg: '¡Listo, gracias!', time: 'Lun', unread: '' },
      { t: 'nav', active: 3 }
    ] },

  { id: 'P17', name: 'Chat individual', file: 'activity_chat.xml',
    desc: 'Mensajes en tiempo real con Firestore.',
    el: [
      { t: 'chathead', name: 'Ana Torres', sub: 'Java  <>  Figma' },
      { t: 'gap', h: 6 },
      { t: 'msgsys', s: 'Intercambio aceptado - chat habilitado' },
      { t: 'msg', side: 'in', s: '¡Hola César! ¿Cuándo empezamos?' },
      { t: 'msg', side: 'out', s: 'Hola Ana, ¿te parece el sábado 10am?' },
      { t: 'msg', side: 'in', s: 'Perfecto, nos vemos por Meet' },
      { t: 'msg', side: 'out', s: 'Listo, te envio el enlace' },
      { t: 'inputbar', ph: 'Escribe un mensaje...' }
    ] },

  { id: 'P18', name: 'Calificar intercambio', file: 'activity_rate_exchange.xml',
    desc: 'Puntualidad, comunicacion y enseñanza.',
    el: [
      { t: 'appbar', title: 'Calificar intercambio', back: true },
      { t: 'gap', h: 6 },
      { t: 'bigavatar', name: 'Ana Torres', score: 'Te enseñó Figma' },
      { t: 'center', s: '¿Cómo fue la experiencia?', size: 7.5, bold: true },
      { t: 'stars', n: 5 },
      { t: 'label', s: 'Detalles' },
      { t: 'rating', label: 'Puntualidad' },
      { t: 'rating', label: 'Comunicación' },
      { t: 'rating', label: 'Calidad de enseñanza' },
      { t: 'area', label: 'Comentario', h: 30 },
      { t: 'gap', h: 4 },
      { t: 'btn', label: 'Enviar calificación', primary: true }
    ] },

  { id: 'P19', name: 'Validación de aprendizaje', file: 'activity_evidence.xml',
    desc: 'Evidencia y autoevaluación al cerrar.',
    el: [
      { t: 'appbar', title: 'Validación de aprendizaje', back: true },
      { t: 'note', s: 'Registra qué practicaste y qué lograste.' },
      { t: 'area', label: 'Actividad realizada', h: 28 },
      { t: 'check', s: 'Se cumplió el objetivo del contrato' },
      { t: 'label', s: 'Autoevaluación' },
      { t: 'stars', n: 5 },
      { t: 'label', s: 'Adjuntar evidencia (opcional)' },
      { t: 'img', label: 'Subir imagen', h: 48 },
      { t: 'area', label: 'Notas (opcional)', h: 24 },
      { t: 'gap', h: 4 },
      { t: 'btn', label: 'Registrar actividad', primary: true },
      { t: 'note', s: 'Autoevaluación entre pares. No es una certificación académica.' }
    ] },

  { id: 'P20', name: 'Mi perfil', file: 'fragment_profile.xml',
    desc: 'Datos, habilidades y accesos a los módulos.',
    el: [
      { t: 'gap', h: 8 },
      { t: 'bigavatar', name: 'César Ricra', score: 'Ing. de Sistemas - 5to ciclo' },
      { t: 'btn', label: 'Editar perfil', primary: false },
      { t: 'stat3', items: [['4.9', 'Reputación'], ['5', 'Intercambios'], ['160', 'SkillPoints']] },
      { t: 'label', s: 'Mis habilidades' },
      { t: 'chips', items: ['Java', 'SQL'] },
      { t: 'chips', items: ['Figma', 'Inglés'] },
      { t: 'rowlink', s: 'Pasaporte de habilidades' },
      { t: 'rowlink', s: 'SkillPoints' },
      { t: 'rowlink', s: 'Skill Challenges' },
      { t: 'rowlink', s: 'Historial' },
      { t: 'rowlink', s: 'Notificaciones' },
      { t: 'nav', active: 4 }
    ] },

  { id: 'P21', name: 'Editar perfil', file: 'activity_edit_profile.xml',
    desc: 'Datos académicos, modalidad y disponibilidad.',
    el: [
      { t: 'appbar', title: 'Editar perfil', back: true },
      { t: 'gap', h: 4 },
      { t: 'avatarpick' },
      { t: 'field', label: 'Nombres' },
      { t: 'field', label: 'Universidad' },
      { t: 'field2', l1: 'Carrera', v1: '', l2: 'Ciclo', v2: '' },
      { t: 'area', label: 'Descripción (max. 280)', h: 26 },
      { t: 'label', s: 'Modalidad' },
      { t: 'chips', items: ['Presencial', 'Virtual', 'Ambas'] },
      { t: 'label', s: 'Disponibilidad' },
      { t: 'chips', items: ['Lun AM', 'Mar PM', 'Sáb AM'] },
      { t: 'gap', h: 4 },
      { t: 'btn', label: 'Guardar', primary: true }
    ] },

  { id: 'P22', name: 'Mis habilidades', file: 'activity_my_skills.xml',
    desc: 'Pestañas Enseño / Quiero aprender.',
    el: [
      { t: 'appbar', title: 'Mis habilidades', back: true },
      { t: 'tabs', items: ['Enseño', 'Quiero aprender'], active: 0 },
      { t: 'gap', h: 4 },
      { t: 'skillrow', name: 'Java', sub: 'Programación - Avanzado' },
      { t: 'skillrow', name: 'SQL', sub: 'Programación - Intermedio' },
      { t: 'skillrow', name: 'Excel', sub: 'Otros - Básico' },
      { t: 'fab', label: 'Agregar habilidad' }
    ] },

  { id: 'P23', name: 'Catálogo / Agregar habilidad', file: 'activity_skill_catalog.xml + sheet_add_skill.xml',
    desc: 'Catálogo por categoría y hoja de nivel.',
    el: [
      { t: 'appbar', title: 'Catálogo de habilidades', back: true },
      { t: 'search', ph: 'Buscar habilidad' },
      { t: 'chips', items: ['Programación', 'Diseño', 'Idiomas'] },
      { t: 'skillrow', name: 'Python', sub: 'Programación' },
      { t: 'skillrow', name: 'Figma', sub: 'Diseño' },
      { t: 'gap', h: 6 },
      { t: 'sheettop' },
      { t: 'h', s: 'Agregar habilidad' },
      { t: 'row2', l: 'Habilidad', r: 'Figma' },
      { t: 'label', s: 'Nivel' },
      { t: 'chips', items: ['Básico', 'Intermedio', 'Avanzado'] },
      { t: 'field', label: 'Nota (opcional)' },
      { t: 'btn', label: 'Guardar', primary: true }
    ] },

  { id: 'P24', name: 'Pasaporte de habilidades', file: 'activity_passport.xml',
    desc: 'Nivel alcanzado por habilidad e insignias.',
    el: [
      { t: 'appbar', title: 'Pasaporte de habilidades', back: true },
      { t: 'stat3', items: [['2', 'Enseñadas'], ['2', 'Aprendidas'], ['5', 'Intercambios']] },
      { t: 'label', s: 'Insignias' },
      { t: 'badges', items: ['Primer\nintercambio', '5 sesiones', 'Mentor'] },
      { t: 'label', s: 'Mis habilidades registradas' },
      { t: 'passrow', name: 'JAVA', sub: 'Intermedio - 5 intercambios - 4.8', pct: 62 },
      { t: 'passrow', name: 'FIGMA', sub: 'Básico - 1 intercambio - 5.0', pct: 24 },
      { t: 'label', s: 'Validación de aprendizaje' },
      { t: 'card', title: 'Rediseño de una landing en Figma', sub: 'Objetivo cumplido - autoeval. 4/5' },
      { t: 'note', s: 'Refleja tu actividad en SkillSwap. No es una certificación académica.' }
    ] },

  { id: 'P25', name: 'SkillPoints', file: 'activity_skill_points.xml',
    desc: 'Saldo, nivel, escala e historial.',
    el: [
      { t: 'appbar', title: 'SkillPoints', back: true },
      { t: 'gap', h: 8 },
      { t: 'center', s: '160', size: 22, bold: true },
      { t: 'center', s: 'SkillPoints acumulados - Colaborador', size: 6.5 },
      { t: 'progress', label: '', pct: 45, txt: 'Faltan 140 para Mentor' },
      { t: 'label', s: 'Niveles' },
      { t: 'row2', l: 'Principiante', r: '0 - 99' },
      { t: 'row2', l: 'Colaborador', r: '100 - 299' },
      { t: 'row2', l: 'Mentor', r: '300 - 699' },
      { t: 'row2', l: 'SkillMaster', r: '700 +' },
      { t: 'label', s: 'Movimientos recientes' },
      { t: 'row2', l: 'Intercambio completado', r: '+20' },
      { t: 'row2', l: 'Buena calificación', r: '+5' },
      { t: 'row2', l: 'Contrato aceptado', r: '+8' },
      { t: 'note', s: 'Puntos de reconocimiento. No son dinero.' }
    ] },

  { id: 'P26', name: 'Skill Challenges', file: 'activity_challenges.xml',
    desc: 'Retos colaborativos abiertos.',
    el: [
      { t: 'appbar', title: 'Skill Challenges', back: true },
      { t: 'note', s: 'Únete a un equipo, aporta tu habilidad y construyan algo juntos.' },
      { t: 'chalcard', title: 'Crear una página web en 7 días', sub: 'Programador - Diseñador - Redactor', meta: '2 de 4 - 40% - 5 días', pct: 40 },
      { t: 'chalcard', title: 'App de reciclaje para el campus', sub: 'Android - UX - Marketing', meta: '3 de 5 - 15% - 12 días', pct: 15 },
      { t: 'fab', label: 'Crear reto' }
    ] },

  { id: 'P27', name: 'Detalle del reto', file: 'activity_challenge_detail.xml',
    desc: 'Objetivo, equipo y postulaciones.',
    el: [
      { t: 'appbar', title: 'Reto', back: true },
      { t: 'gap', h: 4 },
      { t: 'title2', s: 'Crear una página web en 7 días' },
      { t: 'sub', s: 'Organiza: Mía Rojas - ABIERTO' },
      { t: 'label', s: 'Objetivo' },
      { t: 'p', s: 'Publicar una landing funcional con contenido propio antes del viernes.' },
      { t: 'label', s: 'Se necesita' },
      { t: 'chips', items: ['Programador', 'Diseñador', 'Redactor'] },
      { t: 'progress', label: 'Avance del reto', pct: 40, txt: '2 de 4 participantes' },
      { t: 'label', s: 'Participantes' },
      { t: 'row2', l: 'Mía Rojas - Redacción', r: 'ACEPTADO' },
      { t: 'row2', l: 'Luis Quispe - HTML/CSS', r: 'PENDIENTE' },
      { t: 'gap', h: 4 },
      { t: 'btn', label: 'Quiero participar', primary: true }
    ] },

  { id: 'P28', name: 'Crear reto', file: 'activity_create_challenge.xml',
    desc: 'Publicación de un nuevo reto.',
    el: [
      { t: 'appbar', title: 'Crear reto', back: true },
      { t: 'field', label: 'Título del reto' },
      { t: 'area', label: 'Descripción', h: 28 },
      { t: 'field', label: 'Objetivo' },
      { t: 'label', s: 'Categoría' },
      { t: 'chips', items: ['Programación', 'Diseño'] },
      { t: 'label', s: 'Habilidades requeridas' },
      { t: 'note', s: 'Selecciona los perfiles que necesitas en el equipo' },
      { t: 'chips', items: ['Java', 'Figma', 'Redacción'] },
      { t: 'field2', l1: 'Participantes', v1: '4', l2: 'Días', v2: '7' },
      { t: 'gap', h: 4 },
      { t: 'btn', label: 'Publicar reto', primary: true }
    ] },

  { id: 'P29', name: 'Notificaciones', file: 'activity_notifications.xml',
    desc: 'Centro interno + push (FCM).',
    el: [
      { t: 'appbar', title: 'Notificaciones', back: true, action: 'Leer todo' },
      { t: 'gap', h: 4 },
      { t: 'notif', title: 'Nueva solicitud de Ana Torres', sub: 'Hace 5 min', unread: true },
      { t: 'notif', title: 'Ana aceptó tu solicitud', sub: 'Hace 1 h', unread: true },
      { t: 'notif', title: 'Nuevo mensaje de Luis Quispe', sub: 'Ayer', unread: false },
      { t: 'notif', title: 'Insignia desbloqueada: Primer intercambio', sub: 'Lun', unread: false },
      { t: 'notif', title: 'Nueva coincidencia al 82%', sub: 'Lun', unread: false }
    ] },

  { id: 'P30', name: 'Historial', file: 'activity_history.xml',
    desc: 'Intercambios cerrados y calificaciones.',
    el: [
      { t: 'appbar', title: 'Historial', back: true },
      { t: 'gap', h: 4 },
      { t: 'histrow', name: 'Ana Torres', sub: 'Enseñaste Java - Aprendiste Figma', meta: '5.0' },
      { t: 'histrow', name: 'Luis Quispe', sub: 'Enseñaste SQL - Aprendiste Inglés', meta: '4.5' },
      { t: 'histrow', name: 'Mía Rojas', sub: 'Enseñaste Excel - Aprendiste Oratoria', meta: '5.0' },
      { t: 'gap', h: 6 },
      { t: 'row2', l: 'Total de intercambios', r: '5' },
      { t: 'row2', l: 'Promedio recibido', r: '4.9' }
    ] }
];

// ------------------------------------------------------------- renderizado ---
const PW = 240, PH = 432, BEZ = 5, PAD = 9;

function drawPhone(p, x, y, screen) {
  p.roundRect(x, y, PW, PH, 10, { stroke: LINE, fill: [1, 1, 1], lw: 0.9 });
  p.roundRect(x + BEZ, y + BEZ, PW - 2 * BEZ, PH - 2 * BEZ, 6, { stroke: [0.85, 0.85, 0.88], lw: 0.4 });

  // barra de estado
  const sbY = y + BEZ + 2;
  p.text(x + PAD, sbY + 6.5, '21:06', { size: 5, color: MUT });
  p.text(x + PW - PAD, sbY + 6.5, 'LTE  100%', { size: 5, color: MUT, align: 'right' });

  const ctx = {
    p, x: x + PAD, w: PW - 2 * PAD, y: sbY + 12,
    bottom: y + PH - BEZ - 4, navDrawn: false
  };
  for (const el of screen.el) {
    if (ctx.y > ctx.bottom - 4 && el.t !== 'nav' && el.t !== 'fab' && el.t !== 'inputbar') continue;
    (RENDER[el.t] || (() => {}))(ctx, el);
  }
}

const RENDER = {
  gap: (c, e) => { c.y += e.h; },

  logo: (c, e) => {
    c.p.roundRect(c.x + c.w / 2 - 22, c.y, 44, 44, 10, { fill: ACC_SOFT, stroke: ACC, lw: 0.8 });
    c.p.text(c.x + c.w / 2, c.y + 28, 'SS', { size: 14, bold: true, align: 'center', color: ACC });
    c.y += 54;
    c.p.text(c.x + c.w / 2, c.y, e.s, { size: 14, bold: true, align: 'center', color: INK });
    c.y += 12;
  },

  spinner: (c) => {
    c.p.circle(c.x + c.w / 2, c.y + 6, 6, { stroke: LINE, lw: 1.2 });
    c.y += 18;
  },

  title: (c, e) => { c.p.text(c.x, c.y + 10, e.s, { size: 11.5, bold: true, color: INK }); c.y += 16; },
  title2: (c, e) => {
    for (const ln of c.p.wrap(e.s, 10, true, c.w)) { c.p.text(c.x, c.y + 9, ln, { size: 10, bold: true, color: INK }); c.y += 12; }
  },
  sub: (c, e) => { c.p.text(c.x, c.y + 7, e.s, { size: 6.5, color: MUT }); c.y += 12; },
  h: (c, e) => { c.y += 3; c.p.text(c.x, c.y + 7, e.s, { size: 7.5, bold: true, color: INK }); c.y += 12; },
  label: (c, e) => { c.y += 3; c.p.text(c.x, c.y + 6.5, e.s, { size: 6.2, bold: true, color: MUT }); c.y += 11; },

  hrow: (c, e) => {
    c.y += 2;
    c.p.text(c.x, c.y + 8, e.s, { size: e.big ? 10.5 : 7.5, bold: true, color: INK });
    if (e.right) c.p.text(c.x + c.w, c.y + 8, e.right, { size: 6, color: ACC, align: 'right' });
    c.y += e.big ? 15 : 12;
  },

  p: (c, e) => {
    for (const ln of c.p.wrap(e.s, 6.2, false, c.w)) {
      c.p.text(e.center ? c.x + c.w / 2 : c.x, c.y + 6, ln,
        { size: 6.2, color: MUT, align: e.center ? 'center' : 'left' });
      c.y += 8.5;
    }
  },

  center: (c, e) => {
    c.p.text(c.x + c.w / 2, c.y + (e.size || 7), e.s,
      { size: e.size || 7, bold: e.bold, align: 'center', color: e.bold ? INK : MUT });
    c.y += (e.size || 7) + 6;
  },
  right: (c, e) => { c.p.text(c.x + c.w, c.y + 6.5, e.s, { size: e.size || 6.5, color: ACC, align: 'right' }); c.y += 11; },
  topright: (c, e) => { c.p.text(c.x + c.w, c.y + 7, e.s, { size: 6.5, color: MUT, align: 'right' }); c.y += 10; },
  back: (c) => { c.p.text(c.x, c.y + 8, '<', { size: 9, bold: true, color: INK }); c.y += 12; },

  appbar: (c, e) => {
    c.p.rect(c.x - PAD + BEZ, c.y, c.w + 2 * PAD - 2 * BEZ, 20, { fill: SOFT });
    if (e.back) c.p.text(c.x, c.y + 13, '<', { size: 8.5, bold: true, color: INK });
    c.p.text(c.x + (e.back ? 12 : 0), c.y + 13, c.p.clip(e.title, 8, true, c.w - 50), { size: 8, bold: true, color: INK });
    if (e.action) c.p.text(c.x + c.w, c.y + 13, e.action, { size: 5.8, color: ACC, align: 'right' });
    c.y += 26;
  },

  field: (c, e) => {
    c.p.roundRect(c.x, c.y, c.w, 20, 3, { stroke: LINE, lw: 0.5 });
    c.p.text(c.x + 6, c.y + 13, e.label, { size: 6.3, color: MUT });
    c.y += 25;
  },

  field2: (c, e) => {
    const w = (c.w - 8) / 2;
    c.p.roundRect(c.x, c.y, w, 20, 3, { stroke: LINE, lw: 0.5 });
    c.p.text(c.x + 6, c.y + 13, e.l1 + (e.v1 ? '   ' + e.v1 : ''), { size: 6.3, color: MUT });
    c.p.roundRect(c.x + w + 8, c.y, w, 20, 3, { stroke: LINE, lw: 0.5 });
    c.p.text(c.x + w + 14, c.y + 13, e.l2 + (e.v2 ? '   ' + e.v2 : ''), { size: 6.3, color: MUT });
    c.y += 25;
  },

  area: (c, e) => {
    c.p.roundRect(c.x, c.y, c.w, e.h, 3, { stroke: LINE, lw: 0.5 });
    c.p.text(c.x + 6, c.y + 11, e.label, { size: 6.3, color: MUT });
    c.y += e.h + 5;
  },

  search: (c, e) => {
    c.p.roundRect(c.x, c.y, c.w, 19, 9.5, { fill: SOFT, stroke: LINE, lw: 0.4 });
    c.p.circle(c.x + 11, c.y + 9.5, 3, { stroke: MUT, lw: 0.6 });
    c.p.text(c.x + 19, c.y + 12, e.ph, { size: 6.2, color: MUT });
    c.y += 24;
  },

  searchfilter: (c, e) => {
    const bw = 42;
    c.p.roundRect(c.x, c.y, c.w - bw - 6, 19, 9.5, { fill: SOFT, stroke: LINE, lw: 0.4 });
    c.p.circle(c.x + 11, c.y + 9.5, 3, { stroke: MUT, lw: 0.6 });
    c.p.text(c.x + 19, c.y + 12, e.ph, { size: 6.2, color: MUT });
    c.p.roundRect(c.x + c.w - bw, c.y, bw, 19, 4, { stroke: ACC, lw: 0.6 });
    c.p.text(c.x + c.w - bw / 2, c.y + 12, 'Filtros', { size: 6, color: ACC, align: 'center' });
    c.y += 24;
  },

  chips: (c, e) => {
    let cx = c.x;
    for (const it of e.items) {
      const w = c.p.width(it, 6, false) + 12;
      if (cx + w > c.x + c.w) break;
      c.p.roundRect(cx, c.y, w, 14, 7, { fill: SOFT, stroke: LINE, lw: 0.4 });
      c.p.text(cx + w / 2, c.y + 9.5, it, { size: 6, color: INK, align: 'center' });
      cx += w + 5;
    }
    c.y += 19;
  },

  tabs: (c, e) => {
    const w = c.w / e.items.length;
    c.p.line(c.x, c.y + 16, c.x + c.w, c.y + 16, { color: LINE, lw: 0.5 });
    e.items.forEach((it, i) => {
      const act = i === e.active;
      c.p.text(c.x + w * i + w / 2, c.y + 11, c.p.clip(it, 6.3, act, w - 4),
        { size: 6.3, bold: act, color: act ? ACC : MUT, align: 'center' });
      if (act) c.p.rect(c.x + w * i + 6, c.y + 15, w - 12, 1.6, { fill: ACC });
    });
    c.y += 22;
  },

  btn: (c, e) => {
    c.p.roundRect(c.x, c.y, c.w, 21, 5,
      e.primary ? { fill: ACC } : { stroke: ACC, lw: 0.7 });
    c.p.text(c.x + c.w / 2, c.y + 13.5, e.label,
      { size: 7, bold: true, align: 'center', color: e.primary ? [1, 1, 1] : ACC });
    c.y += 27;
  },

  btnrow: (c, e) => {
    const w = (c.w - 8) / 2;
    c.p.roundRect(c.x, c.y, w, 21, 5, { stroke: ACC, lw: 0.7 });
    c.p.text(c.x + w / 2, c.y + 13.5, e.left, { size: 7, bold: true, align: 'center', color: ACC });
    c.p.roundRect(c.x + w + 8, c.y, w, 21, 5, { fill: ACC });
    c.p.text(c.x + w + 8 + w / 2, c.y + 13.5, e.right, { size: 7, bold: true, align: 'center', color: [1, 1, 1] });
    c.y += 27;
  },

  card: (c, e) => {
    const h = e.sub ? 30 : 22;
    c.p.roundRect(c.x, c.y, c.w, h, 4, { stroke: LINE, lw: 0.5 });
    c.p.text(c.x + 7, c.y + 12, c.p.clip(e.title, 6.8, true, c.w - 14), { size: 6.8, bold: true, color: INK });
    if (e.sub) c.p.text(c.x + 7, c.y + 23, c.p.clip(e.sub, 6, false, c.w - 14), { size: 6, color: MUT });
    c.y += h + 6;
  },

  matchcard: (c, e) => {
    const h = 34;
    c.p.roundRect(c.x, c.y, c.w, h, 4, { stroke: LINE, lw: 0.5 });
    c.p.circle(c.x + 16, c.y + h / 2, 10, { fill: SOFT, stroke: LINE, lw: 0.4 });
    c.p.text(c.x + 31, c.y + 14, c.p.clip(e.name, 7, true, c.w - 75), { size: 7, bold: true, color: INK });
    c.p.text(c.x + 31, c.y + 24, c.p.clip(e.sub, 5.8, false, c.w - 75), { size: 5.8, color: MUT });
    c.p.roundRect(c.x + c.w - 36, c.y + 10, 30, 14, 7, { fill: ACC_SOFT });
    c.p.text(c.x + c.w - 21, c.y + 19.5, e.score, { size: 6.3, bold: true, color: ACC, align: 'center' });
    c.y += h + 6;
  },

  reqcard: (c, e) => {
    const h = 46;
    c.p.roundRect(c.x, c.y, c.w, h, 4, { stroke: LINE, lw: 0.5 });
    c.p.circle(c.x + 15, c.y + 15, 8, { fill: SOFT, stroke: LINE, lw: 0.4 });
    c.p.text(c.x + 28, c.y + 13, e.name, { size: 6.8, bold: true, color: INK });
    c.p.text(c.x + 28, c.y + 22, c.p.clip(e.sub, 5.8, false, c.w - 34), { size: 5.8, color: MUT });
    const bw = (c.w - 20) / 2;
    c.p.roundRect(c.x + 7, c.y + 27, bw, 13, 3, { stroke: LINE, lw: 0.5 });
    c.p.text(c.x + 7 + bw / 2, c.y + 36, 'Rechazar', { size: 5.8, align: 'center', color: MUT });
    c.p.roundRect(c.x + 13 + bw, c.y + 27, bw, 13, 3, { fill: ACC });
    c.p.text(c.x + 13 + bw + bw / 2, c.y + 36, 'Aceptar', { size: 5.8, bold: true, align: 'center', color: [1, 1, 1] });
    c.y += h + 6;
  },

  exchcard: (c, e) => {
    const h = 42;
    c.p.roundRect(c.x, c.y, c.w, h, 4, { stroke: LINE, lw: 0.5 });
    c.p.circle(c.x + 15, c.y + 16, 9, { fill: SOFT, stroke: LINE, lw: 0.4 });
    c.p.text(c.x + 30, c.y + 14, e.name, { size: 7, bold: true, color: INK });
    c.p.text(c.x + 30, c.y + 23, e.sub, { size: 6, color: MUT });
    c.p.rect(c.x + 8, c.y + 31, c.w - 16, 3.5, { fill: BAND });
    c.p.rect(c.x + 8, c.y + 31, (c.w - 16) * e.pct / 100, 3.5, { fill: ACC });
    c.y += h + 6;
  },

  chalcard: (c, e) => {
    const h = 46;
    c.p.roundRect(c.x, c.y, c.w, h, 4, { stroke: LINE, lw: 0.5 });
    c.p.text(c.x + 7, c.y + 13, c.p.clip(e.title, 7, true, c.w - 14), { size: 7, bold: true, color: INK });
    c.p.text(c.x + 7, c.y + 23, c.p.clip(e.sub, 5.8, false, c.w - 14), { size: 5.8, color: MUT });
    c.p.text(c.x + 7, c.y + 32, e.meta, { size: 5.8, color: ACC });
    c.p.rect(c.x + 7, c.y + 36, c.w - 14, 3.5, { fill: BAND });
    c.p.rect(c.x + 7, c.y + 36, (c.w - 14) * e.pct / 100, 3.5, { fill: ACC });
    c.y += h + 6;
  },

  chatrow: (c, e) => {
    const h = 34;
    c.p.circle(c.x + 14, c.y + 15, 10, { fill: SOFT, stroke: LINE, lw: 0.4 });
    c.p.text(c.x + 30, c.y + 13, e.name, { size: 7, bold: true, color: INK });
    c.p.text(c.x + 30, c.y + 23, c.p.clip(e.msg, 6, false, c.w - 70), { size: 6, color: MUT });
    c.p.text(c.x + c.w, c.y + 12, e.time, { size: 5.5, color: MUT, align: 'right' });
    if (e.unread) {
      c.p.circle(c.x + c.w - 6, c.y + 22, 5.5, { fill: ACC });
      c.p.text(c.x + c.w - 6, c.y + 24, e.unread, { size: 5.5, bold: true, color: [1, 1, 1], align: 'center' });
    }
    c.p.line(c.x, c.y + h, c.x + c.w, c.y + h, { color: [0.9, 0.9, 0.92], lw: 0.4 });
    c.y += h + 4;
  },

  histrow: (c, e) => {
    const h = 30;
    c.p.circle(c.x + 12, c.y + 14, 8.5, { fill: SOFT, stroke: LINE, lw: 0.4 });
    c.p.text(c.x + 26, c.y + 12, e.name, { size: 6.8, bold: true, color: INK });
    c.p.text(c.x + 26, c.y + 21, c.p.clip(e.sub, 5.8, false, c.w - 60), { size: 5.8, color: MUT });
    c.p.text(c.x + c.w, c.y + 16, e.meta, { size: 6.5, bold: true, color: ACC, align: 'right' });
    c.p.line(c.x, c.y + h, c.x + c.w, c.y + h, { color: [0.9, 0.9, 0.92], lw: 0.4 });
    c.y += h + 4;
  },

  skillrow: (c, e) => {
    const h = 28;
    c.p.roundRect(c.x, c.y, c.w, h, 4, { stroke: LINE, lw: 0.5 });
    c.p.text(c.x + 8, c.y + 12, e.name, { size: 7, bold: true, color: INK });
    c.p.text(c.x + 8, c.y + 21, e.sub, { size: 5.8, color: MUT });
    c.p.text(c.x + c.w - 8, c.y + 17, '...', { size: 7, color: MUT, align: 'right' });
    c.y += h + 6;
  },

  passrow: (c, e) => {
    const h = 32;
    c.p.roundRect(c.x, c.y, c.w, h, 4, { stroke: LINE, lw: 0.5 });
    c.p.text(c.x + 8, c.y + 12, e.name, { size: 7, bold: true, color: INK });
    c.p.text(c.x + 8, c.y + 21, e.sub, { size: 5.8, color: MUT });
    c.p.rect(c.x + 8, c.y + 25, c.w - 16, 3, { fill: BAND });
    c.p.rect(c.x + 8, c.y + 25, (c.w - 16) * e.pct / 100, 3, { fill: ACC });
    c.y += h + 6;
  },

  notif: (c, e) => {
    const h = 28;
    if (e.unread) c.p.rect(c.x, c.y, 2.5, h, { fill: ACC });
    c.p.text(c.x + 8, c.y + 12, c.p.clip(e.title, 6.6, e.unread, c.w - 14), { size: 6.6, bold: e.unread, color: INK });
    c.p.text(c.x + 8, c.y + 21, e.sub, { size: 5.5, color: MUT });
    c.p.line(c.x, c.y + h, c.x + c.w, c.y + h, { color: [0.9, 0.9, 0.92], lw: 0.4 });
    c.y += h + 4;
  },

  bigavatar: (c, e) => {
    c.p.circle(c.x + c.w / 2, c.y + 20, 20, { fill: SOFT, stroke: LINE, lw: 0.6 });
    c.y += 46;
    c.p.text(c.x + c.w / 2, c.y, e.name, { size: 9, bold: true, align: 'center', color: INK });
    c.y += 11;
    c.p.text(c.x + c.w / 2, c.y, e.score, { size: 6.5, align: 'center', color: ACC });
    c.y += 12;
  },

  avatarpick: (c) => {
    c.p.circle(c.x + c.w / 2, c.y + 20, 20, { fill: SOFT, stroke: LINE, lw: 0.6 });
    c.y += 46;
    c.p.text(c.x + c.w / 2, c.y, 'Cambiar foto', { size: 6, align: 'center', color: ACC });
    c.y += 12;
  },

  minihead: (c, e) => {
    c.p.circle(c.x + 13, c.y + 13, 11, { fill: SOFT, stroke: LINE, lw: 0.4 });
    c.p.text(c.x + 29, c.y + 11, e.name, { size: 7.5, bold: true, color: INK });
    c.p.text(c.x + 29, c.y + 21, e.sub, { size: 6, color: MUT });
    if (e.score) c.p.text(c.x + c.w, c.y + 16, e.score, { size: 7, bold: true, color: ACC, align: 'right' });
    c.y += 32;
  },

  homehead: (c, e) => {
    c.p.circle(c.x + 11, c.y + 11, 10, { fill: SOFT, stroke: LINE, lw: 0.4 });
    c.p.text(c.x + 26, c.y + 9, 'Hola, ' + e.name, { size: 8, bold: true, color: INK });
    c.p.text(c.x + 26, c.y + 18, e.level, { size: 5.8, color: ACC });
    c.p.circle(c.x + c.w - 7, c.y + 10, 7, { stroke: LINE, lw: 0.5 });
    c.p.circle(c.x + c.w - 2, c.y + 5, 3, { fill: ACC });
    c.y += 26;
    c.p.text(c.x, c.y + 8, '¿Qué quieres aprender hoy?', { size: 9, bold: true, color: INK });
    c.y += 14;
  },

  chathead: (c, e) => {
    c.p.rect(c.x - PAD + BEZ, c.y, c.w + 2 * PAD - 2 * BEZ, 26, { fill: SOFT });
    c.p.text(c.x, c.y + 16, '<', { size: 8.5, bold: true, color: INK });
    c.p.circle(c.x + 20, c.y + 13, 8, { fill: [1, 1, 1], stroke: LINE, lw: 0.4 });
    c.p.text(c.x + 33, c.y + 11, e.name, { size: 7, bold: true, color: INK });
    c.p.text(c.x + 33, c.y + 20, e.sub, { size: 5.5, color: MUT });
    c.y += 30;
  },

  quick4: (c, e) => {
    const w = (c.w - 15) / 4;
    e.items.forEach((it, i) => {
      const bx = c.x + i * (w + 5);
      c.p.roundRect(bx, c.y, w, 34, 4, { fill: SOFT, stroke: LINE, lw: 0.4 });
      c.p.circle(bx + w / 2, c.y + 12, 5, { stroke: ACC, lw: 0.7 });
      c.p.text(bx + w / 2, c.y + 28, c.p.clip(it, 5.3, false, w - 2), { size: 5.3, align: 'center', color: INK });
    });
    c.y += 40;
  },

  stat3: (c, e) => {
    c.p.roundRect(c.x, c.y, c.w, 32, 4, { stroke: LINE, lw: 0.5 });
    const w = c.w / 3;
    e.items.forEach((it, i) => {
      c.p.text(c.x + w * i + w / 2, c.y + 15, it[0], { size: 9, bold: true, align: 'center', color: INK });
      c.p.text(c.x + w * i + w / 2, c.y + 25, it[1], { size: 5.3, align: 'center', color: MUT });
      if (i) c.p.line(c.x + w * i, c.y + 7, c.x + w * i, c.y + 25, { color: [0.9, 0.9, 0.92], lw: 0.4 });
    });
    c.y += 38;
  },

  badges: (c, e) => {
    const w = (c.w - 10) / 3;
    e.items.forEach((it, i) => {
      const bx = c.x + i * (w + 5);
      c.p.circle(bx + w / 2, c.y + 12, 11, { fill: ACC_SOFT, stroke: ACC, lw: 0.5 });
      c.p.text(bx + w / 2, c.y + 31, c.p.clip(it.replace('\n', ' '), 5.2, false, w), { size: 5.2, align: 'center', color: MUT });
    });
    c.y += 40;
  },

  row2: (c, e) => {
    c.p.text(c.x, c.y + 8, c.p.clip(e.l, 6.3, false, c.w - 55), { size: 6.3, color: MUT });
    c.p.text(c.x + c.w, c.y + 8, e.r, { size: 6.3, bold: true, color: INK, align: 'right' });
    c.p.line(c.x, c.y + 13, c.x + c.w, c.y + 13, { color: [0.92, 0.92, 0.94], lw: 0.4 });
    c.y += 17;
  },

  rowlink: (c, e) => {
    c.p.roundRect(c.x, c.y, c.w, 20, 3, { stroke: [0.9, 0.9, 0.92], lw: 0.4 });
    c.p.circle(c.x + 11, c.y + 10, 4.5, { stroke: ACC, lw: 0.6 });
    c.p.text(c.x + 21, c.y + 12.5, e.s, { size: 6.4, color: INK });
    c.p.text(c.x + c.w - 7, c.y + 13, '>', { size: 6.5, color: MUT, align: 'right' });
    c.y += 24;
  },

  reason: (c, e) => {
    c.p.circle(c.x + 4, c.y + 5, 3, { stroke: ACC, lw: 0.6 });
    c.p.text(c.x + 12, c.y + 7.5, e.s, { size: 6.3, color: INK });
    c.y += 12;
  },

  note: (c, e) => {
    c.y += 2;
    c.p.roundRect(c.x, c.y, c.w, 0, 0, {});
    const lines = c.p.wrap(e.s, 5.6, false, c.w - 12);
    c.p.roundRect(c.x, c.y, c.w, lines.length * 7.5 + 8, 3, { fill: SOFT });
    let yy = c.y + 9;
    for (const ln of lines) { c.p.text(c.x + 6, yy, ln, { size: 5.6, color: MUT }); yy += 7.5; }
    c.y += lines.length * 7.5 + 13;
  },

  progress: (c, e) => {
    if (e.label) c.p.text(c.x, c.y + 7, e.label, { size: 6.2, bold: true, color: MUT });
    const yy = c.y + (e.label ? 12 : 2);
    c.p.rect(c.x, yy, c.w, 4.5, { fill: BAND });
    c.p.rect(c.x, yy, c.w * e.pct / 100, 4.5, { fill: ACC });
    c.p.text(c.x, yy + 14, e.txt, { size: 5.8, color: MUT });
    c.y = yy + 20;
  },

  slider: (c, e) => {
    c.p.rect(c.x, c.y + 6, c.w, 3, { fill: BAND });
    c.p.rect(c.x, c.y + 6, c.w * 0.7, 3, { fill: ACC });
    c.p.circle(c.x + c.w * 0.7, c.y + 7.5, 5, { fill: ACC });
    c.p.text(c.x + c.w, c.y + 22, e.value, { size: 6, color: INK, align: 'right' });
    c.y += 27;
  },

  stars: (c, e) => {
    const s = 11;
    const total = e.n * s + (e.n - 1) * 4;
    let sx = c.x + (c.w - total) / 2;
    for (let i = 0; i < e.n; i++) {
      c.p.roundRect(sx, c.y, s, s, 2, i < 4 ? { fill: ACC } : { stroke: LINE, lw: 0.6 });
      sx += s + 4;
    }
    c.y += s + 8;
  },

  rating: (c, e) => {
    c.p.text(c.x, c.y + 8, e.label, { size: 6.2, color: MUT });
    let sx = c.x + c.w - 5 * 9 - 4 * 3;
    for (let i = 0; i < 5; i++) {
      c.p.roundRect(sx, c.y + 2, 9, 9, 2, i < 4 ? { fill: ACC } : { stroke: LINE, lw: 0.5 });
      sx += 12;
    }
    c.y += 17;
  },

  check: (c, e) => {
    c.p.roundRect(c.x, c.y + 1, 9, 9, 2, { fill: ACC });
    c.p.text(c.x + 14, c.y + 8.5, e.s, { size: 6.3, color: INK });
    c.y += 16;
  },

  img: (c, e) => {
    c.p.roundRect(c.x, c.y, c.w, e.h, 4, { fill: SOFT, stroke: LINE, lw: 0.4 });
    c.p.line(c.x, c.y, c.x + c.w, c.y + e.h, { color: [0.88, 0.88, 0.9], lw: 0.4 });
    c.p.line(c.x + c.w, c.y, c.x, c.y + e.h, { color: [0.88, 0.88, 0.9], lw: 0.4 });
    c.p.text(c.x + c.w / 2, c.y + e.h / 2 + 2, e.label, { size: 6, align: 'center', color: MUT });
    c.y += e.h + 6;
  },

  dots: (c, e) => {
    const total = e.n * 6 + (e.n - 1) * 5;
    let dx = c.x + (c.w - total) / 2;
    for (let i = 0; i < e.n; i++) {
      c.p.circle(dx + 3, c.y + 3, 3, i === e.active ? { fill: ACC } : { fill: BAND });
      dx += 11;
    }
    c.y += 12;
  },

  sheettop: (c) => {
    c.p.rect(c.x - PAD + BEZ, c.y, c.w + 2 * PAD - 2 * BEZ, 1, { fill: LINE });
    c.p.roundRect(c.x + c.w / 2 - 14, c.y + 5, 28, 3, 1.5, { fill: BAND });
    c.y += 14;
  },

  msgsys: (c, e) => {
    const w = c.p.width(e.s, 5.5, false) + 12;
    c.p.roundRect(c.x + (c.w - w) / 2, c.y, w, 13, 6.5, { fill: SOFT });
    c.p.text(c.x + c.w / 2, c.y + 9, e.s, { size: 5.5, align: 'center', color: MUT });
    c.y += 19;
  },

  msg: (c, e) => {
    const maxW = c.w * 0.74;
    const lines = c.p.wrap(e.s, 6.2, false, maxW - 14);
    let bw = 0;
    for (const ln of lines) bw = Math.max(bw, c.p.width(ln, 6.2, false));
    bw += 14;
    const h = lines.length * 8.5 + 9;
    const out = e.side === 'out';
    const bx = out ? c.x + c.w - bw : c.x;
    c.p.roundRect(bx, c.y, bw, h, 5, out ? { fill: ACC } : { fill: SOFT, stroke: LINE, lw: 0.4 });
    let yy = c.y + 10;
    for (const ln of lines) {
      c.p.text(bx + 7, yy, ln, { size: 6.2, color: out ? [1, 1, 1] : INK });
      yy += 8.5;
    }
    c.y += h + 6;
  },

  inputbar: (c, e) => {
    const yy = c.bottom - 24;
    c.p.roundRect(c.x, yy, c.w - 26, 20, 10, { fill: [1, 1, 1], stroke: LINE, lw: 0.5 });
    c.p.text(c.x + 8, yy + 13, e.ph, { size: 6, color: MUT });
    c.p.circle(c.x + c.w - 10, yy + 10, 10, { fill: ACC });
    c.p.text(c.x + c.w - 10, yy + 13, '>', { size: 7, bold: true, color: [1, 1, 1], align: 'center' });
  },

  fab: (c, e) => {
    const w = c.p.width(e.label, 6.3, true) + 26;
    const yy = c.bottom - 26;
    c.p.roundRect(c.x + c.w - w, yy, w, 20, 10, { fill: ACC });
    c.p.text(c.x + c.w - w + 10, yy + 13.5, '+', { size: 8, bold: true, color: [1, 1, 1] });
    c.p.text(c.x + c.w - w / 2 + 5, yy + 13.5, e.label, { size: 6.3, bold: true, color: [1, 1, 1], align: 'center' });
  },

  nav: (c, e) => {
    const items = ['Inicio', 'Explorar', 'Interc.', 'Chats', 'Perfil'];
    const h = 26;
    const yy = c.bottom - h;
    c.p.rect(c.x - PAD + BEZ, yy, c.w + 2 * PAD - 2 * BEZ, h, { fill: SOFT });
    c.p.line(c.x - PAD + BEZ, yy, c.x + c.w + PAD - BEZ, yy, { color: LINE, lw: 0.4 });
    const w = c.w / 5;
    items.forEach((it, i) => {
      const act = i === e.active;
      c.p.circle(c.x + w * i + w / 2, yy + 9, 4, { stroke: act ? ACC : MUT, lw: 0.6 });
      c.p.text(c.x + w * i + w / 2, yy + 22, it, { size: 5, align: 'center', color: act ? ACC : MUT, bold: act });
    });
  }
};

// ------------------------------------------------------------------ páginas ---
const doc = new Doc();
const PAGE_W = 842, PAGE_H = 595;

function pageFrame(p, title, sub, pageNo, total) {
  p.text(40, 34, title, { size: 13, bold: true, color: INK });
  if (sub) p.text(40, 47, sub, { size: 7.5, color: MUT });
  p.line(40, 54, PAGE_W - 40, 54, { color: LINE, lw: 0.7 });
  p.text(40, PAGE_H - 24, 'SkillSwap - Wireframes del aplicativo móvil  |  Desarrollo de Aplicaciones Móviles - UPN  |  2026-2',
    { size: 6.5, color: MUT });
  p.text(PAGE_W - 40, PAGE_H - 24, `${pageNo} / ${total}`, { size: 6.5, color: MUT, align: 'right' });
}

const PER_PAGE = 3;
const wirePages = Math.ceil(SCREENS.length / PER_PAGE);
const TOTAL = wirePages + 2;

// --- Portada ---
const cover = doc.addPage(PAGE_W, PAGE_H);
cover.rect(0, 0, PAGE_W, 8, { fill: ACC });
cover.text(PAGE_W / 2, 150, 'SkillSwap', { size: 40, bold: true, align: 'center', color: INK });
cover.text(PAGE_W / 2, 175, 'Intercambia habilidades, no dinero', { size: 12, align: 'center', color: ACC });
cover.line(PAGE_W / 2 - 150, 200, PAGE_W / 2 + 150, 200, { color: LINE, lw: 0.7 });
cover.text(PAGE_W / 2, 228, 'WIREFRAMES DEL APLICATIVO MOVIL', { size: 15, bold: true, align: 'center', color: INK });
cover.text(PAGE_W / 2, 248, '30 pantallas - Android nativo (Java 11 + XML + Material Design 3)', { size: 9, align: 'center', color: MUT });

const meta = [
  ['Curso', 'Desarrollo de Aplicaciones Móviles'],
  ['Carrera', 'Ingeniería de Sistemas Computacionales - UPN'],
  ['Proyecto', 'SkillSwap: aplicativo móvil para el intercambio de habilidades entre estudiantes universitarios'],
  ['Periodo', '2026-2'],
  ['Integrantes', 'Lagos Sedano, José Alfredo  -  Ricra Boza, César Andrés'],
  ['', 'Leguía Medina, Marcelo Zacarías  -  Decurt Bendezú, Dennis Fabián']
];
let my = 300;
for (const [k, v] of meta) {
  if (k) cover.text(230, my, k, { size: 8.5, bold: true, color: MUT });
  cover.text(310, my, v, { size: 8.5, color: INK });
  my += 16;
}
cover.text(PAGE_W / 2, 470, 'Los wireframes corresponden uno a uno con los layouts XML implementados en app/src/main/res/layout.',
  { size: 7.5, align: 'center', color: MUT });
cover.text(PAGE_W - 40, PAGE_H - 24, `1 / ${TOTAL}`, { size: 6.5, color: MUT, align: 'right' });

// --- Mapa de navegación ---
const map = doc.addPage(PAGE_W, PAGE_H);
pageFrame(map, 'Mapa de navegación', 'Flujo principal entre pantallas. Cada bloque referencia el código de wireframe.', 2, TOTAL);

function flowBox(p, x, y, w, h, code, label, accent) {
  p.roundRect(x, y, w, h, 4, accent ? { fill: ACC_SOFT, stroke: ACC, lw: 0.7 } : { stroke: LINE, fill: [1, 1, 1], lw: 0.6 });
  p.text(x + w / 2, y + 13, code, { size: 6.5, bold: true, align: 'center', color: accent ? ACC : MUT });
  const lines = p.wrap(label, 6.8, false, w - 8);
  let yy = y + 24;
  for (const ln of lines.slice(0, 2)) { p.text(x + w / 2, yy, ln, { size: 6.8, align: 'center', color: INK }); yy += 8.5; }
}

function arrow(p, x1, y1, x2, y2) {
  p.line(x1, y1, x2, y2, { color: MUT, lw: 0.7 });
  const a = Math.atan2(y2 - y1, x2 - x1), s = 4;
  p.line(x2, y2, x2 - s * Math.cos(a - 0.5), y2 - s * Math.sin(a - 0.5), { color: MUT, lw: 0.7 });
  p.line(x2, y2, x2 - s * Math.cos(a + 0.5), y2 - s * Math.sin(a + 0.5), { color: MUT, lw: 0.7 });
}

const BW = 96, BH = 42;
const rows = [
  { y: 88, label: 'Acceso', items: [['P01', 'Splash'], ['P02', 'Onboarding'], ['P03', 'Registro'], ['P04', 'Inicio de sesión'], ['P05', 'Recuperar contraseña']] },
  { y: 172, label: 'Descubrir', items: [['P06', 'Inicio'], ['P07', 'Explorar'], ['P08', 'Filtros'], ['P09', 'Detalle de coincidencia'], ['P10', 'Perfil del usuario']] },
  { y: 256, label: 'Acordar', items: [['P11', 'Enviar solicitud'], ['P12', 'Solicitudes'], ['P13', 'Mis intercambios'], ['P14', 'Detalle intercambio'], ['P15', 'Contrato']] },
  { y: 340, label: 'Ejecutar', items: [['P16', 'Chats'], ['P17', 'Chat individual'], ['P19', 'Validación aprendizaje'], ['P18', 'Calificar'], ['P30', 'Historial']] },
  { y: 424, label: 'Crecer', items: [['P20', 'Mi perfil'], ['P24', 'Pasaporte'], ['P25', 'SkillPoints'], ['P26', 'Skill Challenges'], ['P29', 'Notificaciones']] }
];
const X0 = 118, GAP = 38;
for (const r of rows) {
  map.text(46, r.y + 24, r.label, { size: 8, bold: true, color: ACC });
  r.items.forEach((it, i) => {
    const x = X0 + i * (BW + GAP);
    flowBox(map, x, r.y, BW, BH, it[0], it[1], i === 0);
    if (i < r.items.length - 1) arrow(map, x + BW + 3, r.y + BH / 2, x + BW + GAP - 3, r.y + BH / 2);
  });
}
for (let i = 0; i < rows.length - 1; i++) {
  arrow(map, X0 + 4 * (BW + GAP) + BW / 2, rows[i].y + BH + 3, X0 + BW / 2, rows[i + 1].y - 3);
}
map.text(46, 500, 'P21 Editar perfil, P22 Mis habilidades, P23 Catálogo de habilidades, P27 Detalle del reto y P28 Crear reto se abren desde P20 y P26.',
  { size: 7, color: MUT });
map.text(46, 514, 'El chat (P16/P17) solo existe después de aceptar una solicitud: se crea automáticamente junto con el intercambio.',
  { size: 7, color: MUT });

// --- Paginas de wireframes ---
for (let i = 0; i < SCREENS.length; i += PER_PAGE) {
  const group = SCREENS.slice(i, i + PER_PAGE);
  const p = doc.addPage(PAGE_W, PAGE_H);
  const n = doc.pages.length;
  pageFrame(p, 'Wireframes  ' + group[0].id + ' - ' + group[group.length - 1].id,
    'Pantallas implementadas en Android (Java + XML). Escala aproximada 1:2.', n, TOTAL);

  group.forEach((sc, k) => {
    const x = 40 + k * (PW + 41);
    const y = 72;
    drawPhone(p, x, y, sc);
    p.text(x, y + PH + 16, sc.id + '  ' + sc.name, { size: 8, bold: true, color: INK });
    p.text(x, y + PH + 27, sc.desc, { size: 6.3, color: MUT });
    p.text(x, y + PH + 37, p.clip(sc.file, 6, false, PW), { size: 6, color: ACC });
  });
}

const out = SVG ? 'C:/Users/ricra/AppData/Local/Temp/wf_preview.html' : 'C:/Users/ricra/Downloads/T1_Wireframes_SkillSwap.pdf';
fs.writeFileSync(out, doc.build());
console.log('OK ->', out, '|', doc.pages.length, 'páginas,', SCREENS.length, 'pantallas');
