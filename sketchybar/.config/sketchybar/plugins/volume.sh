#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Volume Plugin - Updates volume icon based on level/mute state
# ─────────────────────────────────────────────────────────────────────────────

source "$HOME/.config/sketchybar/colors.sh"

# Get volume info
VOLUME=$(osascript -e 'output volume of (get volume settings)')
MUTED=$(osascript -e 'output muted of (get volume settings)')

if [ "$MUTED" = "true" ]; then
  ICON="󰖁"
  COLOR=$COLOR_RED
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
