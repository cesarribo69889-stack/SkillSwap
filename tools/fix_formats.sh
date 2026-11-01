#!/usr/bin/env bash
# Repara los especificadores de formato (%1$d / %1$s) que perl se comió.
set -e
S="$(cd "$(dirname "$0")/.." && pwd)/app/src/main/res/values/strings.xml"

# f <nombre> <contenido correcto>
f() {
  python_free_replace "$1" "$2"
}

python_free_replace() {
  local name="$1"; local body="$2"
  awk -v n="$name" -v b="$body" '
    {
      pat = "<string name=\"" n "\">"
      if (index($0, pat) > 0) {
        match($0, /^[ \t]*/)
        indent = substr($0, 1, RLENGTH)
        print indent "<string name=\"" n "\">" b "</string>"
        next
      }
      print
    }' "$S" > "$S.tmp" && mv "$S.tmp" "$S"
}

f fmt_exchanges_count     '%1$d intercambios'
f fmt_percent             '%1$d %%'
f fmt_percent_completed   '%1$d %% completado'
f fmt_progress_advance    'Avance: %1$d %%'
f fmt_session_of          'Sesión %1$d de %2$d'
f fmt_participants_of     '%1$d de %2$d participantes'
f fmt_modality            'Modalidad: %1$s'
f fmt_start_date          'Inicio: %1$s'
f fmt_taught_you          'Te enseñó %1$s'
f fmt_contributes         'Aporta %1$s'
f fmt_teaches             'Enseña %1$s'
f fmt_searches            'Busca %1$s'
f fmt_points_level        '%1$d SkillPoints · %2$s'
f fmt_contract_active     'Acuerdo activo · %1$d sesiones de %2$d min'
f fmt_role_category       '%1$s · %2$s'
f fmt_you_said            'Tú: %1$s'
f fmt_points_delta        '%1$s%2$d'
f fmt_compatible_students '%1$d estudiantes compatibles'
f fmt_compatible_student  '%1$d estudiante compatible'
f fmt_min_compatibility   '%1$d %% o más'
f fmt_deadline_participants '%1$s · %2$d/%3$d participantes'
f st_accepted_suffix      '%1$s · aceptó'
f st_pending_suffix       '%1$s · pendiente'
f fmt_challenge_objective 'Aprender %1$s y enseñar %2$s'

echo "Formatos reparados."
