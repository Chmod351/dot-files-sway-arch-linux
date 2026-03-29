#!/bin/bash

TARGET="$1"
# 1. Obtener la ruta absoluta de donde está ESTE script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 2. Definir la ruta de los módulos usando esa base
MODULES_DIR="$SCRIPT_DIR/modules" 
PROCESSORS_DIR="$SCRIPT_DIR/processors"
OUTPUT_DIR="$SCRIPT_DIR/output"

BASEDIR="$HOME/Operaciones"
OP_DIR="$BASEDIR/$TARGET"

if [[ -z "$TARGET" ]]; then
    echo "Uso: $0 <target>"
    exit 1
fi

echo "--- [ RECON: $TARGET ] ---"

# 1. LOW NOISE
echo "[FASE 1] Low Noise..."
bash "$MODULES_DIR/lowNoice.sh" "$TARGET"
# 2. WHOIS (enriquecimiento automático)
echo ""
echo "[FASE 2] WHOIS sobre resultados..."
bash "$MODULES_DIR/whois.sh" "$TARGET"

# cruzamos los daatos de whois 

echo "[FASE 3] Correlacion..."
bash "$MODULES_DIR/intel.sh" "$TARGET" 
echo "----------------------------------------------"

# ----------------------------------------------
# 3. PAUSA PARA ANÁLISIS
echo ""
echo "[FASE 4] Intervención manual requerida"
echo "Revisá el archivo maestro en: $OP_DIR/lowNoice.json"
echo ""

# 1. Extraemos la lista de expuestos para mostrarla en pantalla (nl lee de la tubería)
echo "[+] Targets EXPUESTOS detectados (sin CDN):"
EXPOSED_LIST=$(jq -r ".\"$TARGET\".subdomains[] | select(.status == \"exposed\") | .host" "$OP_DIR/lowNoice.json")

if [[ -n "$EXPOSED_LIST" ]]; then
    echo "$EXPOSED_LIST" | nl -w2 -s'. '
else
    echo "[!] No se detectaron targets expuestos directamente."
fi

echo ""
read -p "Presioná ENTER para continuar con análisis manual..."

# ----------------------------------------------
# 4. SELECCIÓN DE TARGET
echo ""
echo "[FASE 5] Selección de objetivo"

# 2. Extraemos el primer host expuesto de la variable que ya tenemos en memoria
DEFAULT_TARGET=$(echo "$EXPOSED_LIST" | head -n 1)

read -p "Ingresá URL o dominio [$DEFAULT_TARGET]: " SELECTED_URL

# Si el usuario le da ENTER, usamos el default. Si no hay default, usamos el TARGET original.
SELECTED_URL=${SELECTED_URL:-${DEFAULT_TARGET:-$TARGET}}

echo "[+] Objetivo seleccionado: $SELECTED_URL"

# 6. EXTRAER HOST PARA NMAP
HOST=$(echo "$SELECTED_URL" | sed 's|http[s]*://||')

# 7. CONFIRMACIÓN ANTES DE NMAP
echo ""
read -p "¿Ejecutar Nmap sobre $HOST? (y/n): " CONFIRM

if [[ "$CONFIRM" == "y" ]]; then
    echo "//------------------------------//"
    echo "[FASE 7] PORT SCAN"
    bash "$MODULES_DIR/ports.sh" "$HOST"
else
    echo "[INFO] Nmap cancelado."
fi

echo "[+] Generando reporte maestro final..."
bash "$PROCESSORS_DIR/merger.sh" "$TARGET"

echo "[+] Lanzando Dashboard..."
bash "$SCRIPT_DIR/output/dashboard.sh" "$TARGET"

echo -e "\n--- [ OPERACIÓN COMPLETADA ] ---"

echo ""
echo "--- [ FIN ] ---"
