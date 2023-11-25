#!/bin/bash
cliphist list | wofi --show -p "copy" | cliphist decode | wl-copy

