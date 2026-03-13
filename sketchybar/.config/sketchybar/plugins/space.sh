#!/bin/bash

# Source theme colors (plugins don't inherit sketchybarrc's environment)
source "${CONFIG_DIR:-$HOME/.config/sketchybar}/colors.sh"

# Sync label text from yabai (picks up relabels from yabai-organize)
SID="${NAME#space.}"
YABAI_LABEL=$(yabai -m query --spaces --space "$SID" 2>/dev/null | jq -r '.label // empty')
# Only show label if it's a meaningful name (not default p1-p4 or empty)
case "$YABAI_LABEL" in
  p1|p2|p3|p4|"") DISPLAY_LABEL="" ;;
  *) DISPLAY_LABEL=$(echo "$YABAI_LABEL" | tr '[:lower:]' '[:upper:]') ;;
esac

if [ "$SELECTED" = "true" ]; then
  sketchybar --set $NAME icon.highlight=on \
                         icon.color=$COLOR_BG \
                         label="$DISPLAY_LABEL" \
                         label.drawing=on \
                         label.color=$COLOR_BG \
                         background.drawing=on \
                         background.color=$COLOR_ACCENT
else
  sketchybar --set $NAME label="$DISPLAY_LABEL" \
                         icon.highlight=off \
                         icon.color=$COLOR_FG_DIM \
                         label.drawing=off \
                         background.drawing=off
fi
