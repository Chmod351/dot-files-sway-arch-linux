#!/bin/bash

TARGET="$1"
BASEDIR="$HOME/Operaciones"
OP_DIR="$BASEDIR/$TARGET"

# Fuentes de entrada
INPUT_JSON="$OP_DIR/lowNoice.json"
WHOIS_JSON="$OP_DIR/whois_ips.json"
OUTPUT_FILE="$OP_DIR/intel.json"

if [[ ! -f "$INPUT_JSON" ]]; then
    echo "[-] Error: No existe el reporte de la Fase 1 ($INPUT_JSON)"
    exit 1
fi

echo "----------------------------------------------------"
echo "[INTEL] Enriqueciendo datos técnicos para $TARGET..."
echo "----------------------------------------------------"
# Inicializar como Objeto si no existe
if [ ! -f "$OUTPUT_FILE" ] || [ ! -s "$OUTPUT_FILE" ]; then
    echo "{}" > "$OUTPUT_FILE"
fi

# Extraer pares dominio/ip del JSON de Fase 1
jq -r '.subdomains[] | "\(.host) \(.ip)"' "$INPUT_JSON" | while read -r domain ip; do

    echo "[+] Procesando Intel: $domain ($ip)"

    # --- ASN (Vía DNS lookup - Rápido y confiable) ---
    rev_ip=$(echo $ip | awk -F. '{print $4"."$3"."$2"."$1}')
    asn_raw=$(dig +short "${rev_ip}.origin.asn.cymru.com" TXT | tr -d '"')
    asn=$(echo $asn_raw | awk -F'|' '{print "AS"$1}' | xargs)
    [[ -z "$asn" || "$asn" == "AS" ]] && asn="AS_UNKNOWN"

    # --- PROVIDER & COUNTRY (Extraer del WHOIS_JSON si existe) ---
    # En lugar de parsear archivos TXT, leemos el JSON que ya limpiamos en la Fase 2
    if [[ -f "$WHOIS_JSON" ]]; then
        provider=$(jq -r --arg dom "$domain" '.[$dom].whois.ip_info.org // "Unknown"' "$WHOIS_JSON")
        country=$(jq -r --arg dom "$domain" '.[$dom].whois.ip_info.country // "Unknown"' "$WHOIS_JSON")
    else
        provider="Unknown"
        country="Unknown"
    fi

    # --- INYECCIÓN EN OBJETO MAESTRO ---
    jq --arg dom "$domain" \
       --arg ip "$ip" \
       --arg asn "$asn" \
       --arg prov "$provider" \
       --arg count "$country" \
       '.[$dom] = {
           "ip": $ip,
           "infra": {
               "asn": $asn,
               "provider": $prov,
               "country": $count
           }
       }' "$OUTPUT_FILE" > "$OUTPUT_FILE.tmp" && mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"

done

echo "[DONE] Intel consolidado como Objeto en: $OUTPUT_FILE"
