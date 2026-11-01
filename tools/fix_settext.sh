#!/usr/bin/env bash
# Sustituye los setText() con literales y concatenaciones por recursos de texto.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
J="$ROOT/app/src/main/java/com/skillswap"
S="$ROOT/app/src/main/res/values/strings.xml"

# ---------------------------------------------------------------- 1. strings
NEW=$(cat <<'XEOF'

    <!-- ====== Textos usados desde código ====== -->
    <string name="st_already_joined">Ya participas</string>
    <string name="st_already_joined_long">Ya participas en este reto</string>
    <string name="st_you_are_organizer">Eres el organizador</string>
    <string name="st_team_full">Equipo completo</string>
    <string name="st_applications_closed">Postulaciones cerradas</string>
    <string name="st_they_offer">Te ofrece</string>
    <string name="st_you_offer">Le ofreces</string>
    <string name="st_they_want">Quiere aprender</string>
    <string name="st_you_want">Quieres aprender</string>
    <string name="st_waiting_confirmation">Esperando confirmación</string>
    <string name="st_contract_none">Aún no definido · toca para crearlo</string>
    <string name="st_contract_waiting_partner">Esperando la aceptación de tu compañero</string>
    <string name="st_contract_waiting_you">Pendiente de tu aceptación</string>
    <string name="st_no_complementary_skills">Sin habilidades complementarias</string>
    <string name="st_already_rated">Ya calificaste este intercambio</string>

    <!-- Estados vacíos (título) -->
    <string name="empty_title_challenges">Aún no hay retos</string>
    <string name="empty_title_chats">Sin conversaciones</string>
    <string name="empty_title_exchanges">Nada por aquí</string>
    <string name="empty_title_explore">Sin coincidencias</string>
    <string name="empty_title_notifications">Todo tranquilo</string>
    <string name="empty_title_history">Historial vacío</string>

    <!-- Formatos con datos -->
    <string name="fmt_exchanges_count">%1$d intercambios</string>
    <string name="fmt_percent">%1$d %%</string>
    <string name="fmt_percent_completed">%1$d %% completado</string>
    <string name="fmt_progress_advance">Avance: %1$d %%</string>
    <string name="fmt_session_of">Sesión %1$d de %2$d</string>
    <string name="fmt_participants_of">%1$d de %2$d participantes</string>
    <string name="fmt_modality">Modalidad: %1$s</string>
    <string name="fmt_start_date">Inicio: %1$s</string>
    <string name="fmt_taught_you">Te enseñó %1$s</string>
    <string name="fmt_contributes">Aporta %1$s</string>
    <string name="fmt_teaches">Enseña %1$s</string>
    <string name="fmt_searches">Busca %1$s</string>
    <string name="fmt_points_level">%1$d SkillPoints · %2$s</string>
    <string name="fmt_contract_active">Acuerdo activo · %1$d sesiones de %2$d min</string>
    <string name="fmt_role_category">%1$s · %2$s</string>
    <string name="fmt_you_said">Tú: %1$s</string>
    <string name="fmt_points_delta">%1$s%2$d</string>
    <string name="fmt_compatible_students">%1$d estudiantes compatibles</string>
    <string name="fmt_compatible_student">%1$d estudiante compatible</string>
    <string name="fmt_min_compatibility">%1$d %% o más</string>
    <string name="fmt_deadline_participants">%1$s · %2$d/%3$d participantes</string>
XEOF
)
perl -0pi -e "s|</resources>|$(printf '%s' "$NEW" | sed 's/[&|]/\\&/g')\n</resources>|" "$S"

# ---------------------------------------------------------------- 2. literales
# r <ruta-relativa> <literal> <recurso>
r() {
  local file="$J/$1"; shift
  perl -0pi -e "s|setText\(\"\Q$1\E\"\)|setText(R.string.$2)|g" "$file"
}

r adapter/ChallengeAdapter.java "Ya participas" st_already_joined
r adapter/RequestAdapter.java "Te ofrece" st_they_offer
r adapter/RequestAdapter.java "Quiere aprender" st_they_want
r adapter/RequestAdapter.java "Le ofreces" st_you_offer
r adapter/RequestAdapter.java "Quieres aprender" st_you_want
r view/challenges/ChallengeDetailActivity.java "Eres el organizador" st_you_are_organizer
r view/challenges/ChallengeDetailActivity.java "Ya participas en este reto" st_already_joined_long
r view/challenges/ChallengeDetailActivity.java "Equipo completo" st_team_full
r view/challenges/ChallengeDetailActivity.java "Postulaciones cerradas" st_applications_closed
r view/challenges/ChallengeDetailActivity.java "Quiero participar" lbl_join_challenge
r view/challenges/ChallengesActivity.java "Aún no hay retos" empty_title_challenges
r view/chat/ChatsFragment.java "Sin conversaciones" empty_title_chats
r view/exchange/ExchangeDetailActivity.java "Esperando confirmación" st_waiting_confirmation
r view/exchange/ExchangeDetailActivity.java "Aún no definido · toca para crearlo" st_contract_none
r view/exchange/ExchangeDetailActivity.java "Esperando la aceptación de tu compañero" st_contract_waiting_partner
r view/exchange/ExchangeDetailActivity.java "Pendiente de tu aceptación" st_contract_waiting_you
r view/exchange/ExchangesFragment.java "Nada por aquí" empty_title_exchanges
r view/home/HomeFragment.java "Solicitudes" lbl_requests
r view/matches/ExploreFragment.java "Sin coincidencias" empty_title_explore
r view/notifications/NotificationsActivity.java "Todo tranquilo" empty_title_notifications
r view/profile/UserProfileActivity.java "Sin habilidades complementarias" st_no_complementary_skills
r view/ratings/HistoryActivity.java "Historial vacío" empty_title_history
r view/ratings/RateExchangeActivity.java "Ya calificaste este intercambio" st_already_rated

echo "Literales sustituidos."
