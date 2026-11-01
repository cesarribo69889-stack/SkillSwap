// Datos del Product Backlog de SkillSwap.
// Cada historia esta trazada a la pantalla (wireframe) y al archivo Java/XML
// que la implementa en el repositorio.

const EPICS = [
  ['E01', 'Registro y acceso', 'Permitir que el estudiante cree su cuenta, entre a la aplicación y la abandone de forma segura.'],
  ['E02', 'Perfil y habilidades', 'Construir la identidad del estudiante y el inventario de habilidades que ofrece y busca.'],
  ['E03', 'Coincidencias (SkillMatch)', 'Descubrir estudiantes compatibles y explicar por qué lo son.'],
  ['E04', 'Solicitudes de intercambio', 'Proponer, aceptar o rechazar un intercambio concreto.'],
  ['E05', 'Intercambio y contrato', 'Acordar, ejecutar y cerrar el intercambio con evidencia del aprendizaje.'],
  ['E06', 'Comunicación (chat)', 'Coordinar las sesiones dentro de la aplicación, sin canales externos.'],
  ['E07', 'Calificación y reputación', 'Generar confianza verificable entre estudiantes que no se conocen.'],
  ['E08', 'Gamificación y pasaporte', 'Reconocer la actividad sostenida y dejar constancia del avance por habilidad.'],
  ['E09', 'Skill Challenges', 'Extender el intercambio uno a uno hacia retos colaborativos de equipo.'],
  ['E10', 'Notificaciones', 'Avisar al estudiante de lo que ocurre aunque no tenga la app abierta.']
];

const M = 'Debe tener', S = 'Debería tener', C = 'Podría tener';

const STORIES = [
  // ---------------------------------------------------------------- E01 ---
  { id: 'HU01', e: 'E01', pr: M, pt: 3, sp: 1, sc: 'P03',
    t: 'Como estudiante nuevo, quiero registrarme con mi correo electrónico y una contraseña para crear mi cuenta en SkillSwap.',
    f: 'RegisterActivity.java · activity_register.xml · AuthRepository',
    ac: ['Valida el formato del correo y exige una contraseña de al menos 6 caracteres con letras y números.',
         'Muestra un error legible si el correo ya está registrado.',
         'Al registrarse correctamente, la cuenta queda creada en Firebase Authentication y se abre la pantalla de perfil.'] },

  { id: 'HU02', e: 'E01', pr: M, pt: 2, sp: 1, sc: 'P04',
    t: 'Como estudiante registrado, quiero iniciar sesión con mi correo y contraseña para entrar a mi cuenta.',
    f: 'LoginActivity.java · activity_login.xml · AuthRepository',
    ac: ['Autentica contra Firebase Authentication.',
         'Muestra un mensaje claro si las credenciales son incorrectas, sin revelar cuál de los dos campos falló.',
         'Si la autenticación es correcta, abre la pantalla de Inicio.'] },

  { id: 'HU03', e: 'E01', pr: S, pt: 2, sp: 1, sc: 'P05',
    t: 'Como estudiante que olvidó su contraseña, quiero solicitar un enlace de recuperación para volver a entrar a mi cuenta.',
    f: 'ForgotPasswordActivity.java · activity_forgot_password.xml',
    ac: ['Envía el correo de restablecimiento mediante Firebase Authentication.',
         'Confirma en pantalla que el correo fue enviado.',
         'No revela si el correo existe o no en la base de datos.'] },

  { id: 'HU04', e: 'E01', pr: M, pt: 1, sp: 1, sc: 'P20',
    t: 'Como estudiante autenticado, quiero cerrar sesión desde mi perfil para proteger mi cuenta en un dispositivo compartido.',
    f: 'ProfileFragment.java · fragment_profile.xml',
    ac: ['Pide confirmación antes de cerrar la sesión.',
         'Limpia la sesión local y vuelve a la pantalla de inicio de sesión.',
         'Al volver a abrir la app ya no entra automáticamente.'] },

  { id: 'HU05', e: 'E01', pr: C, pt: 2, sp: 1, sc: 'P02',
    t: 'Como estudiante que abre la app por primera vez, quiero ver una introducción breve para entender cómo funciona el intercambio.',
    f: 'OnboardingActivity.java · activity_onboarding.xml · PrefsManager',
    ac: ['Muestra tres pantallas deslizables con indicador de posición.',
         'Permite omitir la introducción en cualquier momento.',
         'Solo aparece la primera vez; después se va directamente al inicio de sesión.'] },

  // ---------------------------------------------------------------- E02 ---
  { id: 'HU06', e: 'E02', pr: M, pt: 3, sp: 1, sc: 'P21',
    t: 'Como estudiante, quiero completar mi perfil académico (universidad, carrera y ciclo) para que otros sepan quién soy.',
    f: 'EditProfileActivity.java · activity_edit_profile.xml · UserRepository',
    ac: ['Los tres campos son obligatorios para marcar el perfil como completo.',
         'Los datos se guardan en el documento del usuario en Cloud Firestore.',
         'El perfil incompleto no aparece en los resultados de búsqueda de otros estudiantes.'] },

  { id: 'HU07', e: 'E02', pr: S, pt: 3, sp: 1, sc: 'P21',
    t: 'Como estudiante, quiero subir una foto de perfil para dar más confianza a quien me contacte.',
    f: 'EditProfileActivity.java · ImageLoader · Firebase Storage',
    ac: ['Permite elegir una imagen de la galería del dispositivo.',
         'Rechaza archivos que no sean imagen o que superen 5 MB.',
         'La imagen se guarda en Storage bajo el identificador del propio usuario y se muestra recortada en círculo.'] },

  { id: 'HU08', e: 'E02', pr: S, pt: 1, sp: 1, sc: 'P21',
    t: 'Como estudiante, quiero escribir una descripción breve sobre mí para presentarme ante los demás.',
    f: 'EditProfileActivity.java · Validators',
    ac: ['Acepta un máximo de 280 caracteres y muestra el contador restante.',
         'La descripción aparece en el perfil propio y en el perfil público.'] },

  { id: 'HU09', e: 'E02', pr: M, pt: 2, sp: 1, sc: 'P21',
    t: 'Como estudiante, quiero indicar si prefiero intercambiar de forma presencial, virtual o ambas para coordinar mejor.',
    f: 'EditProfileActivity.java · ChipFactory',
    ac: ['Solo se puede elegir una de las tres opciones.',
         'La modalidad elegida se usa como uno de los criterios del cálculo de compatibilidad.'] },

  { id: 'HU10', e: 'E02', pr: M, pt: 3, sp: 1, sc: 'P21',
    t: 'Como estudiante, quiero seleccionar mis bloques de disponibilidad horaria para que me emparejen con horarios compatibles.',
    f: 'EditProfileActivity.java · UserRepository',
    ac: ['Permite marcar varios bloques (día y franja) a la vez.',
         'Los bloques seleccionados se guardan como lista en el perfil.',
         'La coincidencia de bloques aporta hasta 13 puntos al porcentaje de compatibilidad.'] },

  { id: 'HU11', e: 'E02', pr: M, pt: 5, sp: 2, sc: 'P22, P23',
    t: 'Como estudiante, quiero registrar las habilidades que enseño indicando mi nivel de dominio para poder ofrecerlas.',
    f: 'MySkillsActivity.java · SkillCatalogActivity.java · AddSkillSheet.java · SkillCatalog',
    ac: ['Se elige la habilidad desde un catálogo organizado por categorías.',
         'Se indica el nivel Básico, Intermedio o Avanzado y, opcionalmente, una nota.',
         'La habilidad se puede editar o eliminar después.',
         'No se permite registrar dos veces la misma habilidad como enseñada.'] },

  { id: 'HU12', e: 'E02', pr: M, pt: 3, sp: 2, sc: 'P22, P23',
    t: 'Como estudiante, quiero registrar las habilidades que quiero aprender para recibir coincidencias pertinentes.',
    f: 'MySkillsActivity.java · SkillRepository',
    ac: ['Usa el mismo catálogo que las habilidades que se enseñan, en una pestaña distinta.',
         'Una habilidad no puede estar a la vez en la lista de enseñadas y en la de buscadas.',
         'Al guardar, se recalculan las coincidencias del estudiante.'] },

  // ---------------------------------------------------------------- E03 ---
  { id: 'HU13', e: 'E03', pr: M, pt: 5, sp: 2, sc: 'P07',
    t: 'Como estudiante, quiero ver una lista de estudiantes compatibles conmigo para elegir con quién intercambiar.',
    f: 'ExploreFragment.java · fragment_explore.xml · MatchRepository',
    ac: ['Solo aparecen estudiantes con perfil completo y con al menos una habilidad complementaria.',
         'La lista se ordena de mayor a menor compatibilidad.',
         'Si el estudiante no tiene habilidades registradas, se muestra un estado vacío que lo invita a agregarlas.'] },

  { id: 'HU14', e: 'E03', pr: M, pt: 8, sp: 2, sc: 'P07, P09',
    t: 'Como estudiante, quiero ver el porcentaje de compatibilidad de cada coincidencia para priorizar a quién contacto primero.',
    f: 'SkillMatchEngine.java · MatchRepository · SkillMatchEngineTest',
    ac: ['El porcentaje se calcula con un modelo ponderado sobre 100 puntos: habilidades 45, nivel 20, disponibilidad 13, modalidad 12 y reputación 10.',
         'Si no existe ninguna habilidad complementaria en ninguna dirección, el resultado es 0 % y no se ofrece el intercambio.',
         'El resultado es determinista: con las mismas entradas devuelve siempre el mismo valor (verificado por prueba unitaria).'] },

  { id: 'HU15', e: 'E03', pr: S, pt: 3, sp: 2, sc: 'P09',
    t: 'Como estudiante, quiero conocer los criterios por los que el sistema me considera compatible para confiar en el resultado.',
    f: 'MatchDetailActivity.java · activity_match_detail.xml',
    ac: ['Lista en texto cada razón concreta de la coincidencia (qué enseña cada uno, horarios y modalidad).',
         'Muestra la fórmula de ponderación utilizada dentro de la propia pantalla.'] },

  { id: 'HU16', e: 'E03', pr: S, pt: 3, sp: 2, sc: 'P07',
    t: 'Como estudiante, quiero buscar por nombre o por habilidad para encontrar a alguien concreto.',
    f: 'ExploreFragment.java · UserRepository',
    ac: ['La búsqueda cubre nombre, carrera, universidad y habilidades.',
         'No distingue mayúsculas, minúsculas ni tildes.',
         'Los resultados se actualizan mientras se escribe.'] },

  { id: 'HU17', e: 'E03', pr: S, pt: 5, sp: 2, sc: 'P08',
    t: 'Como estudiante, quiero filtrar por categoría, nivel, modalidad y compatibilidad mínima para acotar los resultados.',
    f: 'FiltersSheet.java · sheet_filters.xml',
    ac: ['Los filtros se aplican de forma combinada.',
         'Los filtros activos se muestran como etiquetas sobre la lista y se pueden quitar de una en una.',
         'El botón Limpiar restablece todos los filtros.'] },

  { id: 'HU18', e: 'E03', pr: M, pt: 3, sp: 2, sc: 'P10',
    t: 'Como estudiante, quiero ver el perfil público de otro estudiante con sus habilidades y reputación antes de contactarlo.',
    f: 'UserProfileActivity.java · activity_user_profile.xml',
    ac: ['Muestra habilidades ofrecidas y buscadas, reputación promedio y número de intercambios completados.',
         'Muestra las últimas calificaciones recibidas.',
         'No expone el correo electrónico ni ningún otro dato de contacto privado.'] },

  // ---------------------------------------------------------------- E04 ---
  { id: 'HU19', e: 'E04', pr: M, pt: 5, sp: 3, sc: 'P11',
    t: 'Como estudiante, quiero enviar una solicitud de intercambio indicando qué quiero aprender y qué ofrezco a cambio.',
    f: 'SendRequestActivity.java · ExchangeRequestRepository',
    ac: ['Obliga a elegir una habilidad a aprender y una a ofrecer.',
         'Permite adjuntar modalidad, horario propuesto y un mensaje.',
         'No se puede enviar una segunda solicitud al mismo estudiante mientras la anterior siga pendiente.'] },

  { id: 'HU20', e: 'E04', pr: M, pt: 3, sp: 3, sc: 'P12',
    t: 'Como estudiante, quiero ver las solicitudes que he recibido para decidir si las acepto.',
    f: 'RequestsActivity.java · activity_requests.xml',
    ac: ['Las solicitudes recibidas y enviadas se separan en dos pestañas.',
         'Cada solicitud muestra quién la envía, qué ofrece, qué busca y su estado.'] },

  { id: 'HU21', e: 'E04', pr: M, pt: 5, sp: 3, sc: 'P12',
    t: 'Como estudiante, quiero aceptar una solicitud para que el intercambio quede formalizado.',
    f: 'ExchangeRequestRepository · ExchangeRepository · ChatRepository',
    ac: ['Al aceptar se crea el intercambio y, automáticamente, el chat entre ambos.',
         'La solicitud cambia a estado ACEPTADA y ya no puede volver a responderse.',
         'El emisor recibe una notificación de que su solicitud fue aceptada.'] },

  { id: 'HU22', e: 'E04', pr: M, pt: 2, sp: 3, sc: 'P12',
    t: 'Como estudiante, quiero rechazar una solicitud que no me interesa para mantener ordenada mi bandeja.',
    f: 'RequestsActivity.java · ExchangeRequestRepository',
    ac: ['La solicitud pasa a estado RECHAZADA y desaparece de las pendientes.',
         'No se crea ni intercambio ni chat.',
         'El emisor puede volver a enviar una solicitud nueva más adelante.'] },

  { id: 'HU23', e: 'E04', pr: S, pt: 2, sp: 3, sc: 'P12',
    t: 'Como estudiante, quiero ver el estado de las solicitudes que envié para saber si ya fueron respondidas.',
    f: 'RequestsActivity.java · ExchangeRequestRepository',
    ac: ['Muestra los estados PENDIENTE, ACEPTADA, RECHAZADA y CANCELADA.',
         'Permite cancelar una solicitud propia mientras siga pendiente.'] },

  // ---------------------------------------------------------------- E05 ---
  { id: 'HU24', e: 'E05', pr: M, pt: 3, sp: 3, sc: 'P13',
    t: 'Como estudiante, quiero ver mis intercambios agrupados en próximos, en proceso y completados para organizarme.',
    f: 'ExchangesFragment.java · fragment_exchanges.xml',
    ac: ['Tres pestañas correspondientes a los tres estados.',
         'Cada tarjeta muestra con quién es el intercambio, las habilidades y el avance.',
         'La lista se actualiza sola cuando cambia el estado en Firestore.'] },

  { id: 'HU25', e: 'E05', pr: M, pt: 3, sp: 3, sc: 'P14',
    t: 'Como estudiante, quiero abrir el detalle de un intercambio para consultar todo lo acordado.',
    f: 'ExchangeDetailActivity.java · activity_exchange_detail.xml',
    ac: ['Muestra qué enseña cada parte, modalidad, horario y progreso.',
         'Da acceso directo al contrato, al chat y al registro de actividad.'] },

  { id: 'HU26', e: 'E05', pr: S, pt: 5, sp: 3, sc: 'P15',
    t: 'Como estudiante, quiero definir un contrato de aprendizaje con objetivo, sesiones, duración y actividad final antes de empezar.',
    f: 'ContractActivity.java · ContractRepository',
    ac: ['El número de sesiones se limita entre 1 y 20 y la duración entre 15 y 240 minutos.',
         'Cualquiera de los dos participantes puede redactar el borrador.',
         'El contrato queda vinculado a un único intercambio.'] },

  { id: 'HU27', e: 'E05', pr: S, pt: 3, sp: 3, sc: 'P15',
    t: 'Como estudiante, quiero aceptar el contrato de aprendizaje para que el intercambio pase a estar en proceso.',
    f: 'ContractActivity.java · firestore.rules',
    ac: ['Los dos participantes deben aceptar; con una sola aceptación el contrato queda pendiente.',
         'Las reglas de seguridad impiden que un participante acepte en nombre del otro.',
         'Cuando ambos aceptan, el intercambio cambia a EN_PROCESO.'] },

  { id: 'HU28', e: 'E05', pr: C, pt: 3, sp: 4, sc: 'P14',
    t: 'Como estudiante, quiero ver el progreso del intercambio en sesiones realizadas para saber cuánto falta.',
    f: 'ExchangeRepository · ExchangeDetailActivity.java',
    ac: ['Muestra sesiones realizadas sobre sesiones totales y un porcentaje de avance.',
         'El avance se actualiza al registrar cada sesión.'] },

  { id: 'HU29', e: 'E05', pr: M, pt: 5, sp: 3, sc: 'P14',
    t: 'Como estudiante, quiero marcar el intercambio como completado y que se cierre cuando ambos lo confirmemos.',
    f: 'ExchangeRepository · GamificationRepository · PassportRepository',
    ac: ['Mientras solo uno confirme, el intercambio muestra "esperando confirmación".',
         'Cuando ambos confirman, el intercambio pasa a COMPLETADO.',
         'El cierre otorga 20 SkillPoints a cada participante, actualiza el pasaporte y habilita la calificación.'] },

  { id: 'HU30', e: 'E05', pr: C, pt: 5, sp: 4, sc: 'P19',
    t: 'Como estudiante, quiero registrar qué practiqué, si cumplí el objetivo y una autoevaluación al cerrar el intercambio.',
    f: 'EvidenceActivity.java · EvidenceRepository',
    ac: ['Permite describir la actividad, marcar si se cumplió el objetivo y autoevaluarse de 1 a 5.',
         'Permite adjuntar una imagen opcional como evidencia.',
         'La pantalla advierte de forma visible que se trata de una autoevaluación entre pares y no de una certificación académica.'] },

  // ---------------------------------------------------------------- E06 ---
  { id: 'HU31', e: 'E06', pr: M, pt: 5, sp: 4, sc: 'P16, P17',
    t: 'Como estudiante, quiero que el chat se abra automáticamente al aceptarse la solicitud para coordinar sin salir de la app.',
    f: 'ChatRepository · ExchangeRepository',
    ac: ['El chat no existe antes de aceptar la solicitud.',
         'Se crea en la misma operación que el intercambio y queda vinculado a él.',
         'El primer mensaje del chat es un mensaje de sistema que indica que el intercambio fue aceptado.'] },

  { id: 'HU32', e: 'E06', pr: M, pt: 3, sp: 4, sc: 'P16',
    t: 'Como estudiante, quiero ver la lista de mis conversaciones con el último mensaje y los no leídos.',
    f: 'ChatsFragment.java · fragment_chats.xml',
    ac: ['Las conversaciones se ordenan por el mensaje más reciente.',
         'Se muestra un contador de mensajes no leídos por conversación.',
         'El contador se pone a cero al abrir el chat.'] },

  { id: 'HU33', e: 'E06', pr: M, pt: 5, sp: 4, sc: 'P17',
    t: 'Como estudiante, quiero enviar y recibir mensajes en tiempo real para acordar el día y la hora de la sesión.',
    f: 'ChatActivity.java · ChatRepository · firestore.rules',
    ac: ['Los mensajes nuevos aparecen sin necesidad de recargar la pantalla.',
         'Solo se aceptan mensajes de entre 1 y 2000 caracteres enviados por un participante del chat.',
         'Los mensajes no se pueden editar una vez enviados.'] },

  { id: 'HU34', e: 'E06', pr: C, pt: 2, sp: 4, sc: 'P17',
    t: 'Como estudiante, quiero abrir el intercambio desde el chat para consultar lo acordado sin perder la conversación.',
    f: 'ChatActivity.java · ExchangeDetailActivity.java',
    ac: ['Hay un acceso directo al intercambio en la cabecera del chat.',
         'Al volver, la conversación conserva la posición de lectura.'] },

  // ---------------------------------------------------------------- E07 ---
  { id: 'HU35', e: 'E07', pr: M, pt: 5, sp: 4, sc: 'P18',
    t: 'Como estudiante, quiero calificar a mi compañero al terminar el intercambio para dejar retroalimentación.',
    f: 'RateExchangeActivity.java · RatingRepository',
    ac: ['Solo se puede calificar un intercambio en el que se participó y que esté COMPLETADO.',
         'No es posible calificarse a uno mismo ni calificar dos veces el mismo intercambio.',
         'Las calificaciones son inmutables una vez enviadas.'] },

  { id: 'HU36', e: 'E07', pr: S, pt: 3, sp: 4, sc: 'P18',
    t: 'Como estudiante, quiero calificar puntualidad, comunicación y calidad de enseñanza por separado para ser más preciso.',
    f: 'RateExchangeActivity.java · activity_rate_exchange.xml',
    ac: ['Los tres criterios se puntúan de 1 a 5 estrellas de forma independiente.',
         'El comentario en texto es opcional.'] },

  { id: 'HU37', e: 'E07', pr: M, pt: 5, sp: 5, sc: 'P10, P20',
    t: 'Como estudiante, quiero que mi reputación se calcule con el promedio de las calificaciones recibidas para generar confianza.',
    f: 'RatingRepository · UserRepository · firestore.rules',
    ac: ['La reputación se recalcula en una transacción al recibir cada calificación.',
         'El usuario no puede modificar directamente su reputación ni su número de calificaciones.',
         'Un estudiante sin calificaciones no muestra reputación, no muestra cero.'] },

  { id: 'HU38', e: 'E07', pr: S, pt: 3, sp: 5, sc: 'P30',
    t: 'Como estudiante, quiero consultar el historial de mis intercambios cerrados y sus calificaciones.',
    f: 'HistoryActivity.java · activity_history.xml',
    ac: ['Lista los intercambios completados con lo enseñado, lo aprendido y la calificación obtenida.',
         'Muestra el total de intercambios y el promedio recibido.'] },

  // ---------------------------------------------------------------- E08 ---
  { id: 'HU39', e: 'E08', pr: C, pt: 5, sp: 5, sc: 'P25',
    t: 'Como estudiante, quiero ganar SkillPoints por completar intercambios y otras acciones para percibir mi progreso.',
    f: 'GamificationEngine.java · GamificationRepository · GamificationEngineTest',
    ac: ['Asigna puntos por intercambio completado, buena calificación, perfil completo, contrato aceptado, unirse a un reto y registrar evidencia.',
         'El saldo se refleja en el perfil del estudiante.',
         'La pantalla advierte que los SkillPoints no son dinero ni tienen valor monetario.'] },

  { id: 'HU40', e: 'E08', pr: C, pt: 3, sp: 5, sc: 'P25',
    t: 'Como estudiante, quiero ver mi nivel de gamificación y cuánto me falta para el siguiente.',
    f: 'GamificationEngine.java · SkillPointsActivity.java',
    ac: ['Define cuatro niveles: Principiante, Colaborador, Mentor y SkillMaster.',
         'Muestra una barra de avance y los puntos que faltan para el siguiente nivel.'] },

  { id: 'HU41', e: 'E08', pr: C, pt: 3, sp: 5, sc: 'P24',
    t: 'Como estudiante, quiero desbloquear insignias por mis logros dentro de la aplicación.',
    f: 'GamificationEngine.java · PassportActivity.java',
    ac: ['Existe un catálogo fijo de insignias con condición de desbloqueo conocida.',
         'Las insignias bloqueadas se muestran atenuadas, no ocultas.',
         'Al desbloquear una insignia se genera una notificación.'] },

  { id: 'HU42', e: 'E08', pr: C, pt: 5, sp: 5, sc: 'P24',
    t: 'Como estudiante, quiero consultar mi Pasaporte de Habilidades con el nivel alcanzado en cada habilidad.',
    f: 'PassportActivity.java · PassportRepository',
    ac: ['Registra una entrada por habilidad y rol (enseñada, aprendida o practicada).',
         'El nivel se deriva de la actividad real: menos de 2 intercambios Básico, de 2 a 4 Intermedio, 5 o más Avanzado.',
         'La pantalla advierte que el pasaporte no constituye una certificación académica ni un título oficial.'] },

  { id: 'HU43', e: 'E08', pr: C, pt: 2, sp: 5, sc: 'P25',
    t: 'Como estudiante, quiero ver el historial de movimientos de mis SkillPoints para entender cómo los conseguí.',
    f: 'GamificationRepository · item_point_entry.xml',
    ac: ['Cada movimiento indica el motivo, los puntos y la fecha.',
         'Los movimientos se ordenan del más reciente al más antiguo.'] },

  // ---------------------------------------------------------------- E09 ---
  { id: 'HU44', e: 'E09', pr: C, pt: 3, sp: 5, sc: 'P26',
    t: 'Como estudiante, quiero ver los retos colaborativos abiertos para unirme a un equipo.',
    f: 'ChallengesActivity.java · ChallengeRepository',
    ac: ['Cada reto muestra objetivo, habilidades requeridas, cupo, avance y días restantes.',
         'Los retos con el cupo lleno o vencidos no admiten nuevas postulaciones.'] },

  { id: 'HU45', e: 'E09', pr: C, pt: 5, sp: 5, sc: 'P28',
    t: 'Como estudiante, quiero crear un reto indicando las habilidades que necesito y el cupo del equipo.',
    f: 'CreateChallengeActivity.java · ChallengeRepository',
    ac: ['Exige título, objetivo, categoría, habilidades requeridas, cupo y fecha límite.',
         'El creador queda registrado como organizador del reto.'] },

  { id: 'HU46', e: 'E09', pr: C, pt: 3, sp: 5, sc: 'P27',
    t: 'Como creador de un reto, quiero aceptar o rechazar las postulaciones para armar el equipo.',
    f: 'ChallengeDetailActivity.java · firestore.rules',
    ac: ['El estudiante se postula indicando con qué habilidad aporta.',
         'Solo el creador puede aceptar o rechazar postulaciones.',
         'Al aceptar, el participante se suma al equipo y el contador de cupo se actualiza.'] },

  // ---------------------------------------------------------------- E10 ---
  { id: 'HU47', e: 'E10', pr: S, pt: 5, sp: 4, sc: 'P29',
    t: 'Como estudiante, quiero recibir notificaciones push de nuevas solicitudes, aceptaciones y mensajes aunque no tenga la app abierta.',
    f: 'SkillSwapMessagingService.java · NotificationHelper.java',
    ac: ['Usa Firebase Cloud Messaging con canales separados para mensajes y para el resto de avisos.',
         'Al tocar la notificación se abre directamente la pantalla relacionada.',
         'Si el estudiante no concede el permiso de notificaciones, la app sigue funcionando con el centro interno.'] },

  { id: 'HU48', e: 'E10', pr: S, pt: 3, sp: 5, sc: 'P29',
    t: 'Como estudiante, quiero un centro de notificaciones dentro de la app y poder marcarlas como leídas.',
    f: 'NotificationsActivity.java · NotificationRepository',
    ac: ['Agrupa solicitudes, coincidencias, mensajes, cierres, calificaciones, insignias y retos.',
         'Las no leídas se distinguen visualmente y existe la acción "marcar todas como leídas".',
         'El centro interno funciona aunque no esté configurado el envío push desde un servidor.'] }
];

const SPRINTS = [
  ['Sprint 1', 'Semanas 1-2', 'Acceso y perfil del estudiante',
   'Que un estudiante pueda crear su cuenta, entrar y dejar su perfil académico listo.'],
  ['Sprint 2', 'Semanas 3-4', 'Habilidades y motor de coincidencias',
   'Que el estudiante registre lo que enseña y lo que busca, y que el sistema calcule con quién es compatible.'],
  ['Sprint 3', 'Semanas 5-6', 'Solicitudes, intercambio y contrato',
   'Que dos estudiantes puedan pasar de una coincidencia a un intercambio acordado y cerrado.'],
  ['Sprint 4', 'Semanas 7-8', 'Chat, evidencia, calificación y push',
   'Que puedan coordinar dentro de la app, dejar evidencia del aprendizaje y calificarse.'],
  ['Sprint 5', 'Semanas 9-10', 'Reputación, gamificación y retos',
   'Que la actividad acumulada se traduzca en reputación, pasaporte, SkillPoints y retos de equipo.']
];

const WONT = [
  'Inicio de sesión con Google u otras redes sociales.',
  'Videollamada o llamada de voz integrada en el chat.',
  'Versión para iOS o versión web del aplicativo.',
  'Cualquier forma de pago, suscripción o monetización: el intercambio es siempre conocimiento por conocimiento.',
  'Modo sin conexión con sincronización diferida.',
  'Moderación automática del contenido de los mensajes.',
  'Emisión de certificados con validez académica.'
];

module.exports = { EPICS, STORIES, SPRINTS, WONT, M, S, C };
