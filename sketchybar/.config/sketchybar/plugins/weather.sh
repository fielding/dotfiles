#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Weather Plugin - Fetches weather from wttr.in
# ─────────────────────────────────────────────────────────────────────────────

COLOR_FG_DIM=0xff6272a4
COLOR_CYAN=0xff5ce1ff
COLOR_ORANGE=0xffffb86c

# Fetch weather (format: icon temp)
WEATHER=$(curl -s "wttr.in/?format=%c%t" 2>/dev/null | tr -d '+')

if [ -z "$WEATHER" ] || [[ "$WEATHER" == *"Unknown"* ]]; then
  sketchybar --set $NAME icon="󰖐" label="--" icon.color=$COLOR_FG_DIM
  exit 0
fi

# Extract icon and temp
ICON_RAW=$(echo "$WEATHER" | grep -o '^[^0-9-]*')
TEMP=$(echo "$WEATHER" | grep -o '[-0-9]*°[CF]')

# Map weather emoji to nerd font icons
case "$ICON_RAW" in
  *"☀"*|*"🌣"*)  ICON="󰖙" ;;   # sunny
  *"⛅"*|*"🌤"*) ICON="󰖕" ;;   # partly cloudy
  *"☁"*|*"🌥"*) ICON="󰖐" ;;   # cloudy
  *"🌧"*|*"🌦"*) ICON="󰖗" ;;   # rain
  *"⛈"*|*"🌩"*) ICON="󰙾" ;;   # thunderstorm
  *"🌨"*|*"❄"*) ICON="󰖘" ;;   # snow
  *"🌫"*)       ICON="󰖑" ;;   # fog
  *)            ICON="󰖐" ;;   # default cloudy
esac

# Color based on temp
TEMP_NUM=$(echo "$TEMP" | grep -o '[-0-9]*')
if [ -n "$TEMP_NUM" ]; then
  if [ "$TEMP_NUM" -gt 80 ]; then
    COLOR=$COLOR_ORANGE
  elif [ "$TEMP_NUM" -lt 40 ]; then
    COLOR=$COLOR_CYAN
  else
    COLOR=$COLOR_FG_DIM
  fi
else
  COLOR=$COLOR_FG_DIM
fi

sketchybar --set $NAME icon="$ICON" label="$TEMP" icon.color=$COLOR
