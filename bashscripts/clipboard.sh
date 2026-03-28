#!/bin/bash

if [ "\$1" == "copy" ]; then
  cliphist list | wofi --show -p "copy" | cliphist decode | wl-copy
elif [ "\$1" == "delete" ]; then
  cliphist list | wofi --show -p "delete" | cliphist delete && pkill -RTMIN+9 waybar
elif [ "\$1" == "delete-all" ]; then
  rm -f ~/.cache/cliphist/db; pkill -RTMIN+9 waybar
fi

