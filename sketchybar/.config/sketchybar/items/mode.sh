#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Mode Indicator - Shows current skhd mode with color feedback
# Clicking opens the keybind cheatsheet popup (horizontal)
# ─────────────────────────────────────────────────────────────────────────────

sketchybar --add item mode right \
           --set mode icon="" \
                      icon.drawing=off \
                      label="DEFAULT" \
                      label.font="Helvetica Neue:Condensed Black:16.0" \
                      label.color=$COLOR_BG \
                      label.padding_left=10 \
                      label.padding_right=10 \
                      background.color=$COLOR_ACCENT \
                      background.corner_radius=0 \
                      background.height=32 \
                      click_script="sketchybar --set mode popup.drawing=toggle" \
                      script="$PLUGIN_DIR/mode.sh" \
           --subscribe mode mode_change

# ─────────────────────────────────────────────────────────────────────────────
# Mode Popup - Horizontal keybind chips
# ─────────────────────────────────────────────────────────────────────────────

sketchybar --set mode popup.background.color=$COLOR_BG \
                      popup.background.corner_radius=0 \
                      popup.background.border_width=3 \
                      popup.background.border_color=$COLOR_ACCENT \
                      popup.horizontal=on \
                      popup.align=right \
                      popup.height=30

# Dynamic keybind chips (updated by mode.sh plugin)
for i in {1..8}; do
  sketchybar --add item mode.key$i popup.mode \
             --set mode.key$i icon.font="SF Mono:Heavy:11.0" \
                              icon.color=$COLOR_BG \
                              icon.padding_left=8 \
                              icon.padding_right=4 \
                              label.font="SF Mono:Bold:10.0" \
                              label.color=$COLOR_FG \
                              label.padding_right=8 \
                              background.color=$COLOR_CYAN \
                              background.corner_radius=0 \
                              background.height=22 \
                              background.drawing=on \
                              drawing=off
done

# Escape hint at the end
sketchybar --add item mode.esc popup.mode \
           --set mode.esc icon="ESC" \
                          icon.font="SF Mono:Heavy:10.0" \
                          icon.color=$COLOR_FG_DIM \
                          icon.padding_left=10 \
                          icon.padding_right=10 \
                          label.drawing=off \
                          background.drawing=off
