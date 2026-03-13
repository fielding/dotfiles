#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# WiFi Plugin - Shows WiFi status
# ─────────────────────────────────────────────────────────────────────────────

source "$HOME/.config/sketchybar/colors.sh"

# Check if we have an IP (means connected)
IP=$(ipconfig getifaddr en0 2>/dev/null)

if [ -z "$IP" ]; then
  # Not connected
  ICON="󰤭"
  COLOR=$COLOR_FG_DIM
else
  # Connected
  ICON="󰤨"
  COLOR=$COLOR_GREEN
fi

sketchybar --set $NAME icon="$ICON" icon.color=$COLOR
