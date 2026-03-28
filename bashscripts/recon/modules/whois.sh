#!/bin/bash

TARGET="$1"
BASEDIR="$HOME/Operaciones"
OP_DIR="$BASEDIR/$TARGET"
INPUT_FILE="$OP_DIR/ips.txt"
OUTPUT_FILE="$OP_DIR/whois_ips.json"

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "[-] No existe $INPUT_FILE"
    exit 1
fi

echo "[WHOIS] Analizando IPs..."

echo '{ "targets": [' > "$OUTPUT_FILE"

FIRST=1

awk '{
    for(i=1;i<=NF;i++) {
        if ($i ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/)
            print $1, $i
    }
}' "$INPUT_FILE" | sort -u | while read -r domain ip; do

    clean_domain=$(echo "$domain" | sed 's|http[s]*://||')

    # WHOIS IP PARSE
    IP_JSON=$(whois "$ip" 2>/dev/null | awk -F': *' '
    BEGIN {
        net="unknown"; org="unknown"; country="unknown"; city="unknown"
    }
    tolower($1) ~ /netname/ { net=$2 }
    tolower($1) ~ /orgname|organization/ { org=$2 }
    tolower($1) ~ /country/ { country=$2 }
    tolower($1) ~ /city/ { city=$2 }
    END {
        printf("{\"netname\":\"%s\",\"org\":\"%s\",\"country\":\"%s\",\"city\":\"%s\"}", net, org, country, city)
    }')

    # WHOIS DOMAIN PARSE
    DOMAIN_JSON=$(whois "$clean_domain" 2>/dev/null | awk -F': *' '
    BEGIN {
        registrar="unknown"; created="unknown"
    }
    tolower($1) ~ /registrar/ { registrar=$2 }
    tolower($1) ~ /creation date/ { created=$2 }
    END {
        printf("{\"registrar\":\"%s\",\"created\":\"%s\"}", registrar, created)
    }')

    # coma JSON
    if [[ $FIRST -eq 0 ]]; then
        echo "," >> "$OUTPUT_FILE"
    fi
    FIRST=0

    # escribir objeto
    cat >> "$OUTPUT_FILE" <<EOF
{
  "domain": "$clean_domain",
  "ip": "$ip",
  "ip_info": $IP_JSON,
  "domain_info": $DOMAIN_JSON
}
EOF

done

echo ']}' >> "$OUTPUT_FILE"

echo "[DONE] Output: $OUTPUT_FILE"
