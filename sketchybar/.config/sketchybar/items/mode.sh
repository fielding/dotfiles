#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Mode Indicator - Shows current skhd mode with color feedback
# Clicking opens the keybind cheatsheet popup (horizontal)
# ─────────────────────────────────────────────────────────────────────────────

sketchybar --add item mode right \
           --set mode icon="●" \
                      icon.font="SF Pro:Bold:10.0" \
                      icon.color=$COLOR_ACCENT \
                      icon.padding_right=6 \
                      label="DEFAULT" \
                      label.font="SF Mono:Bold:11.0" \
                      label.color=$COLOR_ACCENT \
                      background.color=$COLOR_BG_LIGHT \
                      background.corner_radius=6 \
                      background.height=26 \
                      click_script="sketchybar --set mode popup.drawing=toggle" \
                      script="$PLUGIN_DIR/mode.sh" \
           --subscribe mode mode_change

# ─────────────────────────────────────────────────────────────────────────────
# Mode Popup - Horizontal keybind chips
# ─────────────────────────────────────────────────────────────────────────────

sketchybar --set mode popup.background.color=$COLOR_BG \
                      popup.background.corner_radius=8 \
                      popup.background.border_width=2 \
                      popup.background.border_color=$COLOR_ACCENT \
                      popup.horizontal=on \
                      popup.align=right \
                      popup.height=28

# Dynamic keybind chips (updated by mode.sh plugin)
for i in {1..8}; do
  sketchybar --add item mode.key$i popup.mode \
             --set mode.key$i icon.font="SF Mono:Bold:10.0" \
                              icon.color=$COLOR_BG \
                              icon.padding_left=8 \
                              icon.padding_right=4 \
                              label.font="SF Pro:Medium:10.0" \
                              label.color=$COLOR_FG \
                              label.padding_right=8 \
                              background.color=$COLOR_CYAN \
                              background.corner_radius=4 \
                              background.height=20 \
                              background.drawing=on \
                              drawing=off
done

# Escape hint at the end
sketchybar --add item mode.esc popup.mode \
           --set mode.esc icon="esc" \
                          icon.font="SF Mono:Medium:10.0" \
                          icon.color=$COLOR_FG_DIM \
                          icon.padding_left=8 \
                          icon.padding_right=8 \
                          label.drawing=off \
                          background.drawing=off
