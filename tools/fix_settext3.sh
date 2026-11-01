#!/usr/bin/env bash
# Sustituye las concatenaciones de setText() en las vistas.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
V="$ROOT/app/src/main/java/com/skillswap/view"
S="$ROOT/app/src/main/res/values/strings.xml"

# ---------------------------------------------------------------- strings
NEW=$(cat <<'XEOF'

    <!-- ====== Descripciones de estados vacíos ====== -->
    <string name="empty_desc_explore">Agrega más habilidades a tu perfil o ajusta los filtros para encontrar estudiantes compatibles.</string>
    <string name="empty_desc_challenges">Crea el primero: define un objetivo, las habilidades que necesitas y arma tu equipo.</string>
    <string name="empty_desc_chats">El chat se habilita automáticamente cuando alguien acepta una solicitud de intercambio.</string>
    <string name="empty_desc_history">Aquí aparecerán los intercambios que completes, con lo que enseñaste y lo que aprendiste.</string>
    <string name="empty_desc_notifications">Aquí verás solicitudes, mensajes, matches e insignias.</string>
    <string name="empty_desc_exchanges_done">Cuando termines un intercambio aparecerá en esta lista.</string>
    <string name="empty_desc_exchanges_pending">Envía una solicitud desde Explorar para crear tu primer intercambio.</string>

    <!-- ====== Valores por defecto mostrados ====== -->
    <string name="st_schedule_pending">Horario por coordinar</string>
    <string name="st_modality_pending">por definir</string>
    <string name="st_availability_pending">Disponibilidad por definir</string>
    <string name="st_no_description">Este estudiante aún no escribió su descripción.</string>
    <string name="st_sessions_pending">Aún no acordaron la cantidad de sesiones</string>
    <string name="st_level_beginner">Principiante</string>
    <string name="st_skillmatch">SkillMatch</string>
    <string name="st_accepted_suffix">%1$s · aceptó</string>
    <string name="st_pending_suffix">%1$s · pendiente</string>
    <string name="fmt_challenge_objective">Aprender %1$s y enseñar %2$s</string>
    <string name="fmt_match_formula">El porcentaje se calcula con reglas reales sobre 100 puntos:\n\n• %1$d pts — coincidencia de habilidades en ambos sentidos\n• %2$d pts — nivel de quien enseña\n• %3$d pts — modalidad compatible\n• %4$d pts — horarios en común\n• %5$d pts — reputación del estudiante\n\nSi no hay habilidades complementarias el resultado es 0 %%.</string>
XEOF
)
perl -0pi -e "s|</resources>|$(printf '%s' "$NEW" | sed 's/[&|]/\\&/g')\n</resources>|" "$S"

p() { perl -0pi -e "$2" "$1"; }

# ============================================================ ExchangeDetail
p "$V/exchange/ExchangeDetailActivity.java" '
s{binding\.txtModality\.setText\("Modalidad: " \+ exchange\.getModality\(\)\);}
 {binding.txtModality.setText(getString(R.string.fmt_modality, exchange.getModality()));}s;
s{\? "Horario por coordinar" : exchange\.getSchedule\(\)\);}
 {? getString(R.string.st_schedule_pending) : exchange.getSchedule());}s;
s{binding\.txtDate\.setText\("Inicio: " \+ DateUtils\.formatDate\(exchange\.getStartDate\(\)\)\);}
 {binding.txtDate.setText(getString(R.string.fmt_start_date,\n                DateUtils.formatDate(exchange.getStartDate())));}s;
s{binding\.txtProgressValue\.setText\(exchange\.getProgress\(\) \+ " %"\);}
 {binding.txtProgressValue.setText(getString(R.string.fmt_percent, exchange.getProgress()));}s;
s{binding\.txtSessions\.setText\(exchange\.getSessionsTotal\(\) > 0\s*\n\s*\? "Sesión " \+ exchange\.getSessionsDone\(\) \+ " de " \+ exchange\.getSessionsTotal\(\)\s*\n\s*: "Aún no acordaron la cantidad de sesiones"\);}
 {binding.txtSessions.setText(exchange.getSessionsTotal() > 0\n                ? getString(R.string.fmt_session_of,\n                        exchange.getSessionsDone(), exchange.getSessionsTotal())\n                : getString(R.string.st_sessions_pending));}s;
s{binding\.txtContractStatus\.setText\("Acuerdo activo · "\s*\n\s*\+ contract\.getSessions\(\) \+ " sesiones de "\s*\n\s*\+ contract\.getSessionDuration\(\) \+ " min"\);}
 {binding.txtContractStatus.setText(getString(R.string.fmt_contract_active,\n                    contract.getSessions(), contract.getSessionDuration()));}s'

# ============================================================ ExploreFragment
p "$V/matches/ExploreFragment.java" '
s{binding\.txtCount\.setText\(count \+ \(count == 1\s*\n\s*\? " estudiante compatible" : " estudiantes compatibles"\)\);}
 {binding.txtCount.setText(getString(count == 1\n                                ? R.string.fmt_compatible_student\n                                : R.string.fmt_compatible_students, count));}s;
s{binding\.empty\.txtEmptyDesc\.setText\(\s*\n\s*"Agrega más habilidades a tu perfil o ajusta los filtros "\s*\n\s*\+ "para encontrar estudiantes compatibles\."\);}
 {binding.empty.txtEmptyDesc.setText(R.string.empty_desc_explore);}s;
s{active\.add\(new String\[\]\{"min", filter\.getMinCompatibility\(\) \+ " % o más"\}\);}
 {active.add(new String[]{"min",\n                    getString(R.string.fmt_min_compatibility, filter.getMinCompatibility())});}s'

# ============================================================ ContractActivity
p "$V/contracts/ContractActivity.java" '
s{binding\.tilObjective\.getEditText\(\)\.setText\(\s*\n\s*"Aprender " \+ ex\.getSkillILearn\(myUid\) \+ " y enseñar "\s*\n\s*\+ ex\.getSkillITeach\(myUid\)\);}
 {binding.tilObjective.getEditText().setText(getString(\n                    R.string.fmt_challenge_objective,\n                    ex.getSkillILearn(myUid), ex.getSkillITeach(myUid)));}s;
s{view\.setText\(name \+ \(accepted \? " · aceptó" : " · pendiente"\)\);}
 {view.setText(getString(accepted\n                ? R.string.st_accepted_suffix : R.string.st_pending_suffix, name));}s'

# ============================================================ ChallengeDetail
p "$V/challenges/ChallengeDetailActivity.java" '
s{binding\.txtDeadline\.setText\(DateUtils\.daysLeft\(c\.getDeadline\(\)\)\s*\n\s*\+ " · " \+ c\.getParticipantsCount\(\) \+ "/" \+ c\.getMaxParticipants\(\) \+ " participantes"\);}
 {binding.txtDeadline.setText(getString(R.string.fmt_deadline_participants,\n                DateUtils.daysLeft(c.getDeadline()),\n                c.getParticipantsCount(), c.getMaxParticipants()));}s;
s{binding\.txtProgress\.setText\("Avance: " \+ c\.getProgress\(\) \+ " %"\);}
 {binding.txtProgress.setText(getString(R.string.fmt_progress_advance, c.getProgress()));}s'

# ============================================================ estados vacíos
p "$V/challenges/ChallengesActivity.java" '
s{binding\.empty\.txtEmptyDesc\.setText\(\s*\n\s*"Crea el primero: define un objetivo, las habilidades que necesitas "\s*\n\s*\+ "y arma tu equipo\."\);}
 {binding.empty.txtEmptyDesc.setText(R.string.empty_desc_challenges);}s'

p "$V/chat/ChatsFragment.java" '
s{binding\.empty\.txtEmptyDesc\.setText\(\s*\n\s*"El chat se habilita automáticamente cuando alguien acepta "\s*\n\s*\+ "una solicitud de intercambio\."\);}
 {binding.empty.txtEmptyDesc.setText(R.string.empty_desc_chats);}s'

p "$V/ratings/HistoryActivity.java" '
s{binding\.empty\.txtEmptyDesc\.setText\(\s*\n\s*"Aquí aparecerán los intercambios que completes, "\s*\n\s*\+ "con lo que enseñaste y lo que aprendiste\."\);}
 {binding.empty.txtEmptyDesc.setText(R.string.empty_desc_history);}s'

p "$V/notifications/NotificationsActivity.java" '
s{binding\.empty\.txtEmptyDesc\.setText\(\s*\n\s*"Aquí verás solicitudes, mensajes, matches e insignias\."\);}
 {binding.empty.txtEmptyDesc.setText(R.string.empty_desc_notifications);}s'

p "$V/exchange/ExchangesFragment.java" '
s{binding\.empty\.txtEmptyDesc\.setText\(tabIndex == 2\s*\n\s*\? "Cuando termines un intercambio aparecerá en esta lista\."\s*\n\s*: "Envía una solicitud desde Explorar para crear tu primer intercambio\."\);}
 {binding.empty.txtEmptyDesc.setText(tabIndex == 2\n                ? R.string.empty_desc_exchanges_done\n                : R.string.empty_desc_exchanges_pending);}s'

# ============================================================ resto
p "$V/ratings/RateExchangeActivity.java" '
s{binding\.txtSkill\.setText\("Te enseñó " \+ exchange\.getSkillILearn\(myUid\)\);}
 {binding.txtSkill.setText(getString(R.string.fmt_taught_you,\n                exchange.getSkillILearn(myUid)));}s'

p "$V/profile/UserProfileActivity.java" '
s{\? "Este estudiante aún no escribió su descripción\."}
 {? getString(R.string.st_no_description)}s;
s{binding\.txtModality\.setText\("Modalidad: "\s*\n\s*\+ \(user\.getModality\(\) == null \|\| user\.getModality\(\)\.isEmpty\(\)\s*\n\s*\? "por definir" : user\.getModality\(\)\)\);}
 {binding.txtModality.setText(getString(R.string.fmt_modality,\n                user.getModality() == null || user.getModality().isEmpty()\n                        ? getString(R.string.st_modality_pending) : user.getModality()));}s;
s{\? "Disponibilidad por definir"}
 {? getString(R.string.st_availability_pending)}s'

p "$V/matches/MatchDetailActivity.java" '
s{setupToolbar\(binding\.toolbarInc\.toolbar, "SkillMatch"\);}
 {setupToolbar(binding.toolbarInc.toolbar, getString(R.string.st_skillmatch));}s;
s{binding\.txtFormula\.setText\(\s*\n\s*"El porcentaje se calcula con reglas reales sobre 100 puntos:\\n\\n"\s*\n(?:.*\n)*?\s*\+ "Si no hay habilidades complementarias el resultado es 0 %\."\);}
 {binding.txtFormula.setText(getString(R.string.fmt_match_formula,\n                SkillMatchEngine.W_SKILLS, SkillMatchEngine.W_LEVEL,\n                SkillMatchEngine.W_MODALITY, SkillMatchEngine.W_AVAILABILITY,\n                SkillMatchEngine.W_REPUTATION));}s'

p "$V/matches/FiltersSheet.java" '
s{binding\.txtMinValue\.setText\(\(\(int\) value\) \+ " %"\)\);}
 {binding.txtMinValue.setText(getString(R.string.fmt_percent, (int) value)));}s;
s{binding\.txtMinValue\.setText\(filter\.getMinCompatibility\(\) \+ " %"\);}
 {binding.txtMinValue.setText(getString(R.string.fmt_percent, filter.getMinCompatibility()));}s'

p "$V/home/HomeFragment.java" '
s{binding\.txtLevel\.setText\(user\.getSkillPoints\(\) \+ " SkillPoints · "\s*\n\s*\+ \(user\.getGamificationLevel\(\) == null \|\| user\.getGamificationLevel\(\)\.isEmpty\(\)\s*\n\s*\? "Principiante" : user\.getGamificationLevel\(\)\)\);}
 {binding.txtLevel.setText(getString(R.string.fmt_points_level,\n                        user.getSkillPoints(),\n                        user.getGamificationLevel() == null\n                                || user.getGamificationLevel().isEmpty()\n                                ? getString(R.string.st_level_beginner)\n                                : user.getGamificationLevel()));}s'

echo "Vistas listas."
