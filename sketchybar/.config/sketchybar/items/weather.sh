#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Weather - Shows current temp and conditions
# Click to open weather.com
# ─────────────────────────────────────────────────────────────────────────────

sketchybar --add item weather right \
           --set weather icon.font="Hack Nerd Font:Bold:16.0" \
                         icon.color=$COLOR_FG_DIM \
                         label.font="Helvetica Neue:Condensed Black:14.0" \
                         label.color=$COLOR_FG \
                         background.color=$COLOR_BG_LIGHT \
                         update_freq=900 \
                         script="$PLUGIN_DIR/weather.sh" \
                         click_script="open 'https://wttr.in'"
