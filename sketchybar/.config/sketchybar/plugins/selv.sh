#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SelvWallet — signups / active users from prod Neon (read-only, RLS
# "monitoring" mode). Hover toggles the popup; everything else refreshes.
# Wallet icon goes lime when someone signed up today, cyan when someone sent.
# ─────────────────────────────────────────────────────────────────────────────
source "$HOME/.config/sketchybar/colors.sh" 2>/dev/null

case "$SENDER" in
  mouse.entered) sketchybar --set selv popup.drawing=on;  exit 0 ;;
  mouse.exited|mouse.exited.global) sketchybar --set selv popup.drawing=off; exit 0 ;;
esac

PSQL=/opt/homebrew/bin/psql
JQ=/usr/bin/jq
TZ_NAME="$(readlink /etc/localtime | sed 's#.*/zoneinfo/##')"
DB_URL="$(security find-generic-password -a selvwallet -s selvwallet-prod-db -w 2>/dev/null)"

JSON=""
if [ -n "$DB_URL" ]; then
  JSON="$(PGCONNECT_TIMEOUT=10 "$PSQL" "$DB_URL" -X -tAq -v ON_ERROR_STOP=1 \
          -v tz="${TZ_NAME:-UTC}" -f "$HOME/.config/sketchybar/plugins/selv.sql" 2>/dev/null \
          | /usr/bin/grep '^{')"
fi

if [ -z "$JSON" ]; then
  sketchybar --set selv icon.color=$COLOR_RED label="—" \
             --set selv_act label="—" \
             --set selv.updated icon="error" label="DB unreachable $(date +%H:%M)"
  exit 0
fi

# Sparkline: scale each series to its own max (all-zero -> flat baseline)
read -r SU_TODAY ACT_TODAY <<<"$(echo "$JSON" | $JQ -r '"\(.su_today) \(.act_today)"')"
ROWS="$(echo "$JSON" | $JQ -r '
  def spark: (max) as $m
    | map(if $m == 0 then "▁" else ["▁","▂","▃","▄","▅","▆","▇","█"][(. * 7 / $m | floor)] end)
    | join("");
  "+\(.su_today) new · \(.act_today) active · \(.tx_today) tx",
  "+\(.su_yday) new · \(.act_yday) active",
  "+\(.su_7) new · \(.act_7) active · \(.tx_7) tx",
  "+\(.su_30) new · \(.act_30) active · \(.tx_30) tx",
  "\(.users) users · \(.wallets) wallets · \(.senders) ever sent · \(.tx) tx",
  "\(.su_series | spark)  max \(.su_series | max)",
  "\(.act_series | spark)  max \(.act_series | max)"')"

{ read -r R_TODAY; read -r R_YDAY; read -r R_WEEK; read -r R_MONTH; read -r R_ALL; read -r R_SU; read -r R_ACT; } <<<"$ROWS"

ICOL=$COLOR_FG_DIM
[ "$ACT_TODAY" -gt 0 ] 2>/dev/null && ICOL=$COLOR_CYAN
[ "$SU_TODAY" -gt 0 ] 2>/dev/null && ICOL=$COLOR_HUMAN
ACOL=$COLOR_FG_DIM
[ "$ACT_TODAY" -gt 0 ] 2>/dev/null && ACOL=$COLOR_CYAN

sketchybar --set selv            icon.color="$ICOL" label="+$SU_TODAY" \
           --set selv_act        icon.color="$ACOL" label="$ACT_TODAY" \
           --set selv.today      icon="today"     label="$R_TODAY" \
           --set selv.yday       icon="yesterday" label="$R_YDAY" \
           --set selv.week       icon="7 days"    label="$R_WEEK" \
           --set selv.month      icon="30 days"   label="$R_MONTH" \
           --set selv.all        icon="all time"  label="$R_ALL" \
           --set selv.spark_su   icon="signups"   label="$R_SU" \
           --set selv.spark_act  icon="active"    label="$R_ACT" \
           --set selv.updated    icon="updated"   label="$(date +%H:%M) · sparklines 14d"
