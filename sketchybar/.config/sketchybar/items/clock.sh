#!/bin/bash

sketchybar --add item clock right \
           --set clock icon="󰥔" \
                       icon.font="Hack Nerd Font:Bold:16.0" \
                       icon.color=$COLOR_FG_DIM \
                       label.font="Helvetica Neue:Condensed Black:14.0" \
                       label.color=$COLOR_FG \
                       background.color=$COLOR_BG_LIGHT \
                       update_freq=30 \
                       script="$PLUGIN_DIR/clock.sh"
