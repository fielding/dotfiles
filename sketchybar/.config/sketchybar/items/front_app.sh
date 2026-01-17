#!/bin/bash

sketchybar --add item front_app left \
           --set front_app icon.drawing=off \
                           label.font="Helvetica Neue:Condensed Black:16.0" \
                           label.color=$COLOR_FG \
                           background.drawing=off \
                           script="$PLUGIN_DIR/front_app.sh" \
           --subscribe front_app front_app_switched
