#!/bin/bash

TARGET="$1"
OUTPUT="intel.json"

# Obtener headers
HEADERS=$(curl -I -s -L --max-time 5 "$TARGET" 2>/dev/null)

# Extraer campos relevantes
SERVER=$(echo "$HEADERS" | awk -F': ' 'tolower($1)=="server" {print $2}' | tr -d '\r')
POWERED=$(echo "$HEADERS" | awk -F': ' 'tolower($1)=="x-powered-by" {print $2}' | tr -d '\r')
CONTENT=$(echo "$HEADERS" | awk -F': ' 'tolower($1)=="content-type" {print $2}' | tr -d '\r')
# Defaults (evita null rotos)
SERVER=${SERVER:-"unknown"}
POWERED=${POWERED:-"unknown"}
CONTENT=${CONTENT:-"unknown"}

# Si no existe el archivo base, crearlo
if [ ! -f "$OUTPUT" ]; then
  echo '{"targets":[]}' > "$OUTPUT"
fi

# Insertar en JSON con jq
jq --arg target "$TARGET" \
   --arg server "$SERVER" \
   --arg powered "$POWERED" \
   --arg content "$CONTENT" '
.targets |= map(
  if .domain == $target or .url == $target then
    .http = {
      server: $server,
      powered_by: $powered,
      content_type: $content
    }
  else . end
)
' "$OUTPUT" > tmp.json && mv tmp.json "$OUTPUT"
