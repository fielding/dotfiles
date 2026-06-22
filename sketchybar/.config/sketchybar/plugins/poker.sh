#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Poker — Thaddius tournament rank + chips (Monad Arena)
# Pulls from the arena-pokerkit repo via its venv python (no uv startup cost).
# Icon color signals standing: lime=#1, amber=in the money (top 10), red=out.
# ─────────────────────────────────────────────────────────────────────────────
source "$HOME/.config/sketchybar/colors.sh" 2>/dev/null

REPO="/Users/fielding/src/hack/felt"
PY="$REPO/.venv/bin/python"

OUT="$("$PY" "$REPO/scripts/sketchybar_status.py" 2>/dev/null)"
RANK="${OUT%%|*}";   REST="${OUT#*|}"
CHIPS="${REST%%|*}"; REST="${REST#*|}"
LEAD="${REST%%|*}";  RANKNUM="${REST#*|}"

case "$RANKNUM" in
  1)    COL=$COLOR_HUMAN ;;                 # leading the field -> lime pop
  ""|0) COL=$COLOR_FG_DIM ;;                # unknown / API error -> dim
  *)    if [ "$RANKNUM" -le 10 ] 2>/dev/null; then
          COL=$COLOR_YELLOW                 # in the money (top 10 pays)
        else
          COL=$COLOR_RED                    # out of the money
        fi ;;
esac

# Split each amount into number + "k" unit so the unit can render dimmed.
# _k() only ever emits a "k" suffix (never M), so a trailing-k test suffices.
CNUM="${CHIPS:-—}"; CUNIT=""
case "$CHIPS" in *k) CNUM="${CHIPS%k}"; CUNIT="k" ;; esac
LNUM="$LEAD"; LUNIT=""
case "$LEAD" in *k) LNUM="${LEAD%k}"; LUNIT="k" ;; esac

sketchybar --set poker        icon.color="$COL" label="${RANK:-?}" \
           --set poker_chips   label="$CNUM" \
           --set poker_chips_k label="$CUNIT" \
           --set poker_lead    label="$LNUM" \
           --set poker_lead_k  label="$LUNIT"
