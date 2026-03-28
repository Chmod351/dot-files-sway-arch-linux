#!/bin/bash

TARGET="$1"
# 1. Obtener la ruta absoluta de donde está ESTE script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 2. Definir la ruta de los módulos usando esa base
MODULES_DIR="$SCRIPT_DIR/modules" 

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

# 3. PAUSA PARA ANÁLISIS
echo ""
echo "[FASE 4] Intervención manual requerida"
echo "Revisá los archivos en: $OP_DIR"
echo ""
echo "Sugerido:"
echo "  - expuestos.txt"
echo "  - ips.txt"
echo "  - whois_ips.txt"
echo ""


read -p "Presioná ENTER para continuar con análisis manual..."
# MOSTRAR TARGETS DISPONIBLES
echo ""
echo "[+] Targets disponibles:"
nl -w2 -s'. ' "$OP_DIR/expuestos.txt"


# 4. SELECCIÓN DE TARGET
echo ""
echo "[FASE 5] Selección de objetivo"
read -p "Ingresá URL o dominio: " SELECTED_URL

if [[ -z "$SELECTED_URL" ]]; then
    echo "[-] No se ingresó ningún target. Saliendo."
    exit 1
fi

# 5. HTTP (low-medium noise)
echo ""
echo "[FASE 6] HTTP HEADERS"
bash "$MODULES_DIR/http.sh" "$SELECTED_URL"

# 6. EXTRAER HOST PARA NMAP
HOST=$(echo "$SELECTED_URL" | sed 's|http[s]*://||')

# 7. CONFIRMACIÓN ANTES DE NMAP
echo ""
read -p "¿Ejecutar Nmap sobre $HOST? (y/n): " CONFIRM

if [[ "$CONFIRM" == "y" ]]; then
    echo ""
    echo "[FASE 6] PORT SCAN"
    bash "$MODULES_DIR/ports.sh" "$HOST"
else
    echo "[INFO] Nmap cancelado."
fi

echo ""
echo "--- [ FIN ] ---"
