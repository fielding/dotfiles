#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Volume Plugin - Updates volume icon based on level/mute state
# ─────────────────────────────────────────────────────────────────────────────

COLOR_FG_DIM=0xff6272a4
COLOR_ACCENT=0xffff0074

# Get volume info
VOLUME=$(osascript -e 'output volume of (get volume settings)')
MUTED=$(osascript -e 'output muted of (get volume settings)')

if [ "$MUTED" = "true" ]; then
  ICON="󰖁"
  COLOR=$COLOR_ACCENT
elif [ "$VOLUME" -eq 0 ]; then
  ICON="󰕿"
  COLOR=$COLOR_FG_DIM
elif [ "$VOLUME" -lt 33 ]; then
  ICON="󰕿"
  COLOR=$COLOR_FG_DIM
elif [ "$VOLUME" -lt 66 ]; then
  ICON="󰖀"
  COLOR=$COLOR_FG_DIM
else
  ICON="󰕾"
  COLOR=$COLOR_FG_DIM
fi

sketchybar --set $NAME icon="$ICON" icon.color=$COLOR
