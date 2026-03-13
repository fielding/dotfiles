#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Mode Plugin - Updates mode indicator with instant show/hide keybinds
# ─────────────────────────────────────────────────────────────────────────────

# Human++ palette (from colors.sh, with fallbacks)
COLOR_BG="${COLOR_BG:-0xff1a1c22}"
COLOR_FG="${COLOR_FG:-0xffdbd6cc}"
COLOR_FG_DIM="${COLOR_FG_DIM:-0xff5a5d62}"
COLOR_PINK="${COLOR_RED:-0xffe7349c}"         # base08 - errors, attention
COLOR_ORANGE="${COLOR_ORANGE:-0xfff26c33}"    # base09 - warnings
COLOR_AMBER="${COLOR_YELLOW:-0xfff2a633}"     # base0A - caution
COLOR_GREEN="${COLOR_GREEN:-0xff04b372}"      # base0B - success
COLOR_CYAN="${COLOR_CYAN:-0xff1ad0d6}"        # base0C - info
COLOR_BLUE="${COLOR_BLUE:-0xff458ae2}"        # base0D - links
COLOR_PURPLE="${COLOR_PURPLE:-0xff9871fe}"    # base0E - special
COLOR_HUMAN="${COLOR_HUMAN:-0xffbbff00}"     # base0F - human intent / lime

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
  switcher|swap|tree|layout|meet|tmux) ;;
  *) MODE="default" ;;
esac

echo "$MODE" > /tmp/skhd_mode

case "$MODE" in
  switcher) COLOR=$COLOR_CYAN;   LABEL="SWITCH" ;;
  swap)     COLOR=$COLOR_BLUE;   LABEL="MOVE" ;;
  tree)     COLOR=$COLOR_AMBER;  LABEL="SIZE" ;;
  layout)   COLOR=$COLOR_PURPLE; LABEL="LAYOUT" ;;
  meet)     COLOR=$COLOR_ORANGE; LABEL="MEET" ;;
  tmux)     COLOR=$COLOR_HUMAN;  LABEL="TMUX" ;;
  *)        COLOR=$COLOR_PINK;   LABEL="DEFAULT" ;;
esac

case "$MODE" in
  default)
    CHIPS=("^F|switch|$COLOR_CYAN" "^M|meet|$COLOR_ORANGE" "^hjkl|focus|$COLOR_PINK" "⌘⇧↩|term|$COLOR_PINK")
    ;;
  switcher)
    CHIPS=("m|move|$COLOR_BLUE" "l|layout|$COLOR_PURPLE" "s|size|$COLOR_AMBER" "t|tmux|$COLOR_HUMAN" "g|meet|$COLOR_ORANGE" "o|tidy|$COLOR_CYAN" "↩|term|$COLOR_CYAN" "⇧0-9|send|$COLOR_CYAN")
    ;;
  swap)
    CHIPS=("hjkl|swap|$COLOR_BLUE" "⇧hjkl|warp|$COLOR_BLUE" "y|flip-y|$COLOR_BLUE" "x|flip-x|$COLOR_BLUE" "s|stack|$COLOR_BLUE")
    ;;
  tree)
    CHIPS=("f|full|$COLOR_AMBER" "⇧F|native|$COLOR_AMBER" "d|parent|$COLOR_AMBER" "w|float|$COLOR_AMBER" "r|rotate|$COLOR_AMBER" "s|split|$COLOR_AMBER" "m|min|$COLOR_AMBER" "p|pip|$COLOR_AMBER")
    ;;
  layout)
    CHIPS=("a|bsp|$COLOR_PURPLE" "s|stack|$COLOR_PURPLE" "d|float|$COLOR_PURPLE" "o|padding|$COLOR_PURPLE")
    ;;
  meet)
    CHIPS=("d|mic|$COLOR_ORANGE" "e|cam|$COLOR_ORANGE" "q|leave|$COLOR_ORANGE")
    ;;
  tmux)
    CHIPS=("f|pick|$COLOR_HUMAN" "⎵|last|$COLOR_HUMAN" "np|sess←→|$COLOR_HUMAN" "hl|win←→|$COLOR_HUMAN" "1-9|win#|$COLOR_HUMAN" "c|new|$COLOR_HUMAN" "d|close|$COLOR_HUMAN" "r|rename|$COLOR_HUMAN")
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
