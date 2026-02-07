#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Mode Indicator - Shows current skhd mode with instant show/hide keybinds
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# Main mode indicator (anchor - created first, chips appear to LEFT)
# ─────────────────────────────────────────────────────────────────────────────

sketchybar --add item mode right \
           --set mode icon="" \
                      icon.drawing=off \
                      label="DEFAULT" \
                      label.font="Helvetica Neue:Condensed Black:16.0" \
                      label.color=$COLOR_BG \
                      label.padding_left=10 \
                      label.padding_right=10 \
                      width=80 \
                      background.color=$COLOR_ACCENT \
                      background.corner_radius=0 \
                      background.height=32 \
                      click_script="$PLUGIN_DIR/mode.sh toggle" \
                      script="$PLUGIN_DIR/mode.sh" \
           --subscribe mode mode_change

# ─────────────────────────────────────────────────────────────────────────────
# Keybind chips - start hidden
# ─────────────────────────────────────────────────────────────────────────────

for i in {1..8}; do
  sketchybar --add item mode.key$i right \
             --set mode.key$i icon.font="Helvetica Neue:Condensed Black:22.0" \
                              icon.color=$COLOR_BG \
                              icon.padding_left=10 \
                              icon.padding_right=0 \
                              label.font="Helvetica Neue:Condensed Black:12.0" \
                              label.color=$COLOR_BG \
                              label.padding_left=6 \
                              label.padding_right=10 \
                              background.color=$COLOR_CYAN \
                              background.corner_radius=0 \
                              background.height=32 \
                              drawing=off \
                              width=0
done

# Escape hint (leftmost when expanded)
sketchybar --add item mode.esc right \
           --set mode.esc icon="ESC" \
                          icon.font="Helvetica Neue:Condensed Black:16.0" \
                          icon.color=$COLOR_BG \
                          icon.padding_left=10 \
                          icon.padding_right=10 \
                          label.drawing=off \
                          background.color=$COLOR_FG_DIM \
                          background.height=32 \
                          drawing=off \
                          width=0
