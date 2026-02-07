#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Calendar - Next meeting with countdown
# Click to open meeting link (Google Meet/Zoom)
# ─────────────────────────────────────────────────────────────────────────────

# Calendar info (dynamic) - added first so it appears to the RIGHT
sketchybar --add item calendar right \
           --set calendar icon="11h" \
                          icon.font="Helvetica Neue:Condensed Black:14.0" \
                          icon.color=$COLOR_FG \
                          icon.padding_left=6 \
                          icon.padding_right=0 \
                          label="No meetings" \
                          label.font="Inconsolata Nerd Font:Regular:13.0" \
                          label.color=$COLOR_FG_DIM \
                          label.padding_left=6 \
                          update_freq=60 \
                          script="$PLUGIN_DIR/calendar.sh" \
                          click_script="$PLUGIN_DIR/calendar.sh --click"

# Calendar icon (static) - added after so it appears to the LEFT
sketchybar --add item calendar_icon right \
           --set calendar_icon icon="" \
                          icon.font="Hack Nerd Font:Bold:14.0" \
                          icon.color=$COLOR_FG_DIM \
                          icon.padding_left=10 \
                          icon.padding_right=6 \
                          label.drawing=off
