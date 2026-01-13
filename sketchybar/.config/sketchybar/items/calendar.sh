#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Calendar - Next meeting with countdown
# Click to open meeting link (Google Meet/Zoom)
# ─────────────────────────────────────────────────────────────────────────────

sketchybar --add item calendar right \
           --set calendar icon="󰃭" \
                          icon.font="Hack Nerd Font:Regular:14.0" \
                          icon.color=$COLOR_FG_DIM \
                          label.font="SF Mono:Medium:11.0" \
                          label.color=$COLOR_FG \
                          background.color=$COLOR_BG_LIGHT \
                          update_freq=60 \
                          script="$PLUGIN_DIR/calendar.sh" \
                          click_script="$PLUGIN_DIR/calendar.sh --click"
