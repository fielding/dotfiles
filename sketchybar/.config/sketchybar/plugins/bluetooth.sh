#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Bluetooth Plugin - Shows Bluetooth status and connected devices
# ─────────────────────────────────────────────────────────────────────────────

COLOR_FG_DIM=0xff6272a4
COLOR_CYAN=0xff5ce1ff

# Check if Bluetooth is on
BT_POWER=$(blueutil --power 2>/dev/null)

if [ "$BT_POWER" != "1" ]; then
  ICON="󰂲"
  COLOR=$COLOR_FG_DIM
else
  # Check for connected devices
  CONNECTED=$(blueutil --connected 2>/dev/null)

  if [ -n "$CONNECTED" ]; then
    ICON="󰂱"
    COLOR=$COLOR_CYAN
  else
    ICON="󰂯"
    COLOR=$COLOR_FG_DIM
  fi
fi

sketchybar --set $NAME icon="$ICON" icon.color=$COLOR
