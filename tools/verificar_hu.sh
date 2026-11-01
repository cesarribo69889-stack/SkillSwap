#!/usr/bin/env bash
# Comprueba que cada historia de usuario del backlog tenga codigo que la soporte.
# Para cada HU busca una marca concreta (metodo, clase o campo) en el fuente.
set -u
J="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/java/com/skillswap"
OK=0; NO=0

# hu <id> <descripcion corta> <archivo-relativo> <patron-grep>
hu() {
  local id="$1" desc="$2" file="$3" pat="$4"
  if [ -f "$J/$file" ] && grep -qE "$pat" "$J/$file"; then
    OK=$((OK+1)); printf "  OK    %-6s %-46s %s\n" "$id" "$desc" "$file"
  else
    NO=$((NO+1)); printf "  FALTA %-6s %-46s %s  <-- %s\n" "$id" "$desc" "$file" "$pat"
  fi
}

echo "=============================================================="
echo " VERIFICACION DE LAS 48 HISTORIAS DE USUARIO"
echo "=============================================================="
echo ""
echo "-- Registro y acceso ----------------------------------------"
hu HU01 "Registrarse con correo y contrasena" repository/AuthRepository.java "createUserWithEmailAndPassword"
hu HU02 "Iniciar sesion" repository/AuthRepository.java "signInWithEmailAndPassword"
hu HU03 "Recuperar contrasena" repository/AuthRepository.java "sendPasswordResetEmail"
hu HU04 "Cerrar sesion" repository/AuthRepository.java "signOut\(\)"
hu HU05 "Onboarding al abrir por primera vez" view/auth/OnboardingActivity.java "setOnboardingDone"

echo ""
echo "-- Perfil y habilidades -------------------------------------"
hu HU06 "Perfil academico (uni/carrera/ciclo)" repository/UserRepository.java 'data.put\("cycle"'
hu HU07 "Foto de perfil" repository/UserRepository.java "embedPhoto|uploadPhoto"
hu HU08 "Descripcion personal" repository/UserRepository.java 'data.put\("description"'
hu HU09 "Modalidad presencial/virtual/ambas" repository/UserRepository.java 'data.put\("modality"'
hu HU10 "Bloques de disponibilidad" repository/UserRepository.java 'data.put\("availability"'
hu HU11 "Registrar habilidades que ensena" repository/SkillRepository.java "addSkill"
hu HU12 "Registrar habilidades que aprende" model/UserSkill.java "TYPE_LEARN"

echo ""
echo "-- Coincidencias (SkillMatch) -------------------------------"
hu HU13 "Lista de estudiantes compatibles" utils/SkillMatchEngine.java "public static List<MatchResult> rank"
hu HU14 "Porcentaje de compatibilidad" utils/SkillMatchEngine.java "setScore"
hu HU15 "Criterios del match explicados" utils/SkillMatchEngine.java "MatchReason"
hu HU16 "Buscar por nombre o habilidad" repository/MatchRepository.java "matchesQuery"
hu HU17 "Filtros categoria/nivel/modalidad/min" repository/MatchRepository.java "applyFilters"
hu HU18 "Perfil publico de otro estudiante" view/profile/UserProfileActivity.java "renderMatch"

echo ""
echo "-- Solicitudes de intercambio -------------------------------"
hu HU19 "Enviar solicitud" repository/ExchangeRequestRepository.java "public void send"
hu HU20 "Ver solicitudes recibidas" repository/ExchangeRequestRepository.java "listenReceived"
hu HU21 "Aceptar solicitud" repository/ExchangeRequestRepository.java "public void accept"
hu HU22 "Rechazar solicitud" repository/ExchangeRequestRepository.java "public void reject"
hu HU23 "Estado de solicitudes enviadas" repository/ExchangeRequestRepository.java "listenSent"

echo ""
echo "-- Intercambio y contrato -----------------------------------"
hu HU24 "Intercambios agrupados por estado" viewmodel/ExchangeViewModel.java "filterByStatus"
hu HU25 "Detalle del intercambio" view/exchange/ExchangeDetailActivity.java "observeDetail"
hu HU26 "Definir contrato de aprendizaje" repository/ContractRepository.java "public void save"
hu HU27 "Aceptar el contrato" repository/ContractRepository.java "public void accept"
hu HU28 "Progreso en sesiones" repository/ExchangeRepository.java "updateProgress"
hu HU29 "Completar cuando ambos confirman" repository/ExchangeRepository.java "markCompleted"
hu HU30 "Registrar evidencia y autoevaluacion" repository/EvidenceRepository.java "public void submit"

echo ""
echo "-- Comunicacion (chat) --------------------------------------"
hu HU31 "Chat se abre al aceptar la solicitud" repository/ExchangeRepository.java "createChat"
hu HU32 "Lista de chats con no leidos" adapter/ChatAdapter.java "getUnreadFor"
hu HU33 "Mensajes en tiempo real" repository/ChatRepository.java "listenMessages"
hu HU34 "Abrir intercambio desde el chat" view/chat/ChatActivity.java "btnExchange"

echo ""
echo "-- Calificacion y reputacion --------------------------------"
hu HU35 "Calificar al terminar" repository/RatingRepository.java "public void submit"
hu HU36 "Puntualidad/comunicacion/ensenanza" model/Rating.java "setPunctuality|setCommunication|setTeaching"
hu HU37 "Reputacion = promedio" repository/UserRepository.java "applyRating"
hu HU38 "Historial de intercambios cerrados" view/ratings/HistoryActivity.java "STATUS_COMPLETED"

echo ""
echo "-- Gamificacion y pasaporte ---------------------------------"
hu HU39 "Ganar SkillPoints" repository/GamificationRepository.java "public void award"
hu HU40 "Nivel y cuanto falta" utils/GamificationEngine.java "nextLevelThreshold"
hu HU41 "Desbloquear insignias" repository/GamificationRepository.java "unlockBadge"
hu HU42 "Pasaporte de habilidades" repository/PassportRepository.java "registerActivity"
hu HU43 "Historial de SkillPoints" repository/GamificationRepository.java "fetchHistory"

echo ""
echo "-- Skill Challenges -----------------------------------------"
hu HU44 "Ver retos abiertos" repository/ChallengeRepository.java "listenAll"
hu HU45 "Crear un reto con cupo" repository/ChallengeRepository.java "public void create"
hu HU46 "Aceptar o rechazar postulaciones" repository/ChallengeRepository.java "public void respond"

echo ""
echo "-- Notificaciones -------------------------------------------"
hu HU47 "Push de solicitudes y mensajes" notifications/SkillSwapMessagingService.java "onMessageReceived"
hu HU48 "Centro interno y marcar leidas" repository/NotificationRepository.java "markAllRead"

echo ""
echo "=============================================================="
printf " TOTAL:  %d implementadas   %d sin encontrar   (de 48)\n" "$OK" "$NO"
echo "=============================================================="
[ "$NO" -eq 0 ]
