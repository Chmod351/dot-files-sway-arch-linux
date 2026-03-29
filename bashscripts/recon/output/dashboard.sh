#!/bin/bash

TARGET="$1"
BASEDIR="$HOME/Operaciones"
REPORT="$BASEDIR/$TARGET/MASTER_REPORT.json"
VULNS_FILE="$BASEDIR/$TARGET/vulnerabilities.json" # <--- Referencia al nuevo archivo

if [[ ! -f "$REPORT" ]]; then
    echo -e "\e[31m[-] No se encontró el reporte maestro en $REPORT\e[0m"
    exit 1
fi

# Colores
GREEN='\e[32m'
RED='\e[31m'
CYAN='\e[36m'
YELLOW='\e[33m'
BLUE='\e[34m'
MAGENTA='\e[35m'
NC='\e[0m'

echo -e "${BLUE}=== DASHBOARD OPERATIVO: $TARGET ===${NC}\n"

# Encabezado
printf "%-30s | %-15s | %-15s | %-15s\n" "HOST" "IP" "STATUS" "NETNAME"
echo "---------------------------------------------------------------------------------------"

for row in $(jq -r ".\"$TARGET\".subdomains[] | @base64" "$REPORT"); do
    
    decode_row=$(echo "$row" | base64 --decode)
    
    _get() {
        echo "$decode_row" | jq -r "$1"
    }

    HOST=$(_get '.host')
    IP=$(_get '.ip')
    STATUS=$(_get '.status')
    NETNAME=$(_get '.whois.ip_info.netname // "N/A"')
    ORG=$(_get '.whois.ip_info.org // "N/A"')
    COUNTRY=$(_get '.whois.ip_info.country // "N/A"')
    REGISTRAR=$(_get '.whois.domain_info.registrar // "N/A"')
    CREATED=$(_get '.whois.domain_info.created // "N/A"')

    [[ "$STATUS" == "exposed" ]] && S_COL="${RED}${STATUS}${NC}" || S_COL="${GREEN}${STATUS}${NC}"

    # 1. Fila Principal
    printf "%-39b | %-15s | %-24b | %-15s\n" "$CYAN$HOST$NC" "$IP" "$S_COL" "$NETNAME"

    # 2. Puertos
    echo -e "${YELLOW}    [PORTS]${NC}"
    echo "$decode_row" | jq -r '.ports[]? | "     - \(.port)/\(.service) (\(.version))"'

    # --- NUEVA SECCIÓN: VULNERABILIDADES ---
    if [[ -f "$VULNS_FILE" ]]; then
        # Buscamos en el archivo de vulnerabilidades si hay algo para este host
        # (Asumiendo que el matcher guarda el link y el título)
        echo -e "${RED}    [VULNS]${NC}"
        
        # Filtramos las vulnerabilidades que coincidan con los servicios de este host
        # Para el MVP, si el matcher es general por target, mostramos las globales del target:
        VULN_DATA=$(jq -r '.matches[]? | "     - [!] \(.title)\n       Link: \(.link)"' "$VULNS_FILE" | head -n 4)
        
        if [[ -n "$VULN_DATA" ]]; then
            echo -e "$VULN_DATA"
        else
            echo -e "     ${GREEN}No known exploits found.${NC}"
        fi
    fi

    # 3. Bloque Intel
    echo -e "${BLUE}    [INTEL]${NC}"
    printf "     Org: %-30s | Country: %s\n" "$ORG" "$COUNTRY"
    printf "     Reg: %-30s | Created: %s\n" "$REGISTRAR" "$CREATED"
    
    echo -e "---------------------------------------------------------------------------------------"
done

echo -e "\n${BLUE}=== FIN DEL REPORTE ===${NC}"
