#!/bin/bash

TARGET="$1"
BASEDIR="$HOME/Operaciones"
OP_DIR="$BASEDIR/$TARGET"

# Fuente de verdad: El JSON de la Fase 1
INPUT_JSON="$OP_DIR/lowNoice.json"
OUTPUT_FILE="$OP_DIR/whois_ips.json"

# Verificación de seguridad
if [[ ! -f "$INPUT_JSON" ]]; then
    echo "[-] Error: No existe el reporte de la Fase 1 ($INPUT_JSON)"
    exit 1
fi

echo "--------------------------------------------------------------------------"
echo "-------[WHOIS] Enriqueciendo infraestructura desde JSON...----------------"
echo "--------------------------------------------------------------------------"

# Inicializamos como OBJETO vacío si no existe
if [ ! -f "$OUTPUT_FILE" ] || [ ! -s "$OUTPUT_FILE" ]; then
    echo "{}" > "$OUTPUT_FILE"
fi

# Extraemos host e ip directamente del JSON de la Fase 1 para iterar
jq -r '.subdomains[] | "\(.host) \(.ip)"' "$INPUT_JSON" | while read -r domain ip; do

    echo "[+] Analizando WHOIS: $domain ($ip)"

    # --- PARSE WHOIS IP ---
    IP_DATA=$(whois "$ip" 2>/dev/null)
    NET=$(echo "$IP_DATA" | awk -F': *' 'tolower($1) ~ /netname/ {print $2}' | head -n1 | xargs)
    ORG=$(echo "$IP_DATA" | awk -F': *' 'tolower($1) ~ /orgname|organization|descr/ {print $2}' | head -n1 | xargs)
    COUNTRY=$(echo "$IP_DATA" | awk -F': *' 'tolower($1) ~ /country/ {print $2}' | head -n1 | xargs)
    
    # --- PARSE WHOIS DOMAIN ---
    DOM_DATA=$(whois "$domain" 2>/dev/null)
    REGISTRAR=$(echo "$DOM_DATA" | awk -F': *' 'tolower($1) ~ /registrar/ {print $2}' | head -n1 | xargs)
    CREATED=$(echo "$DOM_DATA" | awk -F': *' 'tolower($1) ~ /creation date|created/ {print $2}' | head -n1 | xargs)

    # --- INYECCIÓN QUIRÚRGICA CON JQ ---
    # Usamos el dominio como llave maestra para que el "Merge" final sea automático
    jq --arg dom "$domain" \
       --arg ip "$ip" \
       --arg net "${NET:-unknown}" \
       --arg org "${ORG:-unknown}" \
       --arg count "${COUNTRY:-unknown}" \
       --arg reg "${REGISTRAR:-unknown}" \
       --arg cre "${CREATED:-unknown}" \
       '.[$dom] = {
           "ip": $ip,
           "whois": {
               "ip_info": { "netname": $net, "org": $org, "country": $count },
               "domain_info": { "registrar": $reg, "created": $cre }
           }
       }' "$OUTPUT_FILE" > "$OUTPUT_FILE.tmp" && mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"

done

echo "[DONE] Whois consolidado en: $OUTPUT_FILE"
