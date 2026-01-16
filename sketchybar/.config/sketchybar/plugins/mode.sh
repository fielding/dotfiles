#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Mode Plugin - Updates mode indicator and keybind popup
# Triggered by: sketchybar --trigger mode_change MODE=<mode>
# ─────────────────────────────────────────────────────────────────────────────

# Colors (must match sketchybarrc)
COLOR_BG=0xff2d2a2e
COLOR_ACCENT=0xffff0074       # hot pink - default
COLOR_MINT=0xff6bffb8         # mint - switcher
COLOR_CYAN=0xff5ce1ff         # electric blue - swap
COLOR_ORANGE=0xffffb86c       # amber - tree
COLOR_PURPLE=0xffbd93f9       # lavender - layout
COLOR_RED=0xffff5555          # red - meet

# Read mode from trigger or file fallback
MODE="${MODE:-default}"

# Also write to file for other tools to read
echo "$MODE" > /tmp/skhd_mode

# Set color and label based on mode
case "$MODE" in
  switcher) COLOR=$COLOR_MINT;   LABEL="SWITCH" ;;
  swap)     COLOR=$COLOR_CYAN;   LABEL="MOVE" ;;
  tree)     COLOR=$COLOR_ORANGE; LABEL="SIZE" ;;
  layout)   COLOR=$COLOR_PURPLE; LABEL="LAYOUT" ;;
  meet)     COLOR=$COLOR_RED;    LABEL="MEET" ;;
  *)        COLOR=$COLOR_ACCENT; LABEL="DEFAULT"; MODE="default" ;;
esac

# Build batched command for all updates
ARGS=(
  --set mode icon.color=$COLOR
             label="$LABEL"
             label.color=$COLOR
             popup.background.border_color=$COLOR
             popup.drawing=$([ "$MODE" = "default" ] && echo "off" || echo "on")
)

# Hide all chips first
for i in {1..8}; do
  ARGS+=(--set mode.key$i drawing=off)
done

# Define chips per mode: "key|label|color"
case "$MODE" in
  default)
    CHIPS=("^F|switch|$COLOR_MINT" "^M|meet|$COLOR_RED" "^hjkl|focus|$COLOR_ACCENT" "⌘⇧↩|term|$COLOR_ACCENT")
    ;;
  switcher)
    CHIPS=("a|move|$COLOR_CYAN" "s|layout|$COLOR_PURPLE" "t|size|$COLOR_ORANGE" "↩|term|$COLOR_MINT" "1-6|space|$COLOR_MINT" "⇧1-6|send|$COLOR_MINT" "zxc|mon|$COLOR_MINT")
    ;;
  swap)
    CHIPS=("hjkl|swap|$COLOR_CYAN" "⇧hjkl|warp|$COLOR_CYAN" "y|flip-y|$COLOR_CYAN" "x|flip-x|$COLOR_CYAN" "s|stack|$COLOR_CYAN" "⇥|next|$COLOR_CYAN")
    ;;
  tree)
    CHIPS=("f|full|$COLOR_ORANGE" "⇧F|native|$COLOR_ORANGE" "d|parent|$COLOR_ORANGE" "w|float|$COLOR_ORANGE" "r|rotate|$COLOR_ORANGE" "hjkl|grow|$COLOR_ORANGE" "e|balance|$COLOR_ORANGE" "p|pip|$COLOR_ORANGE")
    ;;
  layout)
    CHIPS=("a|bsp|$COLOR_PURPLE" "s|monocle|$COLOR_PURPLE" "d|float|$COLOR_PURPLE" "o|padding|$COLOR_PURPLE")
    ;;
  meet)
    CHIPS=("d|mic|$COLOR_RED" "e|cam|$COLOR_RED" "q|leave|$COLOR_RED")
    ;;
  *)
    CHIPS=()
    ;;
esac

# Add visible chips to batch
for i in "${!CHIPS[@]}"; do
  IFS='|' read -r key label color <<< "${CHIPS[$i]}"
  idx=$((i + 1))
  ARGS+=(--set mode.key$idx drawing=on icon="$key" label="$label" background.color=$color icon.color=$COLOR_BG)
done

# Single batched update - no flicker
sketchybar "${ARGS[@]}"
