#!/bin/bash

# Configuración de ruta
DESTINO="/mnt/data1/Música"

# Verificar si el disco está montado
if [ ! -d "$DESTINO" ]; then
    echo "ERROR: El disco /mnt/data1 no está montado."
    exit 1
fi

# Pedir la URL si no se pasó como argumento
URL=$1
if [ -z "$URL" ]; then
    read -p "Pegá la URL de YouTube (Video o Playlist): " URL
fi

echo "--- Iniciando descarga en $DESTINO ---"

# Ejecutar yt-dlp con esteroides
yt-dlp -x \
    --audio-format mp3 \
    --audio-quality 0 \
    --embed-metadata \
    --embed-thumbnail \
    --paths "$DESTINO" \
    -o "%(title)s.%(ext)s" \
    "$URL"

echo "--- Proceso finalizado. Música guardada en $DESTINO ---"
