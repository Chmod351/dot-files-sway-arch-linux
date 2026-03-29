#!/bin/bash

TARGET="$1"
BASEDIR="$HOME/Operaciones"
REPORT="$BASEDIR/$TARGET/MASTER_REPORT.json"

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
NC='\e[0m'

echo -e "${BLUE}=== DASHBOARD OPERATIVO: $TARGET ===${NC}\n"

# Encabezado
printf "%-30s | %-15s | %-15s | %-15s\n" "HOST" "IP" "STATUS" "NETNAME"
echo "---------------------------------------------------------------------------------------"

# Iteramos usando base64 para evitar que los espacios o saltos de línea rompan el bucle
for row in $(jq -r ".\"$TARGET\".subdomains[] | @base64" "$REPORT"); do
    
    # Función de extracción segura: Pasamos el contenido por STDIN para que JQ no busque archivos
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

    # Lógica de color de Status
    [[ "$STATUS" == "exposed" ]] && S_COL="${RED}${STATUS}${NC}" || S_COL="${GREEN}${STATUS}${NC}"

    # 1. Fila Principal
    printf "%-39b | %-15s | %-24b | %-15s\n" "$CYAN$HOST$NC" "$IP" "$S_COL" "$NETNAME"

    # 2. Puertos indentados
    echo -e "${YELLOW}   [PORTS]${NC}"
    # Extraemos y formateamos puertos en un solo paso
    PORTS_OUTPUT=$(echo "$decode_row" | jq -r '.ports[]? | "     - \(.port)/\(.service) (\(.version))"')
    
    if [[ -n "$PORTS_OUTPUT" ]]; then
        echo "$PORTS_OUTPUT"
    else
        echo -e "     ${NC}(No ports detected)"
    fi
    
    # 3. Bloque Intel
    echo -e "${BLUE}   [INTEL]${NC}"
    printf "     Org: %-30s | Country: %s\n" "$ORG" "$COUNTRY"
    printf "     Reg: %-30s | Created: %s\n" "$REGISTRAR" "$CREATED"
    
    echo -e "---------------------------------------------------------------------------------------"
done

echo -e "\n${BLUE}=== FIN DEL REPORTE ===${NC}"
