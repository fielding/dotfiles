#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Volume Indicator - Shows current volume level
# Click to toggle mute
# ─────────────────────────────────────────────────────────────────────────────

sketchybar --add item volume right \
           --set volume icon.font="Hack Nerd Font:Regular:14.0" \
                        icon.color=$COLOR_FG_DIM \
                        label.font="SF Mono:Medium:11.0" \
                        label.color=$COLOR_FG \
                        label.drawing=off \
                        background.color=$COLOR_BG_LIGHT \
                        script="$PLUGIN_DIR/volume.sh" \
                        click_script="osascript -e 'set volume output muted not (output muted of (get volume settings))' && sketchybar --trigger volume_change" \
           --subscribe volume volume_change
