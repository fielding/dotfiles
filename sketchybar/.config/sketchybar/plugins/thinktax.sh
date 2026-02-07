#!/bin/bash

THINKTAX_BIN="/Users/fielding/src/hack/thinktax/dist/cli.js"

COLOR_FG="${COLOR_FG:-0xffdbd6cc}"
COLOR_RED="${COLOR_RED:-0xffe7349c}"
COLOR_YELLOW="${COLOR_YELLOW:-0xfff2a633}"

if [ -f "$THINKTAX_BIN" ]; then
  PAYLOAD=$(node "$THINKTAX_BIN" sketchybar --format json)
  THINKTAX_LINES=()
  while IFS= read -r line; do
    THINKTAX_LINES+=("$line")
  done < <(printf '%s' "$PAYLOAD" | node -e 'const fs=require("fs"); const data=JSON.parse(fs.readFileSync(0,"utf8")); const today=data.today ?? {}; const mtd=data.mtd ?? {}; console.log(today.total?.label ?? "-"); console.log(today.providers?.cursor?.label ?? "-"); console.log(today.providers?.claude?.label ?? "-"); console.log(today.providers?.codex?.label ?? "-"); console.log(mtd.total?.label ?? "-"); console.log(mtd.providers?.cursor?.label ?? "-"); console.log(mtd.providers?.claude?.label ?? "-"); console.log(mtd.providers?.codex?.label ?? "-"); console.log(data.stale ? "1" : "0"); console.log(data.estimateOnly ? "1" : "0");')
  TODAY_TOTAL="${THINKTAX_LINES[0]:--}"
  TODAY_CURSOR="${THINKTAX_LINES[1]:--}"
  TODAY_CLAUDE="${THINKTAX_LINES[2]:--}"
  TODAY_CODEX="${THINKTAX_LINES[3]:--}"
  MTD_TOTAL="${THINKTAX_LINES[4]:--}"
  MTD_CURSOR="${THINKTAX_LINES[5]:--}"
  MTD_CLAUDE="${THINKTAX_LINES[6]:--}"
  MTD_CODEX="${THINKTAX_LINES[7]:--}"
  STALE_FLAG="${THINKTAX_LINES[8]:-0}"
  ESTIMATE_FLAG="${THINKTAX_LINES[9]:-0}"
else
  TODAY_TOTAL="--"
  TODAY_CURSOR="--"
  TODAY_CLAUDE="--"
  TODAY_CODEX="--"
  MTD_TOTAL="--"
  MTD_CURSOR="--"
  MTD_CLAUDE="--"
  MTD_CODEX="--"
  STALE_FLAG="1"
  ESTIMATE_FLAG="0"
fi

LABEL_COLOR=$COLOR_FG
if [ "$STALE_FLAG" = "1" ]; then
  LABEL_COLOR=$COLOR_RED
elif [ "$ESTIMATE_FLAG" = "1" ]; then
  LABEL_COLOR=${COLOR_FG_SECONDARY:-$COLOR_FG}
fi

MAIN_LABEL="${TODAY_TOTAL} (${MTD_TOTAL})"
CURSOR_LABEL="${TODAY_CURSOR} (${MTD_CURSOR})"
CLAUDE_LABEL="${TODAY_CLAUDE} (${MTD_CLAUDE})"
CODEX_LABEL="${TODAY_CODEX} (${MTD_CODEX})"

# Update main item and breakdown items (bar items, not popup)
sketchybar --set thinktax label="$MAIN_LABEL" label.color=$LABEL_COLOR \
           --set thinktax_cursor label="$CURSOR_LABEL" \
           --set thinktax_claude label="$CLAUDE_LABEL" \
           --set thinktax_codex label="$CODEX_LABEL"
