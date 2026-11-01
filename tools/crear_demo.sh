#!/usr/bin/env bash
# ============================================================================
#  Crea dos cuentas de demostracion con habilidades CRUZADAS para que
#  Explorar muestre un SkillMatch alto y se pueda sustentar el proyecto.
#  Correos:  demo.cesar@skillswap.test  /  demo.ana@skillswap.test
#  Clave:    Demo1234
# ============================================================================
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJ="skillswap-fa97f"
KEY=$(grep -o '"current_key": "[^"]*"' "$ROOT/app/google-services.json" | head -1 | sed 's/.*: "//;s/"//')
FS="https://firestore.googleapis.com/v1/projects/$PROJ/databases/(default)/documents"
PASS="Demo1234"

cuenta() { # $1=email -> imprime "token uid"
  R=$(curl -s -m 25 -X POST "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$KEY" \
      -H "Content-Type: application/json" \
      -d "{\"email\":\"$1\",\"password\":\"$PASS\",\"returnSecureToken\":true}")
  if echo "$R" | grep -q EMAIL_EXISTS; then
    R=$(curl -s -m 25 -X POST "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$KEY" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$1\",\"password\":\"$PASS\",\"returnSecureToken\":true}")
  fi
  echo "$(echo "$R" | grep -o '"idToken": *"[^"]*"' | sed 's/.*: *"//;s/"//') $(echo "$R" | grep -o '"localId": *"[^"]*"' | sed 's/.*: *"//;s/"//')"
}

# skill <id> <nombre> <categoria> <nivel> <TEACH|LEARN>
skill() {
cat <<EOF
{"mapValue":{"fields":{
 "skillId":{"stringValue":"$1"},"name":{"stringValue":"$2"},
 "category":{"stringValue":"$3"},"level":{"stringValue":"$4"},
 "type":{"stringValue":"$5"},"note":{"stringValue":""},
 "addedAt":{"integerValue":"1790000000000"}}}}
EOF
}

perfil() { # $1=uid $2=nombre $3=apellido $4=teachJSON $5=learnJSON $6=teachKey $7=learnKey
cat <<EOF
{"fields":{
 "uid":{"stringValue":"$1"},
 "firstName":{"stringValue":"$2"},"lastName":{"stringValue":"$3"},
 "email":{"stringValue":"demo@skillswap.test"},
 "photoUrl":{"stringValue":""},
 "university":{"stringValue":"Universidad Privada del Norte"},
 "career":{"stringValue":"Ingenieria de Sistemas"},
 "cycle":{"stringValue":"Ciclo IX"},
 "description":{"stringValue":"Cuenta de demostracion de SkillSwap."},
 "modality":{"stringValue":"Virtual"},
 "availability":{"arrayValue":{"values":[
    {"stringValue":"Lunes a Viernes - Noche"},
    {"stringValue":"Sabados - Manana"}]}},
 "teachSkills":{"arrayValue":{"values":[$4]}},
 "learnSkills":{"arrayValue":{"values":[$5]}},
 "teachSkillKeys":{"arrayValue":{"values":[{"stringValue":"$6"}]}},
 "learnSkillKeys":{"arrayValue":{"values":[{"stringValue":"$7"}]}},
 "searchKeywords":{"arrayValue":{"values":[
    {"stringValue":"$(echo "$2" | tr 'A-Z' 'a-z')"},{"stringValue":"demo"},
    {"stringValue":"ingenieria"},{"stringValue":"sistemas"}]}},
 "reputation":{"doubleValue":0},"totalRatings":{"integerValue":"0"},
 "exchangesCount":{"integerValue":"0"},"skillPoints":{"integerValue":"0"},
 "gamificationLevel":{"stringValue":"Principiante"},
 "profileCompleted":{"booleanValue":true},"active":{"booleanValue":true},
 "createdAt":{"integerValue":"1790000000000"},
 "updatedAt":{"integerValue":"1790000000000"}
}}
EOF
}

echo "=============================================================="
echo " Creando cuentas de demostracion"
echo "=============================================================="

read -r TA UA <<< "$(cuenta demo.cesar@skillswap.test)"
read -r TB UB <<< "$(cuenta demo.ana@skillswap.test)"
[ -z "$TA" ] || [ -z "$TB" ] && { echo "No se pudieron crear las cuentas."; exit 1; }

# --- Cesar: ensena Java (Avanzado) + Python, quiere aprender Figma -----------
TEACH_A="$(skill java Java "Programación" Avanzado TEACH),$(skill python Python "Programación" Intermedio TEACH)"
LEARN_A="$(skill figma Figma "Diseño" Básico LEARN)"
R=$(curl -s -m 25 -X PATCH "$FS/users/$UA" -H "Authorization: Bearer $TA" \
    -H "Content-Type: application/json" -d "$(perfil "$UA" Cesar Demo "$TEACH_A" "$LEARN_A" java figma)")
echo "$R" | grep -q '"error"' && echo "  FALLA Cesar: $(echo "$R" | grep -oE '"message": "[^"]*"')" || echo "  OK  Cesar  -> ensena Java(Avanzado), Python(Intermedio) | busca Figma"

# --- Ana: ensena Figma (Avanzado) + Ingles, quiere aprender Java -------------
TEACH_B="$(skill figma Figma "Diseño" Avanzado TEACH),$(skill ingles Inglés Idiomas Avanzado TEACH)"
LEARN_B="$(skill java Java "Programación" Básico LEARN)"
R=$(curl -s -m 25 -X PATCH "$FS/users/$UB" -H "Authorization: Bearer $TB" \
    -H "Content-Type: application/json" -d "$(perfil "$UB" Ana Demo "$TEACH_B" "$LEARN_B" figma java)")
echo "$R" | grep -q '"error"' && echo "  FALLA Ana: $(echo "$R" | grep -oE '"message": "[^"]*"')" || echo "  OK  Ana    -> ensena Figma(Avanzado), Inglés(Avanzado) | busca Java"

# --- cuenta de SkillPoints de cada uno --------------------------------------
for pair in "$UA:$TA" "$UB:$TB"; do
  U="${pair%%:*}"; T="${pair##*:}"
  curl -s -m 20 -X PATCH "$FS/skillPoints/$U" -H "Authorization: Bearer $T" \
    -H "Content-Type: application/json" \
    -d "{\"fields\":{\"userId\":{\"stringValue\":\"$U\"},\"points\":{\"integerValue\":\"0\"},\"level\":{\"stringValue\":\"Principiante\"},\"levelIndex\":{\"integerValue\":\"0\"},\"pointsForNextLevel\":{\"integerValue\":\"100\"}}}" >/dev/null
done
echo "  OK  Cuentas de SkillPoints inicializadas"

echo ""
echo "=============================================================="
echo " LISTO. Entra en la app con:"
echo ""
echo "   demo.cesar@skillswap.test   clave: $PASS"
echo "   demo.ana@skillswap.test     clave: $PASS"
echo ""
echo " uid Cesar: $UA"
echo " uid Ana:   $UB"
echo "=============================================================="
