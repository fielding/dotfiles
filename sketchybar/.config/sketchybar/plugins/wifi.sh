#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# WiFi Plugin - Shows WiFi status
# ─────────────────────────────────────────────────────────────────────────────

COLOR_FG_DIM=0xff6272a4
COLOR_MINT=0xff6bffb8

# Check if we have an IP (means connected)
IP=$(ipconfig getifaddr en0 2>/dev/null)

if [ -z "$IP" ]; then
  # Not connected
  ICON="󰤭"
  COLOR=$COLOR_FG_DIM
else
  # Connected
  ICON="󰤨"
  COLOR=$COLOR_MINT
fi

sketchybar --set $NAME icon="$ICON" icon.color=$COLOR
