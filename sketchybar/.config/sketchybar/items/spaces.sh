#!/bin/bash

# Space indicators
SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9")

for i in "${!SPACE_ICONS[@]}"; do
  sid=$((i+1))
  sketchybar --add space space.$sid left \
             --set space.$sid space=$sid \
                              icon="${SPACE_ICONS[i]}" \
                              icon.font="Helvetica Neue:Condensed Black:16.0" \
                              icon.color=$COLOR_FG_DIM \
                              icon.highlight_color=$COLOR_BG \
                              icon.padding_left=8 \
                              icon.padding_right=8 \
                              background.color=$COLOR_ACCENT \
                              background.corner_radius=0 \
                              background.height=32 \
                              background.drawing=off \
                              label.drawing=off \
                              script="$PLUGIN_DIR/space.sh" \
                              click_script="yabai -m space --focus $sid"
done

# Separator after spaces
sketchybar --add item space_separator left \
           --set space_separator icon="│" \
                                 icon.color=$COLOR_FG_DIM \
                                 icon.font="SF Pro:Regular:14.0" \
                                 icon.padding_left=4 \
                                 icon.padding_right=4 \
                                 background.drawing=off \
                                 label.drawing=off
