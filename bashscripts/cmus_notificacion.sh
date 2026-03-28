#!/bin/bash

# Extraer info de cmus-remote
artist=$(cmus-remote -Q | grep 'tag artist' | cut -d ' ' -f 3-)
title=$(cmus-remote -Q | grep 'tag title' | cut -d ' ' -f 3-)
album=$(cmus-remote -Q | grep 'tag album' | cut -d ' ' -f 3-)

# Si no hay tags, usar el nombre del archivo
if [ -z "$title" ]; then
    title=$(cmus-remote -Q | grep 'file' | rev | cut -d '/' -f 1 | rev)
fi

# Enviar la notificación (con icono de música si tenés)
notify-send -i audio-speakers "Cmus: Reproduciendo" "$title\n$artist — $album"
