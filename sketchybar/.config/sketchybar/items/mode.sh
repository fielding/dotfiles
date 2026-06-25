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

# ─────────────────────────────────────────────────────────────────────────────
# Space-map HUD — a popup anchored on the leftmost space (space.1) so it hugs the
# top-left corner of the bar, filled + toggled by ~/bin/spacemap. One row per
# space: number · project label · the apps living there, focused space lit.
# Fonts follow the bar convention: RobotoMono Nerd Font Medium 14. The glanceable
# "what's on which space" that makes spatial navigation work without hunting.
# ─────────────────────────────────────────────────────────────────────────────
sketchybar --set space.1 popup.background.color=$COLOR_BG_LIGHT \
                      popup.background.corner_radius=8 \
                      popup.background.border_width=2 \
                      popup.background.border_color=$COLOR_ACCENT \
                      popup.background.height=30 \
                      popup.horizontal=off \
                      popup.align=left \
                      popup.y_offset=2

for i in {1..10}; do
  num=$i; [ "$i" = "10" ] && num="0"
  sketchybar --add item spacemap.$i popup.space.1 \
             --set spacemap.$i icon="$num" \
                               icon.font="Helvetica Neue:Condensed Black:16.0" \
                               icon.color=$COLOR_FG \
                               icon.padding_left=12 \
                               icon.padding_right=8 \
                               label="—" \
                               label.font="RobotoMono Nerd Font:Medium:14.0" \
                               label.color=$COLOR_FG_DIM \
                               label.padding_right=16 \
                               background.drawing=off
done

# Keep the HUD's focused-space highlight current while it's held open: re-populate
# on space/display changes. spacemap refresh is a no-op when the popup is hidden,
# so this costs nothing the rest of the time.
sketchybar --add item spacemap_watch left \
           --set spacemap_watch drawing=off script="$HOME/bin/spacemap refresh" \
           --subscribe spacemap_watch space_change display_change
