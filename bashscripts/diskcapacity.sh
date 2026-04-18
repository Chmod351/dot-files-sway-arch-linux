#!/bin/bash

# --- EXTRACCIÓN DE DATOS ---
# Función para sacar el % de uso de forma segura
get_usage() {
    df -h "$1" 2>/dev/null | awk 'NR==2 {print $5}'
}

# Función para sacar GB Libres / Total
get_detail() {
    df -h "$1" 2>/dev/null | awk 'NR==2 {printf "%s / %s", $4, $2}'
}

ROOT_USE=$(get_usage "/")
ARCH_USE=$(get_usage "/mnt/archivos")
DATA_USE=$(get_usage "/mnt/data1")

# --- FORMATEO DEL TOOLTIP ---
TITULO="<span color='#ff8700'><b>── CAPACIDAD DE ALMACENAMIENTO ──</b></span>"
SEP="<span color='#555555'>────────────────────────────────</span>"

TOOLTIP="<tt>${TITULO}\n"
TOOLTIP+="<span color='#87af00'>󰋊 Sistema (/):</span>\n"
TOOLTIP+="   Uso: ${ROOT_USE}  [$(get_detail "/")]\n"
TOOLTIP+="${SEP}\n"
TOOLTIP+="<span color='#87af00'>󰋊 Archivos:</span>\n"
TOOLTIP+="   Uso: ${ARCH_USE:-OFF}  [$(get_detail "/mnt/archivos")]\n"
TOOLTIP+="${SEP}\n"
TOOLTIP+="<span color='#87af00'>󰋊 Data1:</span>\n"
TOOLTIP+="   Uso: ${DATA_USE:-OFF}  [$(get_detail "/mnt/data1")]</tt>"

# --- TEXTO DE LA BARRA ---
# Solo mostramos la raíz para mantener el minimalismo
TEXTO=" ${ROOT_USE}"

echo "{\"text\": \"$TEXTO\", \"tooltip\": \"$TOOLTIP\"}"
