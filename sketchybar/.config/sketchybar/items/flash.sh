#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Flash - Brief visual feedback when keybinds are triggered
# ─────────────────────────────────────────────────────────────────────────────

sketchybar --add item flash right \
           --set flash icon.drawing=off \
                       label="" \
                       label.font="Helvetica Neue:Condensed Black:14.0" \
                       label.color=$COLOR_BG \
                       label.padding_left=10 \
                       label.padding_right=10 \
                       background.color=$COLOR_FG \
                       background.corner_radius=0 \
                       background.height=32 \
                       drawing=off \
                       script="$PLUGIN_DIR/flash.sh" \
           --subscribe flash keybind_flash
