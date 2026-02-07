#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Thinktax - LLM spend summary with animated slide-out breakdown
# Uses color transparency + background.drawing for smooth animations
# ─────────────────────────────────────────────────────────────────────────────

THINKTAX_ICON=""  # U+EE0D from Nerd Fonts
APP_ICON_FONT="sketchybar-app-font:32.0"

# State file for tracking expanded/collapsed
THINKTAX_STATE="$HOME/.local/state/thinktax/sketchybar_expanded"
mkdir -p "$(dirname "$THINKTAX_STATE")"

# Click script
TOGGLE_SCRIPT='
STATE_FILE="$HOME/.local/state/thinktax/sketchybar_expanded"
ANIM="tanh"
DUR=15
TIMEOUT=5

TRANSPARENT="0x00000000"
COLOR_FG="${COLOR_FG:-0xffdbd6cc}"
COLOR_CYAN="${COLOR_CYAN:-0xff1ad0d6}"
COLOR_ORANGE="${COLOR_ORANGE:-0xfff26c33}"
COLOR_GREEN="${COLOR_GREEN:-0xff04b372}"

if [ -f "$STATE_FILE" ]; then
  # ─────────────────────────────────────────────────────────────────────────
  # COLLAPSE: fade out colors, animate width, then hide backgrounds
  # ─────────────────────────────────────────────────────────────────────────
  rm -f "$STATE_FILE"

  # Fade out colors and animate width closed
  sketchybar --animate $ANIM $DUR \
             --set thinktax_cursor icon.color=$TRANSPARENT label.color=$TRANSPARENT width=0 \
             --set thinktax_claude icon.color=$TRANSPARENT label.color=$TRANSPARENT width=0 \
             --set thinktax_codex icon.color=$TRANSPARENT label.color=$TRANSPARENT width=0

  # Hide backgrounds after animation
  (sleep 0.25 && sketchybar \
    --set thinktax_cursor background.drawing=off \
    --set thinktax_claude background.drawing=off \
    --set thinktax_codex background.drawing=off) &

else
  # ─────────────────────────────────────────────────────────────────────────
  # EXPAND: show backgrounds, expand width, then fade in colors
  # ─────────────────────────────────────────────────────────────────────────
  SESSION_ID="$$-$(date +%s)"
  echo "$SESSION_ID" > "$STATE_FILE"

  # Show backgrounds and start width animation (colors still transparent)
  sketchybar --set thinktax_cursor background.drawing=on icon.color=$TRANSPARENT label.color=$TRANSPARENT \
             --set thinktax_claude background.drawing=on icon.color=$TRANSPARENT label.color=$TRANSPARENT \
             --set thinktax_codex background.drawing=on icon.color=$TRANSPARENT label.color=$TRANSPARENT \
             --animate $ANIM $DUR \
             --set thinktax_cursor width=dynamic \
             --set thinktax_claude width=dynamic \
             --set thinktax_codex width=dynamic

  # Wait for width animation, then fade in colors
  sleep 0.25
  sketchybar --animate $ANIM 10 \
             --set thinktax_cursor icon.color=$COLOR_CYAN label.color=$COLOR_FG \
             --set thinktax_claude icon.color=$COLOR_ORANGE label.color=$COLOR_FG \
             --set thinktax_codex icon.color=$COLOR_GREEN label.color=$COLOR_FG

  # Auto-collapse after timeout
  (
    sleep $TIMEOUT
    [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "$SESSION_ID" ] && {
      rm -f "$STATE_FILE"
      sketchybar --animate $ANIM $DUR \
                 --set thinktax_cursor icon.color=$TRANSPARENT label.color=$TRANSPARENT width=0 \
                 --set thinktax_claude icon.color=$TRANSPARENT label.color=$TRANSPARENT width=0 \
                 --set thinktax_codex icon.color=$TRANSPARENT label.color=$TRANSPARENT width=0
      sleep 0.25
      sketchybar --set thinktax_cursor background.drawing=off \
                 --set thinktax_claude background.drawing=off \
                 --set thinktax_codex background.drawing=off
    }
  ) &
fi
'

# ─────────────────────────────────────────────────────────────────────────────
# Main thinktax item (anchor)
# ─────────────────────────────────────────────────────────────────────────────

TRANSPARENT="0x00000000"

sketchybar --add item thinktax right \
           --set thinktax icon="$THINKTAX_ICON" \
                        icon.font="Hack Nerd Font:Bold:16.0" \
                        icon.color=$COLOR_HUMAN \
                        label.color=$COLOR_FG \
                        label.padding_left=6 \
                        label.padding_right=10 \
                        click_script="$TOGGLE_SCRIPT" \
                        update_freq=300 \
                        script="$PLUGIN_DIR/thinktax.sh"

# ─────────────────────────────────────────────────────────────────────────────
# Breakdown items - start fully hidden (transparent colors, bg off, width 0)
# ─────────────────────────────────────────────────────────────────────────────

sketchybar --add item thinktax_cursor right \
           --set thinktax_cursor icon=":cursor:" \
                        icon.font="$APP_ICON_FONT" \
                        icon.color=$TRANSPARENT \
                        icon.padding_left=8 \
                        icon.padding_right=4 \
                        label.font="Inconsolata Nerd Font:Bold:14.0" \
                        label.color=$TRANSPARENT \
                        label.padding_right=8 \
                        drawing=on \
                        width=0 \
                        background.color=$COLOR_BG \
                        background.drawing=off \
                        background.height=30

sketchybar --add item thinktax_claude right \
           --set thinktax_claude icon=":claude:" \
                        icon.font="$APP_ICON_FONT" \
                        icon.color=$TRANSPARENT \
                        icon.padding_left=8 \
                        icon.padding_right=4 \
                        label.font="Inconsolata Nerd Font:Bold:14.0" \
                        label.color=$TRANSPARENT \
                        label.padding_right=8 \
                        drawing=on \
                        width=0 \
                        background.color=$COLOR_BG \
                        background.drawing=off \
                        background.height=30

sketchybar --add item thinktax_codex right \
           --set thinktax_codex icon=":openai:" \
                        icon.font="$APP_ICON_FONT" \
                        icon.color=$TRANSPARENT \
                        icon.padding_left=8 \
                        icon.padding_right=4 \
                        label.font="Inconsolata Nerd Font:Bold:14.0" \
                        label.color=$TRANSPARENT \
                        label.padding_right=8 \
                        drawing=on \
                        width=0 \
                        background.color=$COLOR_BG \
                        background.drawing=off \
                        background.height=30
