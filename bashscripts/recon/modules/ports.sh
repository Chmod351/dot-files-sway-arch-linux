#!/bin/bash

TARGET="$1"
BASEDIR="$HOME/Operaciones"
OP_DIR="$BASEDIR/$TARGET"
OUTPUT="$OP_DIR/intel.json"
# Guardamos el XML en la carpeta de la operación, no en /tmp, para evitar líos de limpieza
TMP_XML="$OP_DIR/nmap_raw.xml"

if [[ -z "$TARGET" ]]; then
    echo "[!] Uso: $0 target"
    exit 1
fi

if [ ! -f "$OUTPUT" ]; then
    echo "[-] Error: No existe $OUTPUT. Corre la fase de Intel primero."
    exit 1
fi

echo "[+] Escaneando con Nmap (sudo requerido)..."

# Ejecutamos Nmap. El output XML irá a la carpeta de la OP.
sudo nmap -sS -sV --top-ports 1000 --open -Pn "$TARGET" -oX "$TMP_XML" > /dev/null

# TRUCO DE OPERADOR: Cambiamos el dueño del XML para que nuestro usuario pueda leerlo
sudo chown $USER:$USER "$TMP_XML"

echo "[+] Extrayendo servicios del XML..."

# Usamos una forma más robusta de extraer los puertos en una sola línea de JQ/Grep 
# (XML es un asco para awk solo, mejor algo más directo)
PORTS_JSON=$(xmllint --xpath '//port[state/@state="open"]' "$TMP_XML" 2>/dev/null | \
awk '
BEGIN { printf "{\"ports\": [" }
{
    # Extraer portid, service name y product/version si existen
    if (match($0, /portid="([0-9]+)"/)) port=substr($0, RSTART+8, RLENGTH-9)
    if (match($0, /name="([^"]+)"/)) service=substr($0, RSTART+6, RLENGTH-7)
    
    # Manejo de producto y versión
    prod="unknown"; ver=""
    if (match($0, /product="([^"]+)"/)) prod=substr($0, RSTART+9, RLENGTH-10)
    if (match($0, /version="([^"]+)"/)) ver=substr($0, RSTART+9, RLENGTH-10)
    
    full_ver = prod (ver != "" ? " " ver : "")
    
    if (port != "") {
        if (NR > 1) printf ","
        printf "{\"port\":%d,\"service\":\"%s\",\"version\":\"%s\"}", port, service, full_ver
    }
}
END { print "]}" }')

echo "[+] Inyectando en $OUTPUT..."

# Inyectar usando JQ de forma segura
# Nota: Ajustamos el filtro para que busque dentro del array directamente
jq --arg target "$TARGET" \
   --argjson ports "$PORTS_JSON" \
   '.[$target].ports = $ports.ports' \
   "$OUTPUT" > "$OUTPUT.tmp" && mv "$OUTPUT.tmp" "$OUTPUT"
# Opcional: Limpiar el XML pesado pero dejar el JSON sagrado
rm "$TMP_XML"

echo "[DONE] Servicios actualizados en $OUTPUT"
