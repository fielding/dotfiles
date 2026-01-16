#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Mic Plugin - Shows mic mute status, toggles on click
# ─────────────────────────────────────────────────────────────────────────────

COLOR_FG_DIM=0xff6272a4
COLOR_RED=0xffff5555
COLOR_MINT=0xff6bffb8

# Handle toggle
if [ "$1" = "--toggle" ]; then
  # Get current input volume
  CURRENT=$(osascript -e 'input volume of (get volume settings)')
  if [ "$CURRENT" -eq 0 ]; then
    osascript -e 'set volume input volume 75'
  else
    osascript -e 'set volume input volume 0'
  fi
fi

# Get mic status
INPUT_VOL=$(osascript -e 'input volume of (get volume settings)')

# Check if in meet mode
MODE=$(cat /tmp/skhd_mode 2>/dev/null || echo "default")

if [ "$INPUT_VOL" -eq 0 ]; then
  ICON="󰍭"
  if [ "$MODE" = "meet" ]; then
    COLOR=$COLOR_RED
  else
    COLOR=$COLOR_FG_DIM
  fi
else
  ICON="󰍬"
  if [ "$MODE" = "meet" ]; then
    COLOR=$COLOR_MINT
  else
    COLOR=$COLOR_FG_DIM
  fi
fi

sketchybar --set $NAME icon="$ICON" icon.color=$COLOR
