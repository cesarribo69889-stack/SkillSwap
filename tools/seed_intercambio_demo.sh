#!/usr/bin/env bash
# ============================================================================
#  Deja listo un intercambio en estado PROXIMO entre las dos cuentas demo
#  (demo.cesar y demo.ana) para poder demostrar el Contrato de aprendizaje.
#  Si ya existe uno sin contrato, no crea otro.
#  Re-ejecutable.
# ============================================================================
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJ="skillswap-fa97f"
KEY=$(grep -o '"current_key": "[^"]*"' "$ROOT/app/google-services.json" | head -1 | sed 's/.*: "//;s/"//')
FS="https://firestore.googleapis.com/v1/projects/$PROJ/databases/(default)/documents"

login() { # $1=email $2=password
  curl -s -m 25 -X POST \
    "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$KEY" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$1\",\"password\":\"$2\",\"returnSecureToken\":true}"
}

field() { echo "$1" | grep -o "\"$2\": *\"[^\"]*\"" | head -1 | sed 's/.*: *"//;s/"//'; }

echo "== autenticando cuentas demo =="
RC=$(login "demo.cesar@skillswap.test" "Demo1234")
RA=$(login "demo.ana@skillswap.test"   "Demo1234")
TC=$(field "$RC" idToken); UC=$(field "$RC" localId)
TA=$(field "$RA" idToken); UA=$(field "$RA" localId)

if [ -z "$TC" ] || [ -z "$TA" ]; then
  echo "ERROR: no se pudo autenticar."
  echo "$RC" | head -c 300; echo; echo "$RA" | head -c 300
  exit 1
fi
echo "  Cesar: $UC"
echo "  Ana  : $UA"

echo ""
echo "== buscando intercambios existentes de Cesar =="
Q=$(curl -s -m 25 -X POST "$FS:runQuery" -H "Authorization: Bearer $TC" \
  -H "Content-Type: application/json" -d "{
    \"structuredQuery\": {
      \"from\": [{\"collectionId\": \"exchanges\"}],
      \"where\": {\"fieldFilter\": {
        \"field\": {\"fieldPath\": \"participants\"},
        \"op\": \"ARRAY_CONTAINS\",
        \"value\": {\"stringValue\": \"$UC\"}}}
    }}")

EXISTING=$(echo "$Q" | grep -o '"name": *"[^"]*exchanges/[^"]*"' | sed 's#.*/exchanges/##;s/"//')
if [ -n "$EXISTING" ]; then
  echo "  ya existen:"
  for e in $EXISTING; do echo "    - $e"; done
else
  echo "  ninguno"
fi

EX="demo_contrato_01"
echo ""
echo "== creando/reiniciando el intercambio $EX =="

BODY=$(cat <<JSON
{"fields":{
  "id":{"stringValue":"$EX"},
  "requestId":{"stringValue":"demo_req_01"},
  "userAId":{"stringValue":"$UC"},
  "userAName":{"stringValue":"Cesar Demo"},
  "userBId":{"stringValue":"$UA"},
  "userBName":{"stringValue":"Ana Demo"},
  "participants":{"arrayValue":{"values":[
      {"stringValue":"$UC"},{"stringValue":"$UA"}]}},
  "skillFromA":{"stringValue":"Java"},
  "skillFromB":{"stringValue":"Figma"},
  "modality":{"stringValue":"Virtual"},
  "status":{"stringValue":"PROXIMO"},
  "progress":{"integerValue":"0"},
  "sessionsTotal":{"integerValue":"0"},
  "sessionsDone":{"integerValue":"0"},
  "contractId":{"stringValue":""},
  "completedByA":{"booleanValue":false},
  "completedByB":{"booleanValue":false},
  "ratedByA":{"booleanValue":false},
  "ratedByB":{"booleanValue":false},
  "createdAt":{"integerValue":"$(date +%s)000"},
  "updatedAt":{"integerValue":"$(date +%s)000"}
}}
JSON
)

# Borrar primero el contrato previo (si lo hubiera) para partir de cero.
curl -s -m 25 -X DELETE "$FS/learningContracts/$EX" \
  -H "Authorization: Bearer $TC" > /dev/null 2>&1

R=$(curl -s -m 25 -X PATCH "$FS/exchanges/$EX" -H "Authorization: Bearer $TC" \
      -H "Content-Type: application/json" -d "$BODY")

if echo "$R" | grep -q '"error"'; then
  echo "  FALLO:"
  echo "$R" | grep -oE '"(status|message)": "[^"]*"' | head -2
  exit 1
fi

echo "  OK - intercambio $EX en estado PROXIMO, sin contrato"
echo ""
echo "Ahora en la app:"
echo "  1. Entra como demo.cesar@skillswap.test / Demo1234"
echo "  2. Pestana Intercambios -> Proximos -> 'Ana Demo'"
echo "  3. Toca la tarjeta 'Contrato de aprendizaje'"
