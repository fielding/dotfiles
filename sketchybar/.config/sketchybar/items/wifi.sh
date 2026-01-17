#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# WiFi Indicator - Shows connection status
# Click to open Network preferences
# ─────────────────────────────────────────────────────────────────────────────

sketchybar --add item wifi right \
           --set wifi icon.font="Hack Nerd Font:Bold:16.0" \
                      icon.color=$COLOR_FG_DIM \
                      label.drawing=off \
                      background.color=$COLOR_BG_LIGHT \
                      update_freq=30 \
                      script="$PLUGIN_DIR/wifi.sh" \
                      click_script="open 'x-apple.systempreferences:com.apple.preference.network'"
