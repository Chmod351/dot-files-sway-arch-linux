#!/bin/bash

last=""

while true; do
    current=$(cmus-remote -Q | grep "tag title")

    if [ "$current" != "$last" ]; then
        ~/.dotfiles/bashscripts/cmus_notificacion.sh
        last="$current"
    fi

    sleep 2
done
