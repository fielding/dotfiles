#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Flash Plugin - Shows brief feedback then hides
# Triggered by: sketchybar --trigger keybind_flash ACTION="text"
# ─────────────────────────────────────────────────────────────────────────────

ACTION="${ACTION:-}"

if [ -n "$ACTION" ]; then
  # Show flash with action text
  sketchybar --set flash label="$ACTION" drawing=on

  # Hide after delay (run in background)
  (
    sleep 0.6
    sketchybar --set flash drawing=off
  ) &
fi
