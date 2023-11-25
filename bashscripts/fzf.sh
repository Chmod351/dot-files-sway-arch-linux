#!/bin/bash

# Usa fzf para buscar archivos, excluyendo node_modules
archivo=$(find . -type d \( -name node_modules -o -name .git \) -prune -o -type f -print | fzf)

# Mueve al directorio del archivo seleccionado
cd "$(dirname "$archivo")"

