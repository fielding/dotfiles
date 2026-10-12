#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SelvWallet — today's signups + active users from the prod DB
# Reads:  󰖄 +1  󰀄 3   (wallet = new signups today, person = users who sent)
# Hover shows a popup with 7d / 30d / all-time totals and 14-day sparklines.
# Items added to "right" stack leftward, so selv_act is added FIRST.
# Plugin (plugins/selv.sh) fills everything; DB URL lives in the Keychain
# (service "selvwallet-prod-db"). Click opens selvwallet.com.
# ─────────────────────────────────────────────────────────────────────────────

SFONT="RobotoMono Nerd Font:Medium:14.0"
CLICK="open https://selvwallet.com"

sketchybar --add item selv_act right \
           --set selv_act icon="󰀄" \
                          icon.font="Hack Nerd Font:Bold:15.0" \
                          icon.color=$COLOR_FG_DIM \
                          icon.padding_left=4 icon.padding_right=4 \
                          label.font="$SFONT" label.color=$COLOR_FG \
                          label.padding_left=0 label.padding_right=12 \
                          click_script="$CLICK" \
                          script="$PLUGIN_DIR/selv.sh" \
           --subscribe selv_act mouse.entered mouse.exited \
           --add item selv right \
           --set selv icon="󰖄" \
                      icon.font="Hack Nerd Font:Bold:16.0" \
                      icon.color=$COLOR_FG_DIM \
                      label.font="$SFONT" label.color=$COLOR_FG \
                      label.padding_left=4 label.padding_right=4 \
                      update_freq=300 \
                      click_script="$CLICK" \
                      script="$PLUGIN_DIR/selv.sh" \
                      popup.align=right \
                      popup.height=26 \
                      popup.background.color=$COLOR_BG_LIGHT \
                      popup.background.border_width=1 \
                      popup.background.border_color=$COLOR_BG_ALT \
                      popup.background.corner_radius=0 \
           --subscribe selv mouse.entered mouse.exited mouse.exited.global

# Popup rows: dim key on the left (icon slot), value on the right (label slot)
for row in today yday week month all spark_su spark_act updated; do
  sketchybar --add item selv.$row popup.selv \
             --set selv.$row icon.font="$SFONT" icon.color=$COLOR_FG_SECONDARY \
                             icon.width=96 icon.padding_left=12 \
                             label.font="$SFONT" label.color=$COLOR_FG \
                             label.padding_right=14
done
sketchybar --set selv.spark_su label.color=$COLOR_HUMAN \
           --set selv.spark_act label.color=$COLOR_CYAN \
           --set selv.updated icon.color=$COLOR_FG_DIM label.color=$COLOR_FG_DIM
