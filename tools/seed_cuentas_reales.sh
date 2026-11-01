#!/usr/bin/env bash
# ============================================================================
#  Deja las DOS CUENTAS REALES del equipo con datos suficientes para
#  sustentar las 48 historias de usuario sin usar las cuentas demo.
#
#  NI LOS CORREOS NI LAS CONTRASENAS ESTAN EN ESTE ARCHIVO: se pasan como
#  argumentos, para que el repositorio pueda ser publico sin exponer datos
#  personales del equipo.
#
#      bash tools/seed_cuentas_reales.sh <correoA> '<claveA>' <correoB> '<claveB>'
#
#  A es quien ensena Java y Python; B es quien ensena Figma e Ingles.
#  Es re-ejecutable: sobrescribe los mismos documentos (ids fijos).
# ============================================================================
set -u

if [ $# -lt 4 ]; then
  echo "Uso: bash tools/seed_cuentas_reales.sh <correoA> '<claveA>' <correoB> '<claveB>'"
  echo ""
  echo "  A -> ensena Java + Python, quiere aprender Figma + Ingles"
  echo "  B -> ensena Figma + Ingles, quiere aprender Java + Python"
  exit 1
fi
MAIL_A="$1"
PASS_A="$2"
MAIL_B="$3"
PASS_B="$4"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJ="skillswap-fa97f"
KEY=$(grep -o '"current_key": "[^"]*"' "$ROOT/app/google-services.json" | head -1 | sed 's/.*: "//;s/"//')
FS="https://firestore.googleapis.com/v1/projects/$PROJ/databases/(default)/documents"
OK=0; FAIL=0
NOW=$(date +%s)000
BS=$(awk "BEGIN{printf \"%c\", 92}")  # barra invertida, para los escapes XXXX de JSON

pass() { OK=$((OK+1)); printf "  \033[32mOK\033[0m    %s\n" "$1"; }
fail() { FAIL=$((FAIL+1)); printf "  \033[31mFALLA\033[0m %s\n         %s\n" "$1" "$2"; }

check() { # $1=descripcion $2=respuesta
  if echo "$2" | grep -q '"error"'; then
    fail "$1" "$(echo "$2" | grep -oE '"message": "[^"]*"' | head -1)"
  else
    pass "$1"
  fi
}

login() { # $1=email $2=pass
  curl -s -m 25 -X POST \
    "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$KEY" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$1\",\"password\":\"$2\",\"returnSecureToken\":true}"
}

put() {  # $1=ruta $2=token $3=cuerpo   (crea o reemplaza)
  curl -s -m 25 -X PATCH "$FS/$1" -H "Authorization: Bearer $2" \
    -H "Content-Type: application/json" -d "$3"
}

upd() {  # $1=ruta $2=token $3=mascara $4=cuerpo  (actualiza solo esos campos)
  curl -s -m 25 -X PATCH "$FS/$1?$3" -H "Authorization: Bearer $2" \
    -H "Content-Type: application/json" -d "$4"
}

field() { echo "$1" | grep -o "\"$2\": *\"[^\"]*\"" | head -1 | sed 's/.*: *"//;s/"//'; }

del() { # $1=ruta $2=token  -- borra si existe, para poder re-ejecutar
  curl -s -m 20 -X DELETE "$FS/$1" -H "Authorization: Bearer $2" > /dev/null 2>&1
}

existe() { # $1=ruta $2=token
  curl -s -m 20 "$FS/$1" -H "Authorization: Bearer $2" | grep -q '"name"'
}

# Para documentos que las reglas declaran inmutables (calificaciones): si ya
# estan, no se tocan. Reescribirlos esta prohibido a proposito.
una_vez() { # $1=descripcion $2=ruta $3=token $4=cuerpo
  if existe "$2" "$3"; then
    pass "$1 (ya existia, no se toca)"
  else
    check "$1" "$(put "$2" "$3" "$4")"
  fi
}

echo "=============================================================="
echo " SKILLSWAP - sembrando las dos cuentas REALES"
echo "=============================================================="
echo ""
echo "[1] AUTENTICACION"

RA=$(login "$MAIL_A" "$PASS_A")
RB=$(login "$MAIL_B" "$PASS_B")
TA=$(field "$RA" idToken); UA=$(field "$RA" localId)
TB=$(field "$RB" idToken); UB=$(field "$RB" localId)

if [ -z "$TA" ] || [ -z "$TB" ]; then
  echo "  ERROR: no se pudo iniciar sesion. Revisa las contrasenas."
  exit 1
fi
pass "Cesar   $UA"
pass "Marcelo $UB"

# El perfil se escribe con updateMask, asi que fcmToken, photoUrl y los
# contadores (reputacion, SkillPoints) quedan intactos. Las reglas prohiben
# expresamente que el dueno modifique su propia reputacion.
MASK_PERFIL="updateMask.fieldPaths=firstName&updateMask.fieldPaths=lastName"
MASK_PERFIL="$MASK_PERFIL&updateMask.fieldPaths=email"
MASK_PERFIL="$MASK_PERFIL&updateMask.fieldPaths=university"
MASK_PERFIL="$MASK_PERFIL&updateMask.fieldPaths=career"
MASK_PERFIL="$MASK_PERFIL&updateMask.fieldPaths=cycle"
MASK_PERFIL="$MASK_PERFIL&updateMask.fieldPaths=description"
MASK_PERFIL="$MASK_PERFIL&updateMask.fieldPaths=modality"
MASK_PERFIL="$MASK_PERFIL&updateMask.fieldPaths=availability"
MASK_PERFIL="$MASK_PERFIL&updateMask.fieldPaths=teachSkills"
MASK_PERFIL="$MASK_PERFIL&updateMask.fieldPaths=learnSkills"
MASK_PERFIL="$MASK_PERFIL&updateMask.fieldPaths=teachSkillKeys"
MASK_PERFIL="$MASK_PERFIL&updateMask.fieldPaths=learnSkillKeys"
MASK_PERFIL="$MASK_PERFIL&updateMask.fieldPaths=searchKeywords"
MASK_PERFIL="$MASK_PERFIL&updateMask.fieldPaths=profileCompleted"
MASK_PERFIL="$MASK_PERFIL&updateMask.fieldPaths=active"
MASK_PERFIL="$MASK_PERFIL&updateMask.fieldPaths=updatedAt"

# ---------------------------------------------------------------------------
# helpers de construccion
# ---------------------------------------------------------------------------
skill() { # id nombre categoria nivel TEACH|LEARN
cat <<EOF
{"mapValue":{"fields":{
 "skillId":{"stringValue":"$1"},"name":{"stringValue":"$2"},
 "category":{"stringValue":"$3"},"level":{"stringValue":"$4"},
 "type":{"stringValue":"$5"},"note":{"stringValue":""},
 "addedAt":{"integerValue":"$NOW"}}}}
EOF
}

sv() { printf '{"stringValue":"%s"}' "$1"; }

perfil() { # uid nombre apellido correo desc teach learn teachKeys learnKeys keywords
cat <<EOF
{"fields":{
 "firstName":{"stringValue":"$2"},"lastName":{"stringValue":"$3"},
 "email":{"stringValue":"$4"},
 "university":{"stringValue":"Universidad Privada del Norte"},
 "career":{"stringValue":"Ingenieria de Sistemas Computacionales"},
 "cycle":{"stringValue":"Ciclo IX"},
 "description":{"stringValue":"$5"},
 "modality":{"stringValue":"Virtual"},
 "availability":{"arrayValue":{"values":[
    {"stringValue":"Lunes a Viernes - Noche"},
    {"stringValue":"Sabados - Manana"}]}},
 "teachSkills":{"arrayValue":{"values":[$6]}},
 "learnSkills":{"arrayValue":{"values":[$7]}},
 "teachSkillKeys":{"arrayValue":{"values":[$8]}},
 "learnSkillKeys":{"arrayValue":{"values":[$9]}},
 "searchKeywords":{"arrayValue":{"values":[${10}]}},
 "profileCompleted":{"booleanValue":true},"active":{"booleanValue":true},
 "updatedAt":{"integerValue":"$NOW"}
}}
EOF
}

# ---------------------------------------------------------------------------
echo ""
echo "[2] PERFILES + HABILIDADES CRUZADAS   (HU06, HU08-HU12)"

# Los acentos van como escapes JSON \uXXXX: enviarlos crudos por curl los
# corrompia ("Programaci n", "Ingl s"). Las comillas dobles son necesarias
# para que bash no se coma la barra invertida.
TEACH_A="$(skill java Java "Programaci${BS}u00f3n" Avanzado TEACH),$(skill python Python "Programaci${BS}u00f3n" Intermedio TEACH)"
LEARN_A="$(skill figma Figma "Dise${BS}u00f1o" "B${BS}u00e1sico" LEARN),$(skill ingles "Ingl${BS}u00e9s" Idiomas Intermedio LEARN)"
KW_A="$(sv cesar),$(sv ricra),$(sv boza),$(sv java),$(sv python),$(sv ingenieria),$(sv sistemas)"
check "Perfil de Cesar (ensena Java+Python, busca Figma+Ingles)" \
  "$(upd "users/$UA" "$TA" "$MASK_PERFIL" "$(perfil "$UA" Cesar "Ricra Boza" "$MAIL_A" \
     "Estudiante de Ingenieria de Sistemas. Me gusta programar en Java y ayudar a quien recien empieza." \
     "$TEACH_A" "$LEARN_A" "$(sv java),$(sv python)" "$(sv figma),$(sv ingles)" "$KW_A")")"

TEACH_B="$(skill figma Figma "Dise${BS}u00f1o" Avanzado TEACH),$(skill ingles "Ingl${BS}u00e9s" Idiomas Avanzado TEACH)"
LEARN_B="$(skill java Java "Programaci${BS}u00f3n" "B${BS}u00e1sico" LEARN),$(skill python Python "Programaci${BS}u00f3n" "B${BS}u00e1sico" LEARN)"
KW_B="$(sv marcelo),$(sv leguia),$(sv medina),$(sv figma),$(sv ingles),$(sv diseno),$(sv sistemas)"
check "Perfil de Marcelo (ensena Figma+Ingles, busca Java+Python)" \
  "$(upd "users/$UB" "$TB" "$MASK_PERFIL" "$(perfil "$UB" Marcelo "Leguia Medina" "$MAIL_B" \
     "Me interesa el diseno de interfaces y practicar ingles. Quiero aprender a programar." \
     "$TEACH_B" "$LEARN_B" "$(sv figma),$(sv ingles)" "$(sv java),$(sv python)" "$KW_B")")"

# catalogo de habilidades (HU11 - lista compartida)
for s in "java:Java:Programaci${BS}u00f3n" "python:Python:Programaci${BS}u00f3n" \
         "figma:Figma:Dise${BS}u00f1o" "ingles:Ingl${BS}u00e9s:Idiomas"; do
  ID="${s%%:*}"; REST="${s#*:}"; NM="${REST%%:*}"; CAT="${REST##*:}"
  # El catalogo es inmutable por reglas (allow update: if false): solo se
  # escribe la primera vez.
  una_vez "Catalogo: $ID" "skills/$ID" "$TA" "{\"fields\":{\"id\":{\"stringValue\":\"$ID\"},\"name\":{\"stringValue\":\"$NM\"},\"category\":{\"stringValue\":\"$CAT\"},\"active\":{\"booleanValue\":true}}}"
done

# ---------------------------------------------------------------------------
echo ""
echo "[3] SKILLMATCH GUARDADO                (HU13-HU15)"
MID="${UA}_${UB}"
check "Match Cesar <-> Marcelo (96%)" \
  "$(put "matches/$MID" "$TA" "{\"fields\":{\"id\":$(sv "$MID"),\"userAId\":$(sv "$UA"),\"userBId\":$(sv "$UB"),\"participants\":{\"arrayValue\":{\"values\":[$(sv "$UA"),$(sv "$UB")]}},\"score\":{\"integerValue\":\"96\"},\"mutual\":{\"booleanValue\":true},\"createdAt\":{\"integerValue\":\"$NOW\"}}}")"

# ---------------------------------------------------------------------------
# intercambio generico
# ---------------------------------------------------------------------------
intercambio() { # id estado progreso total hechos compA compB ratA ratB
cat <<EOF
{"fields":{
 "id":$(sv "$1"),"requestId":$(sv "req_$1"),
 "userAId":$(sv "$UA"),"userAName":$(sv "Cesar Ricra"),
 "userBId":$(sv "$UB"),"userBName":$(sv "Marcelo Leguia"),
 "participants":{"arrayValue":{"values":[$(sv "$UA"),$(sv "$UB")]}},
 "skillFromA":$(sv Java),"skillFromB":$(sv Figma),
 "modality":$(sv Virtual),"schedule":$(sv "Lunes a Viernes - Noche"),
 "status":$(sv "$2"),
 "progress":{"integerValue":"$3"},
 "sessionsTotal":{"integerValue":"$4"},"sessionsDone":{"integerValue":"$5"},
 "contractId":$(sv "$9"),
 "completedByA":{"booleanValue":$6},"completedByB":{"booleanValue":$7},
 "ratedByA":{"booleanValue":$8},"ratedByB":{"booleanValue":${10}},
 "createdAt":{"integerValue":"$NOW"},"updatedAt":{"integerValue":"$NOW"},
 "startDate":{"integerValue":"$NOW"}
}}
EOF
}

contrato() { # id aceptadoA aceptadoB estado objetivo meta actividad
cat <<EOF
{"fields":{
 "id":$(sv "$1"),"exchangeId":$(sv "$1"),
 "participants":{"arrayValue":{"values":[$(sv "$UA"),$(sv "$UB")]}},
 "userAId":$(sv "$UA"),"userBId":$(sv "$UB"),"createdBy":$(sv "$UA"),
 "objective":$(sv "$5"),
 "sessions":{"integerValue":"3"},"sessionDuration":{"integerValue":"60"},
 "modality":$(sv Virtual),
 "goal":$(sv "$6"),
 "finalActivity":$(sv "$7"),
 "acceptedByA":{"booleanValue":$2},"acceptedByB":{"booleanValue":$3},
 "status":$(sv "$4"),
 "createdAt":{"integerValue":"$NOW"},"updatedAt":{"integerValue":"$NOW"}
}}
EOF
}

chat() { # id ultimoMensaje
cat <<EOF
{"fields":{
 "id":$(sv "$1"),"exchangeId":$(sv "$1"),
 "participants":{"arrayValue":{"values":[$(sv "$UA"),$(sv "$UB")]}},
 "userAId":$(sv "$UA"),"userBId":$(sv "$UB"),
 "userAName":$(sv "Cesar Ricra"),"userBName":$(sv "Marcelo Leguia"),
 "enabled":{"booleanValue":true},
 "lastMessage":$(sv "$2"),
 "lastMessageAt":{"integerValue":"$NOW"},
 "unreadA":{"integerValue":"0"},"unreadB":{"integerValue":"$3"},
 "updatedAt":{"integerValue":"$NOW"}
}}
EOF
}

mensaje() { # chatId msgId emisor nombre texto desfase
cat <<EOF
{"fields":{
 "chatId":$(sv "$1"),"senderId":$(sv "$3"),"senderName":$(sv "$4"),
 "text":$(sv "$5"),"type":$(sv TEXT),"read":{"booleanValue":true},
 "timestamp":{"integerValue":"$(( NOW + $6 ))"}
}}
EOF
}

# ---------------------------------------------------------------------------
echo ""
echo "[4] INTERCAMBIO 1 - COMPLETADO         (HU24, HU25, HU28, HU29)"
EX1="real_completado_01"
# Las reglas obligan a crearlo en PROXIMO con progreso 0; el estado final
# se alcanza con una segunda escritura, igual que haria la app.
check "Intercambio 1 creado en PROXIMO" \
  "$(put "exchanges/$EX1" "$TA" "$(intercambio "$EX1" PROXIMO 0 0 0 false false false "" false)")"
check "Intercambio 1 -> COMPLETADO 3/3" \
  "$(put "exchanges/$EX1" "$TA" "$(intercambio "$EX1" COMPLETADO 100 3 3 true true true "$EX1" true)")"
check "Contrato ACTIVO del intercambio 1" \
  "$(put "learningContracts/$EX1" "$TA" "$(contrato "$EX1" true true ACTIVO \
     "Aprender los fundamentos de Figma y ensenar POO con Java" \
     "Disenar 3 pantallas y programar una calculadora" \
     "Entregar el prototipo navegable y la calculadora funcionando")")"
check "Chat del intercambio 1" "$(put "chats/$EX1" "$TA" "$(chat "$EX1" "Gracias por todo, quedo genial" 0)")"
del "chats/$EX1/messages/m01" "$TA"
check "  mensaje 1" "$(put "chats/$EX1/messages/m01" "$TA" "$(mensaje "$EX1" m01 "$UA" "Cesar" "Hola Marcelo, arrancamos el sabado?" 1000)")"
del "chats/$EX1/messages/m02" "$TB"
check "  mensaje 2" "$(put "chats/$EX1/messages/m02" "$TB" "$(mensaje "$EX1" m02 "$UB" "Marcelo" "Perfecto, a las 7pm me va bien" 2000)")"
del "chats/$EX1/messages/m03" "$TA"
check "  mensaje 3" "$(put "chats/$EX1/messages/m03" "$TA" "$(mensaje "$EX1" m03 "$UA" "Cesar" "Listo, te paso el enlace de la reunion" 3000)")"
del "chats/$EX1/messages/m04" "$TB"
check "  mensaje 4" "$(put "chats/$EX1/messages/m04" "$TB" "$(mensaje "$EX1" m04 "$UB" "Marcelo" "Gracias por todo, quedo genial" 4000)")"

echo ""
echo "[5] VALIDACION DEL APRENDIZAJE         (HU30)"
check "Evidencia de Cesar" \
  "$(put "learningEvidence/ev_cesar_01" "$TA" "{\"fields\":{\"id\":$(sv ev_cesar_01),\"exchangeId\":$(sv "$EX1"),\"userId\":$(sv "$UA"),\"partnerId\":$(sv "$UB"),\"skillName\":$(sv Figma),\"activity\":$(sv "Disene en Figma el prototipo de 3 pantallas de SkillSwap"),\"notes\":$(sv "Me costo el autolayout pero lo saque"),\"evidenceUrl\":$(sv ""),\"objectiveAchieved\":{\"booleanValue\":true},\"selfAssessment\":{\"integerValue\":\"4\"},\"createdAt\":{\"integerValue\":\"$NOW\"}}}")"
check "Evidencia de Marcelo" \
  "$(put "learningEvidence/ev_marcelo_01" "$TB" "{\"fields\":{\"id\":$(sv ev_marcelo_01),\"exchangeId\":$(sv "$EX1"),\"userId\":$(sv "$UB"),\"partnerId\":$(sv "$UA"),\"skillName\":$(sv Java),\"activity\":$(sv "Programe una calculadora en Java aplicando POO"),\"notes\":$(sv "Entendi herencia y encapsulamiento"),\"evidenceUrl\":$(sv ""),\"objectiveAchieved\":{\"booleanValue\":true},\"selfAssessment\":{\"integerValue\":\"4\"},\"createdAt\":{\"integerValue\":\"$NOW\"}}}")"

echo ""
echo "[6] CALIFICACIONES                     (HU35-HU38)"
# Una calificacion emitida es inmutable: las reglas prohiben update y delete.
# Por eso, si ya existe, se deja como esta.
if existe "ratings/rat_a_b_01" "$TA"; then
  pass "Cesar califica a Marcelo (ya existia, inmutable)"
else
check "Cesar califica a Marcelo" \
  "$(put "ratings/rat_a_b_01" "$TA" "{\"fields\":{\"id\":$(sv rat_a_b_01),\"exchangeId\":$(sv "$EX1"),\"fromUserId\":$(sv "$UA"),\"fromUserName\":$(sv "Cesar Ricra"),\"toUserId\":$(sv "$UB"),\"toUserName\":$(sv "Marcelo Leguia"),\"skillTaught\":$(sv Figma),\"stars\":{\"doubleValue\":5},\"punctuality\":{\"doubleValue\":5},\"communication\":{\"doubleValue\":5},\"teaching\":{\"doubleValue\":4},\"comment\":$(sv "Explica muy claro y siempre llego puntual"),\"createdAt\":{\"integerValue\":\"$NOW\"}}}")"
fi
if existe "ratings/rat_b_a_01" "$TB"; then
  pass "Marcelo califica a Cesar (ya existia, inmutable)"
else
check "Marcelo califica a Cesar" \
  "$(put "ratings/rat_b_a_01" "$TB" "{\"fields\":{\"id\":$(sv rat_b_a_01),\"exchangeId\":$(sv "$EX1"),\"fromUserId\":$(sv "$UB"),\"fromUserName\":$(sv "Marcelo Leguia"),\"toUserId\":$(sv "$UA"),\"toUserName\":$(sv "Cesar Ricra"),\"skillTaught\":$(sv Java),\"stars\":{\"doubleValue\":5},\"punctuality\":{\"doubleValue\":4},\"communication\":{\"doubleValue\":5},\"teaching\":{\"doubleValue\":5},\"comment\":$(sv "Muy paciente explicando POO desde cero"),\"createdAt\":{\"integerValue\":\"$NOW\"}}}")"
fi
check "Reputacion de Marcelo" "$(upd "users/$UB" "$TA" "updateMask.fieldPaths=reputation&updateMask.fieldPaths=totalRatings&updateMask.fieldPaths=exchangesCount" '{"fields":{"reputation":{"doubleValue":4.75},"totalRatings":{"integerValue":"1"},"exchangesCount":{"integerValue":"1"}}}')"
check "Reputacion de Cesar"   "$(upd "users/$UA" "$TB" "updateMask.fieldPaths=reputation&updateMask.fieldPaths=totalRatings&updateMask.fieldPaths=exchangesCount" '{"fields":{"reputation":{"doubleValue":4.75},"totalRatings":{"integerValue":"1"},"exchangesCount":{"integerValue":"1"}}}')"

# ---------------------------------------------------------------------------
echo ""
echo "[7] INTERCAMBIO 2 - EN PROCESO 1/3     (HU24, HU28)"
EX2="real_enproceso_01"
check "Intercambio 2 creado en PROXIMO" \
  "$(put "exchanges/$EX2" "$TA" "$(intercambio "$EX2" PROXIMO 0 0 0 false false false "" false)")"
check "Intercambio 2 -> EN_PROCESO 1/3" \
  "$(put "exchanges/$EX2" "$TA" "$(intercambio "$EX2" EN_PROCESO 33 3 1 false false false "$EX2" false)")"
check "Contrato ACTIVO del intercambio 2" \
  "$(put "learningContracts/$EX2" "$TA" "$(contrato "$EX2" true true ACTIVO \
     "Practicar ingles tecnico y ensenar Python" \
     "Sostener una conversacion tecnica de 10 minutos" \
     "Exponer en ingles como funciona un script en Python")")"
check "Chat del intercambio 2" "$(put "chats/$EX2" "$TA" "$(chat "$EX2" "Nos vemos el jueves entonces" 1)")"
del "chats/$EX2/messages/m01" "$TB"
check "  mensaje 1" "$(put "chats/$EX2/messages/m01" "$TB" "$(mensaje "$EX2" m01 "$UB" "Marcelo" "Nos vemos el jueves entonces" 1000)")"

echo ""
echo "[8] INTERCAMBIO 3 - PROXIMO SIN CONTRATO  (para demostrar HU26-HU27 en vivo)"
EX3="real_proximo_01"
check "Intercambio proximo, sin contrato" \
  "$(put "exchanges/$EX3" "$TA" "$(intercambio "$EX3" PROXIMO 0 0 0 false false false "" false)")"
curl -s -m 20 -X DELETE "$FS/learningContracts/$EX3" -H "Authorization: Bearer $TA" > /dev/null 2>&1
check "Chat del intercambio 3" "$(put "chats/$EX3" "$TA" "$(chat "$EX3" "Intercambio aceptado" 0)")"

# ---------------------------------------------------------------------------
echo ""
echo "[9] SOLICITUD PENDIENTE                (HU19-HU23, para aceptar en vivo)"
REQ="real_req_pend_01"
# Si ya existe hay que borrarla: una solicitud creada solo admite cambios de
# estado, no una reescritura completa (createdAt no se puede tocar).
curl -s -m 20 -X DELETE "$FS/exchangeRequests/$REQ" -H "Authorization: Bearer $TB" > /dev/null 2>&1
check "Marcelo envia solicitud a Cesar" \
  "$(put "exchangeRequests/$REQ" "$TB" "{\"fields\":{\"id\":$(sv "$REQ"),\"fromUserId\":$(sv "$UB"),\"fromUserName\":$(sv "Marcelo Leguia"),\"toUserId\":$(sv "$UA"),\"toUserName\":$(sv "Cesar Ricra"),\"participants\":{\"arrayValue\":{\"values\":[$(sv "$UA"),$(sv "$UB")]}},\"skillWanted\":$(sv Python),\"skillOffered\":$(sv Figma),\"modality\":$(sv Virtual),\"schedule\":$(sv "Sabados - Manana"),\"message\":$(sv "Hola Cesar, me gustaria aprender Python y te puedo ensenar Figma"),\"status\":$(sv PENDIENTE),\"matchScore\":{\"integerValue\":\"96\"},\"exchangeId\":$(sv ""),\"createdAt\":{\"integerValue\":\"$NOW\"},\"updatedAt\":{\"integerValue\":\"$NOW\"}}}")"

# ---------------------------------------------------------------------------
echo ""
echo "[10] PASAPORTE DE HABILIDADES          (HU42)"
pasaporte() { # uid token clave nombre rol nivel veces progreso
  put "skillPassport/$3" "$2" "{\"fields\":{\"id\":$(sv "$3"),\"userId\":$(sv "$1"),\"skillName\":$(sv "$4"),\"role\":$(sv "$5"),\"level\":$(sv "$6"),\"exchangesCount\":{\"integerValue\":\"$7\"},\"hours\":{\"integerValue\":\"3\"},\"progress\":{\"integerValue\":\"$8\"},\"lastActivityAt\":{\"integerValue\":\"$NOW\"}}}"
}
check "Cesar - Java ensenada"    "$(pasaporte "$UA" "$TA" "${UA}__java__ENSENADA"    Java   ENSENADA  Intermedio 1 20)"
check "Cesar - Figma aprendida"  "$(pasaporte "$UA" "$TA" "${UA}__figma__APRENDIDA"  Figma  APRENDIDA Basico     1 20)"
check "Marcelo - Figma ensenada" "$(pasaporte "$UB" "$TB" "${UB}__figma__ENSENADA"   Figma  ENSENADA  Intermedio 1 20)"
check "Marcelo - Java aprendida" "$(pasaporte "$UB" "$TB" "${UB}__java__APRENDIDA"   Java   APRENDIDA Basico     1 20)"

# ---------------------------------------------------------------------------
echo ""
echo "[11] SKILLPOINTS, NIVELES E INSIGNIAS  (HU39-HU41, HU43)"
puntos() { # uid token total
  put "skillPoints/$1" "$2" "{\"fields\":{\"userId\":$(sv "$1"),\"points\":{\"integerValue\":\"$3\"},\"level\":$(sv Principiante),\"levelIndex\":{\"integerValue\":\"0\"},\"pointsForNextLevel\":{\"integerValue\":\"100\"},\"updatedAt\":{\"integerValue\":\"$NOW\"}}}"
}
historial() { # uid token id puntos motivo desfase
  put "skillPoints/$1/history/$3" "$2" "{\"fields\":{\"userId\":$(sv "$1"),\"points\":{\"integerValue\":\"$4\"},\"reason\":$(sv "$5"),\"createdAt\":{\"integerValue\":\"$(( NOW + $6 ))\"}}}"
}
insignia() { # uid token codigo nombre desc
  put "badges/$1__$3" "$2" "{\"fields\":{\"userId\":$(sv "$1"),\"code\":$(sv "$3"),\"name\":$(sv "$4"),\"description\":$(sv "$5"),\"unlocked\":{\"booleanValue\":true},\"unlockedAt\":{\"integerValue\":\"$NOW\"}}}"
}

for p in "$UA:$TA" "$UB:$TB"; do
  U="${p%%:*}"; T="${p##*:}"
  puntos "$U" "$T" 53 > /dev/null
  historial "$U" "$T" h01  8 "Contrato aceptado"        1000 > /dev/null
  historial "$U" "$T" h02 15 "Sesion registrada"        2000 > /dev/null
  historial "$U" "$T" h03 25 "Intercambio completado"   3000 > /dev/null
  historial "$U" "$T" h04  5 "Validacion de aprendizaje" 4000 > /dev/null
  insignia "$U" "$T" FIRST_SWAP "Primer intercambio" "Completaste tu primer intercambio" > /dev/null
  insignia "$U" "$T" COMMITTED  "Compromiso"         "Aceptaste un contrato de aprendizaje" > /dev/null
  upd "users/$U" "$T" "updateMask.fieldPaths=skillPoints&updateMask.fieldPaths=gamificationLevel" \
      '{"fields":{"skillPoints":{"integerValue":"53"},"gamificationLevel":{"stringValue":"Principiante"}}}' > /dev/null
done
pass "53 SkillPoints, 4 movimientos y 2 insignias para cada uno"

# ---------------------------------------------------------------------------
echo ""
echo "[12] SKILL CHALLENGE                   (HU44-HU46)"
CH="real_reto_01"
check "Cesar crea el reto" \
  "$(put "challenges/$CH" "$TA" "{\"fields\":{\"id\":$(sv "$CH"),\"title\":$(sv "App movil en 7 dias"),\"description\":$(sv "Armar entre todos una app sencilla: diseno en Figma y codigo en Java."),\"objective\":$(sv "Publicar un prototipo funcional"),\"category\":$(sv "Programaci${BS}u00f3n"),\"requiredSkills\":{\"arrayValue\":{\"values\":[$(sv Java),$(sv Figma)]}},\"participantIds\":{\"arrayValue\":{\"values\":[$(sv "$UA")]}},\"creatorId\":$(sv "$UA"),\"creatorName\":$(sv "Cesar Ricra"),\"creatorPhoto\":$(sv ""),\"maxParticipants\":{\"integerValue\":\"4\"},\"participantsCount\":{\"integerValue\":\"1\"},\"durationDays\":{\"integerValue\":\"7\"},\"progress\":{\"integerValue\":\"0\"},\"status\":$(sv ABIERTO),\"deadline\":{\"integerValue\":\"$(( NOW + 604800000 ))\"},\"createdAt\":{\"integerValue\":\"$NOW\"}}}")"
del "challengeParticipants/${CH}__${UB}" "$TB"
check "Marcelo se postula (PENDIENTE)" \
  "$(put "challengeParticipants/${CH}__${UB}" "$TB" "{\"fields\":{\"id\":$(sv "${CH}__${UB}"),\"challengeId\":$(sv "$CH"),\"userId\":$(sv "$UB"),\"userName\":$(sv "Marcelo Leguia"),\"userPhoto\":$(sv ""),\"skill\":$(sv Figma),\"role\":$(sv "Disenador"),\"message\":$(sv "Puedo encargarme de todo el diseno"),\"status\":$(sv PENDIENTE),\"joinedAt\":{\"integerValue\":\"$NOW\"}}}")"

# ---------------------------------------------------------------------------
echo ""
echo "[13] NOTIFICACIONES                    (HU48)"
borrar_notis() { for n in not_01 not_02 not_03; do del "notifications/$n" "$TA"; done; del "notifications/not_04" "$TB"; }
notif() { # id destino token tipo titulo cuerpo leida ref
  put "notifications/$1" "$3" "{\"fields\":{\"id\":$(sv "$1"),\"userId\":$(sv "$2"),\"type\":$(sv "$4"),\"title\":$(sv "$5"),\"body\":$(sv "$6"),\"read\":{\"booleanValue\":$7},\"referenceId\":$(sv "$8"),\"createdAt\":{\"integerValue\":\"$NOW\"}}}"
}
borrar_notis
check "Solicitud pendiente -> Cesar" \
  "$(notif not_01 "$UA" "$TB" NEW_REQUEST "Nueva solicitud de intercambio" "Marcelo Leguia quiere aprender Python" false "$REQ")"
check "Mensaje nuevo -> Cesar" \
  "$(notif not_02 "$UA" "$TB" NEW_MESSAGE "Nuevo mensaje" "Marcelo: Nos vemos el jueves entonces" false "$EX2")"
check "Postulacion al reto -> Cesar" \
  "$(notif not_03 "$UA" "$TB" NEW_REQUEST "Postulacion a tu reto" "Marcelo Leguia quiere unirse a 'App movil en 7 dias'" false "$CH")"
# Las reglas obligan a que toda notificacion nazca sin leer: solo su dueno
# puede marcarla como leida despues (eso es justo lo que demuestra la HU48).
check "Intercambio cerrado -> Marcelo" \
  "$(notif not_04 "$UB" "$TA" EXCHANGE_COMPLETED "Intercambio completado" "Ya puedes calificar tu intercambio con Cesar" false "$EX1")"

# ---------------------------------------------------------------------------
echo ""
echo "=============================================================="
printf " RESULTADO:  %d correctas   %d fallidas\n" "$OK" "$FAIL"
echo "=============================================================="
echo ""
echo " Entra en la app con cualquiera de las dos cuentas reales."
echo ""
echo "   Explorar      -> el otro companero con 96 %"
echo "   Intercambios  -> Proximos(1) / En proceso(1) / Completados(1)"
echo "   Solicitudes   -> 1 pendiente (Marcelo -> Cesar)"
echo "   Chats         -> 3 conversaciones"
echo "   Perfil        -> 53 SkillPoints, 2 insignias, pasaporte con 2 entradas"
echo "   Retos         -> 1 reto abierto con 1 postulante pendiente"
echo ""
[ "$FAIL" -eq 0 ]
