#!/usr/bin/env bash
# Extrae los textos hardcodeados de los layouts a strings.xml
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
L="$ROOT/app/src/main/res/layout"
S="$ROOT/app/src/main/res/values/strings.xml"

# ---------------------------------------------------------------- 1. nuevos strings
NEW=$(cat <<'XEOF'

    <!-- ====== Extraídos de los layouts ====== -->
    <string name="lbl_about_me">Sobre mí</string>
    <string name="lbl_manage">Gestionar</string>
    <string name="lbl_reputation">Reputación</string>
    <string name="lbl_exchanges">Intercambios</string>
    <string name="lbl_requests">Solicitudes</string>
    <string name="lbl_chat">Chat</string>
    <string name="lbl_view_detail">Ver detalle</string>
    <string name="lbl_save">Guardar</string>
    <string name="lbl_description">Descripción</string>
    <string name="lbl_objective">Objetivo</string>
    <string name="lbl_progress">Progreso</string>
    <string name="lbl_details">Detalles</string>
    <string name="lbl_category">Categoría</string>
    <string name="lbl_skill">Habilidad</string>
    <string name="lbl_all_f">Todas</string>
    <string name="lbl_message">Mensaje</string>
    <string name="lbl_participants">Participantes</string>
    <string name="lbl_days">Días</string>
    <string name="lbl_sessions">Sesiones</string>
    <string name="lbl_minutes_per_session">Minutos por sesión</string>
    <string name="lbl_badges">Insignias</string>
    <string name="lbl_levels">Niveles</string>
    <string name="lbl_recent_activity">Movimientos recientes</string>
    <string name="lbl_min_compatibility">Compatibilidad mínima</string>
    <string name="lbl_you_teach">Tú enseñas</string>
    <string name="lbl_you_learn">Tú aprendes</string>
    <string name="lbl_taught_past">Enseñaste</string>
    <string name="lbl_learned_past">Aprendiste</string>
    <string name="lbl_taught_plural">Enseñadas</string>
    <string name="lbl_learned_plural">Aprendidas</string>
    <string name="lbl_offers">Ofrece</string>
    <string name="lbl_wants_to_learn">Quiere aprender</string>
    <string name="lbl_i_want_to_learn">Quiero aprender</string>
    <string name="lbl_i_can_teach">Puedo enseñar</string>
    <string name="lbl_i_teach">Enseño</string>
    <string name="lbl_skill_taught">Habilidad enseñada</string>
    <string name="lbl_skill_learned">Habilidad aprendida</string>
    <string name="lbl_the_exchange">El intercambio</string>
    <string name="lbl_needed">Se necesita</string>
    <string name="lbl_required_skills">Habilidades requeridas</string>
    <string name="lbl_skillpoints_total">SkillPoints acumulados</string>
    <string name="lbl_my_registered_skills">Mis habilidades registradas</string>
    <string name="lbl_ratings_received">Calificaciones recibidas</string>
    <string name="lbl_how_calculated">Cómo se calcula</string>
    <string name="lbl_why_compatible">¿Por qué son compatibles?</string>
    <string name="lbl_how_was_it">¿Cómo fue la experiencia?</string>
    <string name="lbl_agreement_acceptance">Aceptación del acuerdo</string>
    <string name="lbl_accept_agreement">Aceptar acuerdo</string>
    <string name="lbl_challenge_progress">Avance del reto</string>
    <string name="lbl_self_assessment">Autoevaluación</string>
    <string name="lbl_activity_done">Actividad realizada</string>
    <string name="lbl_final_activity">Actividad final</string>
    <string name="lbl_objective_exchange">Objetivo del intercambio</string>
    <string name="lbl_concrete_goal">Meta concreta</string>
    <string name="lbl_proposed_schedule">Horario propuesto</string>
    <string name="lbl_challenge_title">Título del reto</string>
    <string name="lbl_create_challenge">Crear reto</string>
    <string name="lbl_publish_challenge">Publicar reto</string>
    <string name="lbl_join_challenge">Quiero participar</string>
    <string name="lbl_send_rating">Enviar calificación</string>
    <string name="lbl_register_activity">Registrar actividad</string>
    <string name="lbl_register_session">Registrar sesión realizada</string>
    <string name="lbl_attach_evidence">Adjuntar evidencia (opcional)</string>
    <string name="lbl_note_optional">Nota (opcional)</string>
    <string name="lbl_notes_optional">Notas (opcional)</string>
    <string name="lbl_mark_all_read">Marcar todas como leídas</string>
    <string name="lbl_objective_met">Se cumplió el objetivo del contrato</string>

    <!-- Textos de ayuda -->
    <string name="hint_search_home">Busca una habilidad o estudiante</string>
    <string name="hint_write_message">Escribe un mensaje…</string>
    <string name="help_chat_enabled">El chat se habilita con cada intercambio aceptado</string>
    <string name="help_availability">Elige los bloques en los que puedes coordinar sesiones</string>
    <string name="help_skills_they_teach">Habilidades que este estudiante enseña</string>
    <string name="help_choose_offer">Elige lo que ofrecerás a cambio</string>
    <string name="help_team_skills">Selecciona los perfiles que necesitas en el equipo</string>
    <string name="help_contract_intro">Definan juntos el objetivo antes de iniciar</string>
    <string name="help_evidence_intro">Registra qué practicaste y qué lograste.</string>
    <string name="help_evidence_row">Registra la actividad que realizaste</string>
    <string name="help_challenges_intro">Únete a un equipo, aporta tu habilidad y construyan algo juntos.</string>

    <!-- Estados vacíos -->
    <string name="empty_no_matches">Agrega habilidades a tu perfil para descubrir estudiantes compatibles.</string>
    <string name="empty_no_exchanges">Todavía no tienes intercambios activos.</string>
    <string name="empty_no_ratings">Todavía no tiene calificaciones.</string>
    <string name="empty_no_passport">Tu pasaporte se llenará cuando completes intercambios.</string>
    <string name="empty_first_message">Escribe el primer mensaje y coordinen su intercambio.</string>

    <!-- Valores por defecto de formularios -->
    <string name="default_sessions">3</string>
    <string name="default_duration">60</string>
    <string name="default_participants">4</string>
    <string name="default_days">7</string>
XEOF
)
perl -0pi -e "s|</resources>|$(printf '%s' "$NEW" | sed 's/[&|]/\\&/g')\n</resources>|" "$S"

# ---------------------------------------------------------------- 2. reemplazos
# x <archivo> <literal> <recurso>
x() {
  local file="$L/$1"; shift
  local literal="$1"; shift
  local res="$1"
  [ -f "$file" ] || { echo "  ! falta $file"; return; }
  perl -0pi -e "s|android:text=\"\Q$literal\E\"|android:text=\"\@string/$res\"|g" "$file"
}

# borra el atributo android:text de valores que el codigo sobreescribe
del() {
  local file="$L/$1"; shift
  local literal="$1"
  [ -f "$file" ] || { echo "  ! falta $file"; return; }
  perl -0pi -e "s|\n\s*android:text=\"\Q$literal\E\"||g" "$file"
}

# ---- placeholders que el código sustituye en runtime ----
del item_match_home.xml "95 %"
del item_match_card.xml "95%"
del item_popular_skill.xml "Java"
del fragment_profile.xml "0.0"
del fragment_profile.xml "0"
del activity_user_profile.xml "0 % compatible"
del activity_passport.xml "0"
del activity_skill_points.xml "0"
del activity_skill_points.xml "Principiante"
del sheet_filters.xml "0 %"

# ---- perfil ----
x fragment_profile.xml "Sobre mí" lbl_about_me
x fragment_profile.xml "Gestionar" lbl_manage
x fragment_profile.xml "Reputación" lbl_reputation
x fragment_profile.xml "Intercambios" lbl_exchanges
x fragment_profile.xml "SkillPoints" skillpoints
x activity_user_profile.xml "Reputación" lbl_reputation
x activity_user_profile.xml "Intercambios" lbl_exchanges
x activity_user_profile.xml "Calificaciones recibidas" lbl_ratings_received
x activity_user_profile.xml "Todavía no tiene calificaciones." empty_no_ratings

# ---- home ----
x fragment_home.xml "Busca una habilidad o estudiante" hint_search_home
x fragment_home.xml "Agrega habilidades a tu perfil para descubrir estudiantes compatibles." empty_no_matches
x fragment_home.xml "Todavía no tienes intercambios activos." empty_no_exchanges

# ---- explorar / intercambios / chats ----
x fragment_exchanges.xml "Solicitudes" lbl_requests
x item_exchange.xml "Tú enseñas" lbl_you_teach
x item_exchange.xml "Tú aprendes" lbl_you_learn
x item_exchange.xml "Chat" lbl_chat
x item_exchange.xml "Ver detalle" lbl_view_detail
x fragment_chats.xml "El chat se habilita con cada intercambio aceptado" help_chat_enabled

# ---- edición de perfil / habilidades ----
x activity_edit_profile.xml "Elige los bloques en los que puedes coordinar sesiones" help_availability
x sheet_add_skill.xml "Categoría" lbl_category
x sheet_add_skill.xml "Habilidad" lbl_skill
x sheet_add_skill.xml "Nota (opcional)" lbl_note_optional

# ---- filtros ----
x sheet_filters.xml "Categoría" lbl_category
x sheet_filters.xml "Habilidad" lbl_skill
x sheet_filters.xml "Todas" lbl_all_f
x sheet_filters.xml "Compatibilidad mínima" lbl_min_compatibility

# ---- solicitudes ----
x item_request.xml "Ofrece" lbl_offers
x item_request.xml "Quiere aprender" lbl_wants_to_learn
x activity_send_request.xml "Quiero aprender" lbl_i_want_to_learn
x activity_send_request.xml "Puedo enseñar" lbl_i_can_teach
x activity_send_request.xml "Habilidades que este estudiante enseña" help_skills_they_teach
x activity_send_request.xml "Elige lo que ofrecerás a cambio" help_choose_offer
x activity_send_request.xml "Horario propuesto" lbl_proposed_schedule
x activity_send_request.xml "Mensaje" lbl_message

# ---- chat ----
x activity_chat.xml "Escribe un mensaje…" hint_write_message
x activity_chat.xml "Escribe el primer mensaje y coordinen su intercambio." empty_first_message

# ---- detalle de intercambio ----
x activity_exchange_detail.xml "El intercambio" lbl_the_exchange
x activity_exchange_detail.xml "Habilidad enseñada" lbl_skill_taught
x activity_exchange_detail.xml "Habilidad aprendida" lbl_skill_learned
x activity_exchange_detail.xml "Progreso" lbl_progress
x activity_exchange_detail.xml "Registrar sesión realizada" lbl_register_session
x activity_exchange_detail.xml "Chat" lbl_chat
x activity_exchange_detail.xml "Registra la actividad que realizaste" help_evidence_row

# ---- calificar / historial ----
x activity_rate_exchange.xml "¿Cómo fue la experiencia?" lbl_how_was_it
x activity_rate_exchange.xml "Detalles" lbl_details
x activity_rate_exchange.xml "Enviar calificación" lbl_send_rating
x item_history.xml "Enseñaste" lbl_taught_past
x item_history.xml "Aprendiste" lbl_learned_past

# ---- notificaciones ----
x activity_notifications.xml "Marcar todas como leídas" lbl_mark_all_read

# ---- pasaporte / skillpoints ----
x activity_passport.xml "Enseñadas" lbl_taught_plural
x activity_passport.xml "Aprendidas" lbl_learned_plural
x activity_passport.xml "Intercambios" lbl_exchanges
x activity_passport.xml "Insignias" lbl_badges
x activity_passport.xml "Mis habilidades registradas" lbl_my_registered_skills
x activity_passport.xml "Tu pasaporte se llenará cuando completes intercambios." empty_no_passport
x activity_skill_points.xml "SkillPoints acumulados" lbl_skillpoints_total
x activity_skill_points.xml "Niveles" lbl_levels
x activity_skill_points.xml "Movimientos recientes" lbl_recent_activity

# ---- contrato ----
x activity_contract.xml "Definan juntos el objetivo antes de iniciar" help_contract_intro
x activity_contract.xml "Objetivo del intercambio" lbl_objective_exchange
x activity_contract.xml "Sesiones" lbl_sessions
x activity_contract.xml "Minutos por sesión" lbl_minutes_per_session
x activity_contract.xml "Meta concreta" lbl_concrete_goal
x activity_contract.xml "Actividad final" lbl_final_activity
x activity_contract.xml "Aceptación del acuerdo" lbl_agreement_acceptance
x activity_contract.xml "Guardar" lbl_save
x activity_contract.xml "Aceptar acuerdo" lbl_accept_agreement
x activity_contract.xml "3" default_sessions
x activity_contract.xml "60" default_duration

# ---- retos ----
x activity_challenges.xml "Únete a un equipo, aporta tu habilidad y construyan algo juntos." help_challenges_intro
x activity_challenges.xml "Crear reto" lbl_create_challenge
x item_challenge.xml "Se necesita" lbl_needed
x item_challenge.xml "Quiero participar" lbl_join_challenge
x activity_challenge_detail.xml "Objetivo" lbl_objective
x activity_challenge_detail.xml "Descripción" lbl_description
x activity_challenge_detail.xml "Habilidades requeridas" lbl_required_skills
x activity_challenge_detail.xml "Participantes" lbl_participants
x activity_challenge_detail.xml "Avance del reto" lbl_challenge_progress
x activity_challenge_detail.xml "Quiero participar" lbl_join_challenge
x activity_create_challenge.xml "Título del reto" lbl_challenge_title
x activity_create_challenge.xml "Objetivo" lbl_objective
x activity_create_challenge.xml "Descripción" lbl_description
x activity_create_challenge.xml "Habilidades requeridas" lbl_required_skills
x activity_create_challenge.xml "Selecciona los perfiles que necesitas en el equipo" help_team_skills
x activity_create_challenge.xml "Participantes" lbl_participants
x activity_create_challenge.xml "Días" lbl_days
x activity_create_challenge.xml "Publicar reto" lbl_publish_challenge
x activity_create_challenge.xml "4" default_participants
x activity_create_challenge.xml "7" default_days

# ---- evidencia ----
x activity_evidence.xml "Registra qué practicaste y qué lograste." help_evidence_intro
x activity_evidence.xml "Actividad realizada" lbl_activity_done
x activity_evidence.xml "Se cumplió el objetivo del contrato" lbl_objective_met
x activity_evidence.xml "Autoevaluación" lbl_self_assessment
x activity_evidence.xml "Notas (opcional)" lbl_notes_optional
x activity_evidence.xml "Adjuntar evidencia (opcional)" lbl_attach_evidence
x activity_evidence.xml "Registrar actividad" lbl_register_activity

# ---- match ----
x activity_match_detail.xml "¿Por qué son compatibles?" lbl_why_compatible
x activity_match_detail.xml "Cómo se calcula" lbl_how_calculated

# ---- mis habilidades ----
x activity_my_skills.xml "Enseño" lbl_i_teach
x activity_my_skills.xml "Quiero aprender" lbl_i_want_to_learn

echo "Extracción completada."
