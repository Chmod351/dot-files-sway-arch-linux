#!/bin/bash

BASEDIR="$HOME/Operaciones"
TARGET=$1

if [ -z "$TARGET" ]; then
    echo -e "\e[31m[!] Uso: ./reconocimiento.sh dominio.com\e[0m"
    exit 1
fi

# Definimos la ruta absoluta de la operación
OP_DIR="$BASEDIR/$TARGET"

echo -e "\n\e[34m[+] Iniciando Fase de Radar para: $TARGET\e[0m"
echo -e "[+] Los datos se guardarán en: $OP_DIR"

# Creamos la carpeta de la operación
mkdir -p "$OP_DIR"

# 1. ENUMERACIÓN PASIVA
echo "[+] Buscando subdominios de forma pasiva..."
# Redirigimos todo a la ruta absoluta $OP_DIR
subfinder -d "$TARGET" -silent > "$OP_DIR/subs_raw.txt"
assetfinder --subs-only "$TARGET" >> "$OP_DIR/subs_raw.txt"
sort -u "$OP_DIR/subs_raw.txt" > "$OP_DIR/subdominios.txt"
rm "$OP_DIR/subs_raw.txt"

# 2. FILTRADO DE SUPERVIVIENTES
echo "[+] Comprobando cuáles responden (HTTP/HTTPS)..."
cat "$OP_DIR/subdominios.txt" | httprobe > "$OP_DIR/vivos.txt"

# 3. DETECCIÓN DE "ESCUDOS"
echo "[+] Analizando servidores 'desnudos'..."
# Limpiamos el archivo de objetivos antes de empezar
> "$OP_DIR/objetivos_nmap.txt"

while read -r url; do
    server=$(curl -I -s --connect-timeout 5 "$url" | grep -i "server:" | awk '{print $2}' | tr -d '\r')
    if [[ "$server" == *"cloudflare"* ]]; then
        echo "[-] $url está protegido por Cloudflare."
    else
        echo -e "\e[32m[!] $url -> SERVIDOR EXPUESTO: $server\e[0m"
        echo "$url" >> "$OP_DIR/objetivos_nmap.txt"
    fi
done < "$OP_DIR/vivos.txt"

echo -e "\n\e[36m[DONE] Proceso terminado. Datos guardados en: $OP_DIR\e[0m"
