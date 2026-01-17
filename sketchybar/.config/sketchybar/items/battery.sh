#!/bin/bash

sketchybar --add item battery right \
           --set battery icon.font="Hack Nerd Font:Bold:16.0" \
                         icon.color=$COLOR_FG_DIM \
                         label.font="Helvetica Neue:Condensed Black:14.0" \
                         label.color=$COLOR_FG \
                         background.color=$COLOR_BG_LIGHT \
                         update_freq=120 \
                         script="$PLUGIN_DIR/battery.sh" \
           --subscribe battery system_woke power_source_change
