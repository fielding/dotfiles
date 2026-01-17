#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Bluetooth Indicator - Shows connection status
# Click to open Bluetooth preferences
# ─────────────────────────────────────────────────────────────────────────────

sketchybar --add item bluetooth right \
           --set bluetooth icon.font="Hack Nerd Font:Bold:16.0" \
                           icon.color=$COLOR_FG_DIM \
                           label.drawing=off \
                           background.color=$COLOR_BG_LIGHT \
                           update_freq=30 \
                           script="$PLUGIN_DIR/bluetooth.sh" \
                           click_script="open 'x-apple.systempreferences:com.apple.preference.Bluetooth'"
