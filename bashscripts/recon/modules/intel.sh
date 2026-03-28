#!/bin/bash

TARGET="$1"
BASEDIR="$HOME/Operaciones"
OP_DIR="$BASEDIR/$TARGET"
IPS_FILE="$OP_DIR/ips.txt"
WHOIS_FILE="$OP_DIR/whois_ips.txt"
OUTPUT_FILE="$OP_DIR/intel.json"

# Asegurar que el directorio existe (Fix ruta)
mkdir -p "$OP_DIR"

if [[ ! -f "$IPS_FILE" || ! -f "$WHOIS_FILE" ]]; then
    echo "[-] Faltan archivos necesarios en $OP_DIR"
    exit 1
fi

echo "[INTEL] Generando intel.json..."

# Iniciar el array JSON
echo "[" > "$OUTPUT_FILE"

# Contador para manejar las comas del JSON
count=0
total_ips=$(awk '{for(i=1;i<=NF;i++) if ($i ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) count++} END {print count}' "$IPS_FILE")

awk '{for(i=1;i<=NF;i++) if ($i ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) print $1, $i}' "$IPS_FILE" | sort -u | \
while read -r domain ip; do
    count=$((count + 1))
    clean_domain=$(echo "$domain" | sed 's|http[s]*://||')

    # --- EXTRAER BLOQUE WHOIS Y LIMPIAR ESPACIOS ---
    block=$(awk "/$ip/{flag=1} flag{print} /----------------------/{flag=0}" "$WHOIS_FILE" | sed 's/^[[:space:]]*//')

    # --- ASN ---
    asn=$(echo "$block" | grep -oE 'AS[0-9]+' | head -n1)
    if [[ -z "$asn" ]]; then
        rev_ip=$(echo $ip | awk -F. '{print $4"."$3"."$2"."$1}')
        asn_raw=$(dig +short "${rev_ip}.origin.asn.cymru.com" TXT | tr -d '"')
        asn=$(echo $asn_raw | awk -F'|' '{print "AS"$1}' | xargs)
    fi
    [[ -z "$asn" ]] && asn="AS_UNKNOWN"

    # --- PROVIDER & COUNTRY (Extraídos del bloque) ---
    provider=$(echo "$block" | grep -iE "^(OrgName|Owner|NetName|descr):" | head -n1 | cut -d':' -f2- | xargs)
    country=$(echo "$block" | grep -i "^Country:" | head -n1 | cut -d':' -f2- | xargs)

    [[ -z "$provider" ]] && provider="Unknown Provider"
    [[ -z "$country" ]] && country="Unknown"

    # --- CONSTRUIR OBJETO ---
    # Usamos un heredoc limpio. La coma solo se pone si no es el último elemento.
    cat >> "$OUTPUT_FILE" <<EOF
  {
    "domain": "$clean_domain",
    "ip": "$ip",
    "asn": "$asn",
    "provider": "$provider",
    "country": "$country"
  }$( [[ $count -lt $total_ips ]] && echo "," )
EOF
done

echo "]" >> "$OUTPUT_FILE"
echo "[DONE] Intel consolidado en: $OUTPUT_FILE"
