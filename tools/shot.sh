#!/usr/bin/env bash
# Captura la pantalla del emulador y la guarda en capturas/<nombre>.png
# Uso: bash tools/shot.sh 01_login
#
# Ojo: MSYS_NO_PATHCONV hace falta para la ruta DEL DISPOSITIVO (/sdcard/...),
# pero rompe la ruta local de destino. Por eso la local se pasa en formato
# Windows con cygpath y la variable solo se exporta para las llamadas a adb.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/capturas"
mkdir -p "$OUT"
DEST="$(cygpath -w "$OUT/$1.png")"
export PATH="$PATH:/c/Users/ricra/AppData/Local/Android/Sdk/platform-tools"

MSYS_NO_PATHCONV=1 adb shell screencap -p /sdcard/_s.png
MSYS_NO_PATHCONV=1 adb pull /sdcard/_s.png "$DEST" > /dev/null 2>&1
MSYS_NO_PATHCONV=1 adb shell rm /sdcard/_s.png

if [ -f "$OUT/$1.png" ]; then echo "capturas/$1.png"; else echo "ERROR: no se guardo $1"; fi
