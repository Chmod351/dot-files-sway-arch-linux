#!/bin/bash

# CPU - HWMon3 (Rutas auditadas)
CPU_PKG=$(cat /sys/class/hwmon/hwmon3/temp1_input | awk '{print $1/1000}')
C0=$(cat /sys/class/hwmon/hwmon3/temp2_input | awk '{print $1/1000}')
C1=$(cat /sys/class/hwmon/hwmon3/temp3_input | awk '{print $1/1000}')
C2=$(cat /sys/class/hwmon/hwmon3/temp4_input | awk '{print $1/1000}')
C3=$(cat /sys/class/hwmon/hwmon3/temp5_input | awk '{print $1/1000}')

# GPU - HWMon1 (Rutas auditadas)
GPU_EDGE=$(cat /sys/class/hwmon/hwmon1/temp1_input | awk '{print $1/1000}')
GPU_JUNC=$(cat /sys/class/hwmon/hwmon1/temp2_input | awk '{print $1/1000}')
GPU_FAN=$(cat /sys/class/hwmon/hwmon1/fan1_input)


VRAM_USED_RAW=$(cat /sys/class/class/drm/card0/device/mem_info_vram_used)
VRAM_USED=$(echo "$VRAM_USED_RAW" | awk '{printf "%.2f", $1/1024/1024/1024}') # En GiB
# Formateo con Pango para que se vea Monoespaciado y con Colores NERV
# Usamos <tt> para forzar Teletype (mono) y <span> para el color
TITULO="<span color='#ff8700'><b>── SYSTEM STATUS ──</b></span>"
SEP="<span color='#555555'>──────────────────────</span>"
LIMITE=80
ESTADO=""

# Verificamos si CPU o GPU superan el límite (usamos printf para convertir a entero)
CPU_INT=$(printf "%.0f" "$CPU_PKG")
GPU_INT=$(printf "%.0f" "$GPU_EDGE")

if [ "$CPU_INT" -ge "$LIMITE" ] || [ "$GPU_INT" -ge "$LIMITE" ]; then
    ESTADO="critical"
fi

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

# Texto de la barra (Sigue minimalista pero potente)
TEXTO="󰻠 ${CPU_PKG}°C | 󰢮 ${GPU_EDGE}°C"

# Output JSON
echo "{\"text\": \"$TEXTO\", \"tooltip\": \"$TOOLTIP\", \"class\": \"$ESTADO\"}"
