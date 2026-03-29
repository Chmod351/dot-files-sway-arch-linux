#!/bin/bash

TARGET="$1"
# Asegurate de usar la ruta completa si lo lanzás desde el orquestador
BASEDIR="$HOME/Operaciones"
OP_DIR="$BASEDIR/$TARGET"
OUTPUT="$OP_DIR/http.json"

if [[ -z "$TARGET" ]]; then
    echo "[!] Uso: $0 scanme.nmap.org"
    exit 1
fi

# 1. Preparación del entorno (Cimiento sólido)
mkdir -p "$OP_DIR"
if [ ! -f "$OUTPUT" ] || [ ! -s "$OUTPUT" ]; then
    echo "{}" > "$OUTPUT"
fi

echo "[+] Obteniendo headers de $TARGET..."

# 2. Obtener headers (Seguimos con el radar en bajo ruido)
HEADERS=$(curl -I -s -L --max-time 5 "$TARGET" 2>/dev/null)

# 3. Extraer campos con AWK (Limpiando retornos de carro \r)
SERVER=$(echo "$HEADERS" | awk -F': ' 'tolower($1)=="server" {print $2}' | tr -d '\r' | xargs)
POWERED=$(echo "$HEADERS" | awk -F': ' 'tolower($1)=="x-powered-by" {print $2}' | tr -d '\r' | xargs)
CONTENT=$(echo "$HEADERS" | awk -F': ' 'tolower($1)=="content-type" {print $2}' | tr -d '\r' | xargs)

# Fallbacks para no tener campos vacíos
SERVER=${SERVER:-"unknown"}
POWERED=${POWERED:-"unknown"}
CONTENT=${CONTENT:-"unknown"}

# 4. Inyección Atómica con JQ
# Nota: Quitamos el bloque que creaba {"targets":[]}
jq --arg target "$TARGET" \
   --arg server "$SERVER" \
   --arg powered "$POWERED" \
   --arg content "$CONTENT" \
   '.[$target].http = { 
       server: $server, 
       powered_by: ($powered | split(", ")), 
       content_type: $content 
   }' "$OUTPUT" > "$OUTPUT.tmp" && mv "$OUTPUT.tmp" "$OUTPUT"

echo "[DONE] HTTP Info inyectada en $OUTPUT"
