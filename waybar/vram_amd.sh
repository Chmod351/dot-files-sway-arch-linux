#!/bin/bash

# Ruta de tu GPU AMD (RX 6600)
GPU_PATH="/sys/class/hwmon/hwmon1/device"

# Extracción de datos
if [ -f "$GPU_PATH/mem_info_vram_used" ]; then
    USED_RAW=$(cat "$GPU_PATH/mem_info_vram_used")
    TOTAL_RAW=$(cat "$GPU_PATH/mem_info_vram_total")
else
    USED_RAW=$(cat "$GPU_PATH/vram_used" 2>/dev/null || echo 0)
    TOTAL_RAW=$(cat "$GPU_PATH/vram_total" 2>/dev/null || echo 0)
fi

# Conversión a MiB (Ajustado para kernels de Arch)
USED=$(( USED_RAW / 1024 / 1024 ))
TOTAL=$(( TOTAL_RAW / 1024 / 1024 ))

# Fallback si el kernel ya entrega en KiB
if [ "$USED" -eq 0 ] && [ "$USED_RAW" -gt 0 ]; then
    USED=$(( USED_RAW / 1024 ))
    TOTAL=$(( TOTAL_RAW / 1024 ))
fi

# Cálculo de porcentaje para la lógica de color
PERC=$(( 100 * USED / TOTAL ))

# --- JERARQUÍA DE CLASES ---
CLASS="low"
if [ "$PERC" -ge 85 ]; then
    CLASS="critical"
elif [ "$PERC" -ge 60 ]; then
    CLASS="medium"
fi

# Salida JSON compatible con Waybar
echo "{\"text\": \"gpu ${USED}MB\", \"tooltip\": \"Uso de VRAM: ${PERC}% de ${TOTAL}MB\", \"class\": \"$CLASS\"}"
