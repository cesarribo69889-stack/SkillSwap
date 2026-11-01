#!/usr/bin/env bash
# ============================================================================
#  Prueba end-to-end del flujo completo de SkillSwap contra el Firebase real.
#  Simula a dos estudiantes (Cesar y Ana) recorriendo los 13 pasos del flujo
#  y comprueba que las reglas de seguridad no bloqueen ningun paso legitimo.
#  Al final borra TODO lo que creo.
# ============================================================================
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJ="skillswap-fa97f"
KEY=$(grep -o '"current_key": "[^"]*"' "$ROOT/app/google-services.json" | head -1 | sed 's/.*: "//;s/"//')
FS="https://firestore.googleapis.com/v1/projects/$PROJ/databases/(default)/documents"
OK=0; FAIL=0
CREATED=""

pass() { OK=$((OK+1)); printf "  \033[32mOK\033[0m   %s\n" "$1"; }
fail() { FAIL=$((FAIL+1)); printf "  \033[31mFALLA\033[0m %s\n     -> %s\n" "$1" "$2"; }

# check <descripcion> <respuesta-json> [<ruta-creada>]
check() {
  if echo "$2" | grep -q '"error"'; then
    fail "$1" "$(echo "$2" | grep -oE '"(status|message)": "[^"]*"' | head -1)"
  else
    pass "$1"
    [ -n "${3:-}" ] && CREATED="$CREATED $3"
  fi
}

signup() { # $1=email
  curl -s -m 25 -X POST "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$KEY" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$1\",\"password\":\"prueba123\",\"returnSecureToken\":true}"
}

post() { # $1=path(con ?documentId=) $2=token $3=body
  curl -s -m 25 -X POST "$FS/$1" -H "Authorization: Bearer $2" \
    -H "Content-Type: application/json" -d "$3"
}

patch() { # $1=path $2=token $3=updateMask-query $4=body
  curl -s -m 25 -X PATCH "$FS/$1?$3" -H "Authorization: Bearer $2" \
    -H "Content-Type: application/json" -d "$4"
}

echo "=============================================================="
echo " SKILLSWAP - prueba end-to-end del flujo completo"
echo "=============================================================="

# ---------------------------------------------------------------- 1. cuentas
echo ""
echo "[1] REGISTRO de dos estudiantes"
RA=$(signup "e2e.cesar@skillswap.test"); TA=$(echo "$RA" | grep -o '"idToken": *"[^"]*"' | sed 's/.*: *"//;s/"//'); UA=$(echo "$RA" | grep -o '"localId": *"[^"]*"' | sed 's/.*: *"//;s/"//')
RB=$(signup "e2e.ana@skillswap.test");   TB=$(echo "$RB" | grep -o '"idToken": *"[^"]*"' | sed 's/.*: *"//;s/"//'); UB=$(echo "$RB" | grep -o '"localId": *"[^"]*"' | sed 's/.*: *"//;s/"//')
[ -n "$TA" ] && pass "Cuenta A creada ($UA)" || fail "Cuenta A" "$RA"
[ -n "$TB" ] && pass "Cuenta B creada ($UB)" || fail "Cuenta B" "$RB"
[ -z "$TA" ] || [ -z "$TB" ] && { echo "Sin tokens, aborto."; exit 1; }

# ---------------------------------------------------------------- 2. perfiles
echo ""
echo "[2] CREAR PERFIL + HABILIDADES"
perfil() { # $1=uid $2=nombre $3=ensena $4=aprende
cat <<EOF
{"fields":{
 "uid":{"stringValue":"$1"},
 "firstName":{"stringValue":"$2"},"lastName":{"stringValue":"Prueba"},
 "email":{"stringValue":"e2e@skillswap.test"},
 "university":{"stringValue":"UPN"},"career":{"stringValue":"Ingenieria de Sistemas"},
 "cycle":{"stringValue":"Ciclo VI"},"modality":{"stringValue":"Virtual"},
 "availability":{"arrayValue":{"values":[{"stringValue":"Lunes a Viernes - Noche"}]}},
 "teachSkillKeys":{"arrayValue":{"values":[{"stringValue":"$3"}]}},
 "learnSkillKeys":{"arrayValue":{"values":[{"stringValue":"$4"}]}},
 "reputation":{"doubleValue":0},"totalRatings":{"integerValue":"0"},
 "exchangesCount":{"integerValue":"0"},"skillPoints":{"integerValue":"0"},
 "active":{"booleanValue":true},"profileCompleted":{"booleanValue":true}
}}
EOF
}
check "Perfil de Cesar (ensena java, busca figma)" "$(post "users?documentId=$UA" "$TA" "$(perfil "$UA" Cesar java figma)")" "users/$UA"
check "Perfil de Ana (ensena figma, busca java)"   "$(post "users?documentId=$UB" "$TB" "$(perfil "$UB" Ana figma java)")" "users/$UB"
check "Catalogo de habilidades (skills)" "$(post "skills?documentId=e2e_java" "$TA" '{"fields":{"id":{"stringValue":"e2e_java"},"name":{"stringValue":"Java"},"category":{"stringValue":"Programacion"}}}')" "skills/e2e_java"

# ---------------------------------------------------------------- 3. explorar
echo ""
echo "[3] BUSCAR COINCIDENCIAS (Explorar lee los perfiles)"
R=$(curl -s -m 25 "$FS/users" -H "Authorization: Bearer $TA")
echo "$R" | grep -q '"documents"' && pass "Cesar puede listar estudiantes" || fail "Listar estudiantes" "$R"

# ---------------------------------------------------------------- 4. match
echo ""
echo "[4] SKILLMATCH (guardar el match calculado)"
MID="${UA}_${UB}"
check "Guardar match" "$(post "matches?documentId=$MID" "$TA" "{\"fields\":{\"id\":{\"stringValue\":\"$MID\"},\"userAId\":{\"stringValue\":\"$UA\"},\"userBId\":{\"stringValue\":\"$UB\"},\"participants\":{\"arrayValue\":{\"values\":[{\"stringValue\":\"$UA\"},{\"stringValue\":\"$UB\"}]}},\"score\":{\"integerValue\":\"96\"},\"mutual\":{\"booleanValue\":true}}}")" "matches/$MID"

# ---------------------------------------------------------------- 5. solicitud
echo ""
echo "[5] ENVIAR SOLICITUD (Cesar -> Ana)"
REQ="e2ereq001"
check "Cesar envia solicitud" "$(post "exchangeRequests?documentId=$REQ" "$TA" "{\"fields\":{\"id\":{\"stringValue\":\"$REQ\"},\"fromUserId\":{\"stringValue\":\"$UA\"},\"fromUserName\":{\"stringValue\":\"Cesar\"},\"toUserId\":{\"stringValue\":\"$UB\"},\"toUserName\":{\"stringValue\":\"Ana\"},\"participants\":{\"arrayValue\":{\"values\":[{\"stringValue\":\"$UA\"},{\"stringValue\":\"$UB\"}]}},\"skillWanted\":{\"stringValue\":\"Figma\"},\"skillOffered\":{\"stringValue\":\"Java\"},\"modality\":{\"stringValue\":\"Virtual\"},\"schedule\":{\"stringValue\":\"Lunes a Viernes - Noche\"},\"status\":{\"stringValue\":\"PENDIENTE\"},\"matchScore\":{\"integerValue\":\"96\"}}}")" "exchangeRequests/$REQ"
check "Notificacion a Ana" "$(post "notifications?documentId=e2enot001" "$TA" "{\"fields\":{\"userId\":{\"stringValue\":\"$UB\"},\"type\":{\"stringValue\":\"NEW_REQUEST\"},\"title\":{\"stringValue\":\"Nueva solicitud\"},\"body\":{\"stringValue\":\"Cesar quiere aprender Figma\"},\"read\":{\"booleanValue\":false}}}")" "notifications/e2enot001"

# ---------------------------------------------------------------- 6. aceptar
echo ""
echo "[6] ACEPTAR SOLICITUD + CREAR INTERCAMBIO (Ana)"
EX="e2eex001"
check "Ana crea el intercambio" "$(post "exchanges?documentId=$EX" "$TB" "{\"fields\":{\"id\":{\"stringValue\":\"$EX\"},\"requestId\":{\"stringValue\":\"$REQ\"},\"userAId\":{\"stringValue\":\"$UA\"},\"userAName\":{\"stringValue\":\"Cesar\"},\"userBId\":{\"stringValue\":\"$UB\"},\"userBName\":{\"stringValue\":\"Ana\"},\"participants\":{\"arrayValue\":{\"values\":[{\"stringValue\":\"$UA\"},{\"stringValue\":\"$UB\"}]}},\"skillFromA\":{\"stringValue\":\"Java\"},\"skillFromB\":{\"stringValue\":\"Figma\"},\"modality\":{\"stringValue\":\"Virtual\"},\"status\":{\"stringValue\":\"PROXIMO\"},\"progress\":{\"integerValue\":\"0\"},\"sessionsTotal\":{\"integerValue\":\"0\"},\"sessionsDone\":{\"integerValue\":\"0\"},\"completedByA\":{\"booleanValue\":false},\"completedByB\":{\"booleanValue\":false},\"ratedByA\":{\"booleanValue\":false},\"ratedByB\":{\"booleanValue\":false}}}")" "exchanges/$EX"
check "Ana marca la solicitud ACEPTADA" "$(patch "exchangeRequests/$REQ" "$TB" "updateMask.fieldPaths=status&updateMask.fieldPaths=exchangeId&updateMask.fieldPaths=updatedAt" "{\"fields\":{\"status\":{\"stringValue\":\"ACEPTADA\"},\"exchangeId\":{\"stringValue\":\"$EX\"},\"updatedAt\":{\"integerValue\":\"1790000000000\"}}}")"

# ---------------------------------------------------------------- 7. chat
echo ""
echo "[7] CHAT (solo existe con intercambio aceptado)"
check "Crear conversacion" "$(post "chats?documentId=$EX" "$TB" "{\"fields\":{\"id\":{\"stringValue\":\"$EX\"},\"exchangeId\":{\"stringValue\":\"$EX\"},\"participants\":{\"arrayValue\":{\"values\":[{\"stringValue\":\"$UA\"},{\"stringValue\":\"$UB\"}]}},\"enabled\":{\"booleanValue\":true},\"lastMessage\":{\"stringValue\":\"Intercambio aceptado\"}}}")" "chats/$EX"
check "Cesar envia un mensaje" "$(post "chats/$EX/messages?documentId=e2emsg001" "$TA" "{\"fields\":{\"chatId\":{\"stringValue\":\"$EX\"},\"senderId\":{\"stringValue\":\"$UA\"},\"senderName\":{\"stringValue\":\"Cesar\"},\"text\":{\"stringValue\":\"Hola Ana, empezamos el sabado?\"},\"type\":{\"stringValue\":\"TEXT\"},\"timestamp\":{\"integerValue\":\"1790000000000\"}}}")" "chats/$EX/messages/e2emsg001"
check "Ana responde" "$(post "chats/$EX/messages?documentId=e2emsg002" "$TB" "{\"fields\":{\"chatId\":{\"stringValue\":\"$EX\"},\"senderId\":{\"stringValue\":\"$UB\"},\"senderName\":{\"stringValue\":\"Ana\"},\"text\":{\"stringValue\":\"Perfecto, a las 7pm\"},\"type\":{\"stringValue\":\"TEXT\"},\"timestamp\":{\"integerValue\":\"1790000001000\"}}}")" "chats/$EX/messages/e2emsg002"

# ---------------------------------------------------------------- 8. contrato
echo ""
echo "[8] CONTRATO DE APRENDIZAJE (innovacion 3)"
check "Cesar crea el contrato" "$(post "learningContracts?documentId=$EX" "$TA" "{\"fields\":{\"id\":{\"stringValue\":\"$EX\"},\"exchangeId\":{\"stringValue\":\"$EX\"},\"participants\":{\"arrayValue\":{\"values\":[{\"stringValue\":\"$UA\"},{\"stringValue\":\"$UB\"}]}},\"userAId\":{\"stringValue\":\"$UA\"},\"userBId\":{\"stringValue\":\"$UB\"},\"createdBy\":{\"stringValue\":\"$UA\"},\"objective\":{\"stringValue\":\"Aprender POO con Java\"},\"sessions\":{\"integerValue\":\"3\"},\"sessionDuration\":{\"integerValue\":\"60\"},\"modality\":{\"stringValue\":\"Virtual\"},\"finalActivity\":{\"stringValue\":\"Crear una calculadora\"},\"acceptedByA\":{\"booleanValue\":true},\"acceptedByB\":{\"booleanValue\":false},\"status\":{\"stringValue\":\"PENDIENTE\"}}}")" "learningContracts/$EX"
check "Ana acepta el acuerdo" "$(patch "learningContracts/$EX" "$TB" "updateMask.fieldPaths=acceptedByB&updateMask.fieldPaths=status" '{"fields":{"acceptedByB":{"booleanValue":true},"status":{"stringValue":"ACTIVO"}}}')"
echo "    (comprobando que Ana NO pueda aceptar por Cesar...)"
R=$(patch "learningContracts/$EX" "$TB" "updateMask.fieldPaths=acceptedByA" '{"fields":{"acceptedByA":{"booleanValue":false}}}')
echo "$R" | grep -q 'PERMISSION_DENIED' && pass "BLOQUEADO: Ana no puede firmar por Cesar" || fail "Deberia bloquear firma ajena" "$R"

# ---------------------------------------------------------------- 9. completar
echo ""
echo "[9] REALIZAR Y COMPLETAR EL INTERCAMBIO"
check "Avance de sesiones" "$(patch "exchanges/$EX" "$TA" "updateMask.fieldPaths=sessionsDone&updateMask.fieldPaths=progress&updateMask.fieldPaths=status" '{"fields":{"sessionsDone":{"integerValue":"3"},"progress":{"integerValue":"100"},"status":{"stringValue":"EN_PROCESO"}}}')"
check "Cesar marca completado" "$(patch "exchanges/$EX" "$TA" "updateMask.fieldPaths=completedByA" '{"fields":{"completedByA":{"booleanValue":true}}}')"
check "Ana confirma y se cierra" "$(patch "exchanges/$EX" "$TB" "updateMask.fieldPaths=completedByB&updateMask.fieldPaths=status" '{"fields":{"completedByB":{"booleanValue":true},"status":{"stringValue":"COMPLETADO"}}}')"

# ---------------------------------------------------------------- 10. efectos
echo ""
echo "[10] EFECTOS DEL CIERRE (pasaporte, puntos, insignias)"
check "Pasaporte de Cesar (Java ensenada)" "$(post "skillPassport?documentId=${UA}__java__ENSENADA" "$TA" "{\"fields\":{\"userId\":{\"stringValue\":\"$UA\"},\"skillName\":{\"stringValue\":\"Java\"},\"role\":{\"stringValue\":\"ENSENADA\"},\"level\":{\"stringValue\":\"Basico\"},\"exchangesCount\":{\"integerValue\":\"1\"},\"progress\":{\"integerValue\":\"20\"}}}")" "skillPassport/${UA}__java__ENSENADA"
check "Pasaporte de Ana escrito por Cesar" "$(post "skillPassport?documentId=${UB}__figma__ENSENADA" "$TA" "{\"fields\":{\"userId\":{\"stringValue\":\"$UB\"},\"skillName\":{\"stringValue\":\"Figma\"},\"role\":{\"stringValue\":\"ENSENADA\"},\"exchangesCount\":{\"integerValue\":\"1\"}}}")" "skillPassport/${UB}__figma__ENSENADA"
check "Cuenta de SkillPoints" "$(post "skillPoints?documentId=$UA" "$TA" "{\"fields\":{\"userId\":{\"stringValue\":\"$UA\"},\"points\":{\"integerValue\":\"20\"},\"level\":{\"stringValue\":\"Principiante\"}}}")" "skillPoints/$UA"
check "Historial de puntos" "$(post "skillPoints/$UA/history?documentId=e2eh001" "$TA" "{\"fields\":{\"userId\":{\"stringValue\":\"$UA\"},\"points\":{\"integerValue\":\"20\"},\"reason\":{\"stringValue\":\"Intercambio completado\"}}}")" "skillPoints/$UA/history/e2eh001"
check "Insignia Primer intercambio" "$(post "badges?documentId=${UA}__FIRST_SWAP" "$TA" "{\"fields\":{\"userId\":{\"stringValue\":\"$UA\"},\"code\":{\"stringValue\":\"FIRST_SWAP\"},\"name\":{\"stringValue\":\"Primer intercambio\"},\"unlocked\":{\"booleanValue\":true}}}")" "badges/${UA}__FIRST_SWAP"
check "Contador de intercambios del otro" "$(patch "users/$UB" "$TA" "updateMask.fieldPaths=exchangesCount" '{"fields":{"exchangesCount":{"integerValue":"1"}}}')"

# ---------------------------------------------------------------- 11. calificar
echo ""
echo "[11] CALIFICAR"
check "Cesar califica a Ana" "$(post "ratings?documentId=e2erat001" "$TA" "{\"fields\":{\"exchangeId\":{\"stringValue\":\"$EX\"},\"fromUserId\":{\"stringValue\":\"$UA\"},\"fromUserName\":{\"stringValue\":\"Cesar\"},\"toUserId\":{\"stringValue\":\"$UB\"},\"skillTaught\":{\"stringValue\":\"Figma\"},\"stars\":{\"doubleValue\":5},\"punctuality\":{\"doubleValue\":5},\"communication\":{\"doubleValue\":5},\"teaching\":{\"doubleValue\":4},\"comment\":{\"stringValue\":\"Excelente\"}}}")" "ratings/e2erat001"
check "Reputacion de Ana actualizada" "$(patch "users/$UB" "$TA" "updateMask.fieldPaths=reputation&updateMask.fieldPaths=totalRatings" '{"fields":{"reputation":{"doubleValue":4.75},"totalRatings":{"integerValue":"1"}}}')"
echo "    (comprobando que no se pueda calificar dos veces el mismo doc...)"
R=$(patch "ratings/e2erat001" "$TA" "updateMask.fieldPaths=stars" '{"fields":{"stars":{"doubleValue":1}}}')
echo "$R" | grep -q 'PERMISSION_DENIED' && pass "BLOQUEADO: las calificaciones son inmutables" || fail "Deberia bloquear edicion de rating" "$R"

# ---------------------------------------------------------------- 12. evidencia
echo ""
echo "[12] VALIDACION DE APRENDIZAJE (innovacion 6)"
check "Cesar registra la actividad" "$(post "learningEvidence?documentId=e2eev001" "$TA" "{\"fields\":{\"exchangeId\":{\"stringValue\":\"$EX\"},\"userId\":{\"stringValue\":\"$UA\"},\"partnerId\":{\"stringValue\":\"$UB\"},\"skillName\":{\"stringValue\":\"Figma\"},\"activity\":{\"stringValue\":\"Diseno de un wireframe\"},\"objectiveAchieved\":{\"booleanValue\":true},\"selfAssessment\":{\"integerValue\":\"4\"}}}")" "learningEvidence/e2eev001"

# ---------------------------------------------------------------- 13. retos
echo ""
echo "[13] SKILL CHALLENGES (innovacion 5)"
CH="e2ech001"
check "Cesar crea un reto" "$(post "challenges?documentId=$CH" "$TA" "{\"fields\":{\"id\":{\"stringValue\":\"$CH\"},\"title\":{\"stringValue\":\"Crear una pagina web en 7 dias\"},\"objective\":{\"stringValue\":\"Landing funcional\"},\"requiredSkills\":{\"arrayValue\":{\"values\":[{\"stringValue\":\"Java\"},{\"stringValue\":\"Figma\"}]}},\"participantIds\":{\"arrayValue\":{\"values\":[{\"stringValue\":\"$UA\"}]}},\"creatorId\":{\"stringValue\":\"$UA\"},\"creatorName\":{\"stringValue\":\"Cesar\"},\"maxParticipants\":{\"integerValue\":\"4\"},\"participantsCount\":{\"integerValue\":\"1\"},\"progress\":{\"integerValue\":\"0\"},\"status\":{\"stringValue\":\"ABIERTO\"}}}")" "challenges/$CH"
check "Ana se postula" "$(post "challengeParticipants?documentId=${CH}__${UB}" "$TB" "{\"fields\":{\"challengeId\":{\"stringValue\":\"$CH\"},\"userId\":{\"stringValue\":\"$UB\"},\"userName\":{\"stringValue\":\"Ana\"},\"skill\":{\"stringValue\":\"Figma\"},\"status\":{\"stringValue\":\"PENDIENTE\"}}}")" "challengeParticipants/${CH}__${UB}"
check "Cesar acepta a Ana" "$(patch "challengeParticipants/${CH}__${UB}" "$TA" "updateMask.fieldPaths=status" '{"fields":{"status":{"stringValue":"ACEPTADO"}}}')"
echo "    (comprobando que un extrano no pueda aceptar postulantes...)"
R=$(patch "challengeParticipants/${CH}__${UB}" "$TB" "updateMask.fieldPaths=status" '{"fields":{"status":{"stringValue":"ACEPTADO"}}}')
echo "$R" | grep -q 'PERMISSION_DENIED' && pass "BLOQUEADO: solo el creador decide" || fail "Deberia bloquear" "$R"

# ---------------------------------------------------------------- seguridad
echo ""
echo "[SEGURIDAD] intentos ilegitimos que DEBEN fallar"
R=$(patch "users/$UA" "$TB" "updateMask.fieldPaths=firstName" '{"fields":{"firstName":{"stringValue":"Hackeado"}}}')
echo "$R" | grep -q 'PERMISSION_DENIED' && pass "BLOQUEADO: Ana no edita el perfil de Cesar" || fail "Deberia bloquear edicion de perfil ajeno" "$R"
R=$(curl -s -m 25 "$FS/chats/$EX/messages" -H "Authorization: Bearer $TB")
echo "$R" | grep -q '"documents"' && pass "Ana SI puede leer su propio chat" || fail "Ana deberia leer su chat" "$R"
R=$(curl -s -m 25 "$FS/users")
echo "$R" | grep -q 'PERMISSION_DENIED' && pass "BLOQUEADO: sin sesion no se lee nada" || fail "Deberia bloquear anonimo" "$R"

# ---------------------------------------------------------------- limpieza
echo ""
echo "[LIMPIEZA] borrando todo lo creado"
for p in $CREATED; do
  curl -s -m 20 -X DELETE "$FS/$p" -H "Authorization: Bearer $TA" >/dev/null
  curl -s -m 20 -X DELETE "$FS/$p" -H "Authorization: Bearer $TB" >/dev/null
done
curl -s -m 20 -X POST "https://identitytoolkit.googleapis.com/v1/accounts:delete?key=$KEY" -H "Content-Type: application/json" -d "{\"idToken\":\"$TA\"}" >/dev/null
curl -s -m 20 -X POST "https://identitytoolkit.googleapis.com/v1/accounts:delete?key=$KEY" -H "Content-Type: application/json" -d "{\"idToken\":\"$TB\"}" >/dev/null
echo "  Datos de prueba eliminados."

echo ""
echo "=============================================================="
printf " RESULTADO:  \033[32m%d correctas\033[0m   \033[31m%d fallos\033[0m\n" "$OK" "$FAIL"
echo "=============================================================="
[ "$FAIL" -eq 0 ]
