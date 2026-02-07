#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Mode Plugin - Updates mode indicator with instant show/hide keybinds
# ─────────────────────────────────────────────────────────────────────────────

# Colors
TRANSPARENT="0x00000000"
COLOR_BG="${COLOR_BG:-0xff1a1c22}"
COLOR_FG="${COLOR_FG:-0xffdbd6cc}"
COLOR_ACCENT="${COLOR_ACCENT:-0xffff0074}"
COLOR_MINT="${COLOR_MINT:-0xff6bffb8}"
COLOR_CYAN="${COLOR_CYAN:-0xff5ce1ff}"
COLOR_ORANGE="${COLOR_ORANGE:-0xffffb86c}"
COLOR_PURPLE="${COLOR_PURPLE:-0xffbd93f9}"
COLOR_RED="${COLOR_RED:-0xffff5555}"
COLOR_FG_DIM="${COLOR_FG_DIM:-0xff5a5d62}"

TIMEOUT=5
MODE_EXPANDED_FILE="/tmp/sketchybar_mode_expanded"

# ─────────────────────────────────────────────────────────────────────────────
# Helper: hide all chips instantly
# ─────────────────────────────────────────────────────────────────────────────
hide_chips() {
  sketchybar \
    --set mode.key1 drawing=off width=0 \
    --set mode.key2 drawing=off width=0 \
    --set mode.key3 drawing=off width=0 \
    --set mode.key4 drawing=off width=0 \
    --set mode.key5 drawing=off width=0 \
    --set mode.key6 drawing=off width=0 \
    --set mode.key7 drawing=off width=0 \
    --set mode.key8 drawing=off width=0 \
    --set mode.esc drawing=off width=0
}

# ─────────────────────────────────────────────────────────────────────────────
# Handle manual toggle click (for default mode hints)
# ─────────────────────────────────────────────────────────────────────────────
if [ "$1" = "toggle" ]; then
  CURRENT_MODE=$(cat /tmp/skhd_mode 2>/dev/null || echo "default")

  if [ "$CURRENT_MODE" != "default" ]; then
    exit 0
  fi

  if [ -f "$MODE_EXPANDED_FILE" ]; then
    rm -f "$MODE_EXPANDED_FILE"
    hide_chips
  else
    echo "$(date +%s)" > "$MODE_EXPANDED_FILE"
    MODE="default"
    export MODE

    (
      sleep $TIMEOUT
      if [ -f "$MODE_EXPANDED_FILE" ]; then
        rm -f "$MODE_EXPANDED_FILE"
        hide_chips
      fi
    ) &

    exec "$0"
  fi
  exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# Mode change handling
# ─────────────────────────────────────────────────────────────────────────────

MODE="${MODE:-$(cat /tmp/skhd_mode 2>/dev/null || echo "default")}"

case "$MODE" in
  switcher|swap|tree|layout|meet) ;;
  *) MODE="default" ;;
esac

echo "$MODE" > /tmp/skhd_mode

case "$MODE" in
  switcher) COLOR=$COLOR_MINT;   LABEL="SWITCH" ;;
  swap)     COLOR=$COLOR_CYAN;   LABEL="MOVE" ;;
  tree)     COLOR=$COLOR_ORANGE; LABEL="SIZE" ;;
  layout)   COLOR=$COLOR_PURPLE; LABEL="LAYOUT" ;;
  meet)     COLOR=$COLOR_RED;    LABEL="MEET" ;;
  *)        COLOR=$COLOR_ACCENT; LABEL="DEFAULT" ;;
esac

case "$MODE" in
  default)
    CHIPS=("^F|switch|$COLOR_MINT" "^M|meet|$COLOR_RED" "^hjkl|focus|$COLOR_ACCENT" "⌘⇧↩|term|$COLOR_ACCENT")
    ;;
  switcher)
    CHIPS=("m|move|$COLOR_CYAN" "l|layout|$COLOR_PURPLE" "s|size|$COLOR_ORANGE" "g|meet|$COLOR_RED" "↩|term|$COLOR_MINT" "d|scatter|$COLOR_MINT" "⇧1-9|send|$COLOR_MINT" "zxc|mon|$COLOR_MINT")
    ;;
  swap)
    CHIPS=("hjkl|swap|$COLOR_CYAN" "⇧hjkl|warp|$COLOR_CYAN" "y|flip-y|$COLOR_CYAN" "x|flip-x|$COLOR_CYAN" "s|stack|$COLOR_CYAN" "⇥|next|$COLOR_CYAN")
    ;;
  tree)
    CHIPS=("f|full|$COLOR_ORANGE" "⇧F|native|$COLOR_ORANGE" "d|parent|$COLOR_ORANGE" "w|float|$COLOR_ORANGE" "r|rotate|$COLOR_ORANGE" "s|split|$COLOR_ORANGE" "hjkl|size|$COLOR_ORANGE" "e|bal|$COLOR_ORANGE")
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

# Update mode indicator
sketchybar --set mode background.color=$COLOR label="$LABEL" label.color=$COLOR_BG

# Determine if we should show chips
SHOULD_SHOW="no"
if [ "$MODE" != "default" ]; then
  SHOULD_SHOW="yes"
elif [ -f "$MODE_EXPANDED_FILE" ]; then
  SHOULD_SHOW="yes"
fi

if [ "$SHOULD_SHOW" = "yes" ]; then
  CHIP_COUNT=${#CHIPS[@]}

  # Build command to show all chips instantly
  ARGS=()
  for i in {1..8}; do
    idx=$((i - 1))
    if [ $idx -lt $CHIP_COUNT ]; then
      IFS='|' read -r key label color <<< "${CHIPS[$idx]}"
      ARGS+=(--set mode.key$i drawing=on width=dynamic background.color=$color icon="$key" label="$label" icon.color=$COLOR_BG label.color=$COLOR_BG)
    else
      ARGS+=(--set mode.key$i drawing=off width=0)
    fi
  done

  if [ "$MODE" != "default" ]; then
    ARGS+=(--set mode.esc drawing=on width=dynamic icon.color=$COLOR_BG)
  else
    ARGS+=(--set mode.esc drawing=off width=0)
  fi

  sketchybar "${ARGS[@]}"

else
  rm -f "$MODE_EXPANDED_FILE"
  hide_chips
fi
