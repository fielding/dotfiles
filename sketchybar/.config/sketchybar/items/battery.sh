#!/bin/bash

sketchybar --add item battery right \
           --set battery icon.font="Hack Nerd Font:Regular:14.0" \
                         icon.color=$COLOR_FG_DIM \
                         label.font="SF Mono:Medium:12.0" \
                         label.color=$COLOR_FG \
                         background.color=$COLOR_BG_LIGHT \
                         update_freq=120 \
                         script="$PLUGIN_DIR/battery.sh" \
           --subscribe battery system_woke power_source_change
