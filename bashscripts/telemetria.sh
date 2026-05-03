#!/bin/bash

# --- DETECCIÓN DINÁMICA DE RUTAS (Escalabilidad) ---
# Buscamos el índice correcto para CPU y GPU basándonos en el nombre del driver
CPU_PATH=$(for d in /sys/class/hwmon/hwmon*; do [ -f "$d/name" ] && grep -q "coretemp" "$d/name" && echo "$d" && break; done)
GPU_PATH=$(for d in /sys/class/hwmon/hwmon*; do [ -f "$d/name" ] && grep -q "amdgpu" "$d/name" && echo "$d" && break; done)

# Fallback por si el sensor no está disponible (evita que el JSON rompa la barra)
if [ -z "$CPU_PATH" ] || [ -z "$GPU_PATH" ]; then
    echo "{\"text\": \"ERR\", \"tooltip\": \"Sensores no detectados\"}"
    exit 1
fi

# --- EXTRACCIÓN DE DATOS ---

# CPU - Usando la ruta detectada dinámicamente
CPU_PKG=$(cat ${CPU_PATH}/temp1_input | awk '{print $1/1000}')
C0=$(cat ${CPU_PATH}/temp2_input | awk '{print $1/1000}')
C1=$(cat ${CPU_PATH}/temp3_input | awk '{print $1/1000}')
C2=$(cat ${CPU_PATH}/temp4_input | awk '{print $1/1000}')
C3=$(cat ${CPU_PATH}/temp5_input | awk '{print $1/1000}')

# GPU - Usando la ruta detectada dinámicamente
GPU_EDGE=$(cat ${GPU_PATH}/temp1_input | awk '{print $1/1000}')
GPU_JUNC=$(cat ${GPU_PATH}/temp2_input | awk '{print $1/1000}')
GPU_FAN=$(cat ${GPU_PATH}/fan1_input)

# VRAM - Corregida la ruta duplicada /class/class/
VRAM_USED_RAW=$(cat /sys/class/drm/card0/device/mem_info_vram_used)
VRAM_USED=$(echo "$VRAM_USED_RAW" | awk '{printf "%.2f", $1/1024/1024/1024}') # En GiB

# --- LÓGICA DE ESTADO ---

TITULO="<span color='#ff8700'><b>── SYSTEM STATUS ──</b></span>"
SEP="<span color='#555555'>──────────────────────</span>"
LIMITE=80
ESTADO=""

# Convertimos a entero para comparar
CPU_INT=$(printf "%.0f" "$CPU_PKG")
GPU_INT=$(printf "%.0f" "$GPU_EDGE")

if [ "$CPU_INT" -ge "$LIMITE" ] || [ "$GPU_INT" -ge "$LIMITE" ]; then
    ESTADO="critical"
fi

# --- FORMATEO PANGO (NERV Style) ---

TOOLTIP="<tt>${TITULO}\n"
TOOLTIP+="<span color='#af8700'>󰻠 CPU Cores:</span>\n"
TOOLTIP+="  Core 0:  ${C0}°C\n"
TOOLTIP+="  Core 1:  ${C1}°C\n"
TOOLTIP+="  Core 2:  ${C2}°C\n"
TOOLTIP+="  Core 3:  ${C3}°C\n"
TOOLTIP+="${SEP}\n"
TOOLTIP+="<span color='#af5f00'>󰢮 GPU Status:</span>\n"
TOOLTIP+="  Uso:       ${VRAM_USED} GB \n"
TOOLTIP+="  Edge:      ${GPU_EDGE}°C\n"
TOOLTIP+="  Junction:  ${GPU_JUNC}°C\n"
TOOLTIP+="  Fans:      ${GPU_FAN} RPM</tt>"

# Texto de la barra
TEXTO="󰻠 ${CPU_PKG}°C | 󰢮 ${GPU_EDGE}°C"

# Output JSON para Waybar/Swaybar
echo "{\"text\": \"$TEXTO\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$ESTADO\"}"
