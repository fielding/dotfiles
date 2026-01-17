#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Mic Indicator - Shows mic mute status
# Click to toggle mute, highlights when in meet mode
# ─────────────────────────────────────────────────────────────────────────────

sketchybar --add item mic right \
           --set mic icon.font="Hack Nerd Font:Bold:16.0" \
                     icon.color=$COLOR_FG_DIM \
                     label.drawing=off \
                     background.color=$COLOR_BG_LIGHT \
                     script="$PLUGIN_DIR/mic.sh" \
                     click_script="$PLUGIN_DIR/mic.sh --toggle" \
           --subscribe mic volume_change
