#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Poker — Thaddius Monad Arena tournament standing
# Reads:  ♠ #1  86.5k  +40.9k   (spade colored by standing; the "k" is dimmed)
# sketchybar can't two-tone one label, so each amount is split into a bright
# number item + a dim "k" unit item. Items added to "right" stack leftward, so
# the rightmost piece (poker_lead_k) is added FIRST and the ♠ anchor LAST.
# Sub-items carry no icon, so icon.drawing=off kills the inherited icon padding
# that would otherwise leave a gap between the number and its "k".
# Plugin (plugins/poker.sh) fills all five labels. Click opens the dashboard.
# ─────────────────────────────────────────────────────────────────────────────

POKER_ICON="♠"   # spade — colored by standing (lime=#1, amber=ITM, red=out)
PFONT="RobotoMono Nerd Font:Medium:14.0"
CLICK="open http://localhost:8485"

sketchybar --add item poker_lead_k right \
           --set poker_lead_k icon.drawing=off label.font="$PFONT" label.color=$COLOR_FG_DIM \
                              label.padding_left=0 label.padding_right=12 \
                              click_script="$CLICK" \
           --add item poker_lead right \
           --set poker_lead icon.drawing=off label.font="$PFONT" label.color=$COLOR_FG \
                            label.padding_left=0 label.padding_right=0 \
                            click_script="$CLICK" \
           --add item poker_chips_k right \
           --set poker_chips_k icon.drawing=off label.font="$PFONT" label.color=$COLOR_FG_DIM \
                               label.padding_left=0 label.padding_right=8 \
                               click_script="$CLICK" \
           --add item poker_chips right \
           --set poker_chips icon.drawing=off label.font="$PFONT" label.color=$COLOR_FG \
                             label.padding_left=0 label.padding_right=0 \
                             click_script="$CLICK" \
           --add item poker right \
           --set poker icon="$POKER_ICON" \
                       icon.font="Hack Nerd Font:Bold:16.0" \
                       icon.color=$COLOR_HUMAN \
                       label.font="$PFONT" \
                       label.color=$COLOR_FG \
                       label.padding_left=4 \
                       label.padding_right=6 \
                       update_freq=60 \
                       click_script="$CLICK" \
                       script="$PLUGIN_DIR/poker.sh"
