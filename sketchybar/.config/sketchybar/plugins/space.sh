#!/bin/bash

# Colors
COLOR_BG=0xff2d2a2e
COLOR_FG_DIM=0xff727072
COLOR_ACCENT=0xffff0074

if [ "$SELECTED" = "true" ]; then
  # Solid accent background with dark text (like mode indicator)
  sketchybar --set $NAME icon.highlight=on \
                         icon.color=$COLOR_BG \
                         background.drawing=on \
                         background.color=$COLOR_ACCENT
else
  # No background, dim text
  sketchybar --set $NAME icon.highlight=off \
                         icon.color=$COLOR_FG_DIM \
                         background.drawing=off
fi
