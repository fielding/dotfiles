#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Calendar Plugin - Shows next meeting with countdown, click to join
# ─────────────────────────────────────────────────────────────────────────────

CLICK="$1"
MEETING_LINK_FILE="/tmp/sketchybar_meeting_link"

# Colors (Monokai base + vibrant accents)
COLOR_FG_DIM=0xff727072
COLOR_ORANGE=0xffffb86c
COLOR_RED=0xffff5555
COLOR_MINT=0xff6bffb8

# Handle click - open meeting link
if [ "$CLICK" = "--click" ]; then
  if [ -f "$MEETING_LINK_FILE" ]; then
    LINK=$(cat "$MEETING_LINK_FILE")
    if [ -n "$LINK" ]; then
      open "$LINK"
    fi
  fi
  exit 0
fi

# Get next event - simpler format
EVENT_INFO=$(icalBuddy -n -li 1 -nc -nrd -npn -ea -ec "Birthdays,US Holidays" -iep "title,datetime,notes,location" -b "" eventsToday+1 2>/dev/null)

if [ -z "$EVENT_INFO" ]; then
  sketchybar --set $NAME label="No meetings" icon.color=$COLOR_FG_DIM
  rm -f "$MEETING_LINK_FILE"
  exit 0
fi

# Extract title (first line, before any "location:" or "notes:")
TITLE=$(echo "$EVENT_INFO" | head -1 | sed 's/^[[:space:]]*//')

# Extract time from the datetime line
TIME_LINE=$(echo "$EVENT_INFO" | grep -E "^[[:space:]]*(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)" | head -1)
if [ -z "$TIME_LINE" ]; then
  TIME_LINE=$(echo "$EVENT_INFO" | grep -E "[0-9]+:[0-9]+" | head -1)
fi

# Extract meeting link from full output
MEETING_LINK=""
if [[ "$EVENT_INFO" =~ (https://meet\.google\.com/[a-z-]+) ]]; then
  MEETING_LINK="${BASH_REMATCH[1]}"
elif [[ "$EVENT_INFO" =~ (https://[a-z]+\.zoom\.us/j/[0-9]+) ]]; then
  MEETING_LINK="${BASH_REMATCH[1]}"
fi

# Save meeting link for click handler
if [ -n "$MEETING_LINK" ]; then
  echo "$MEETING_LINK" > "$MEETING_LINK_FILE"
else
  rm -f "$MEETING_LINK_FILE"
fi

# Parse start time
NOW=$(date +%s)
if [[ "$TIME_LINE" =~ ([A-Za-z]+)[[:space:]]+([0-9]+).*at[[:space:]]+([0-9]+):([0-9]+)[[:space:]]*(AM|PM)? ]]; then
  MONTH="${BASH_REMATCH[1]}"
  DAY="${BASH_REMATCH[2]}"
  HOUR="${BASH_REMATCH[3]}"
  MIN="${BASH_REMATCH[4]}"
  AMPM="${BASH_REMATCH[5]}"

  # Convert to 24h if needed
  if [ "$AMPM" = "PM" ] && [ "$HOUR" -ne 12 ]; then
    HOUR=$((HOUR + 12))
  elif [ "$AMPM" = "AM" ] && [ "$HOUR" -eq 12 ]; then
    HOUR=0
  fi

  # Get event timestamp
  YEAR=$(date +%Y)
  EVENT_TIME=$(date -j -f "%b %d %Y %H:%M" "$MONTH $DAY $YEAR $HOUR:$MIN" +%s 2>/dev/null)
else
  # Fallback - assume it's happening now
  EVENT_TIME=$NOW
fi

DIFF=$((EVENT_TIME - NOW))

# Format countdown
if [ $DIFF -lt -3600 ]; then
  # Event ended more than an hour ago, skip
  sketchybar --set $NAME label="No meetings" icon.color=$COLOR_FG_DIM
  exit 0
elif [ $DIFF -lt 0 ]; then
  # Meeting in progress
  COUNTDOWN="NOW"
  ICON_COLOR=$COLOR_RED
elif [ $DIFF -lt 300 ]; then
  # Less than 5 min
  MINS=$((DIFF / 60))
  COUNTDOWN="${MINS}m"
  ICON_COLOR=$COLOR_RED
elif [ $DIFF -lt 900 ]; then
  # Less than 15 min
  MINS=$((DIFF / 60))
  COUNTDOWN="${MINS}m"
  ICON_COLOR=$COLOR_ORANGE
elif [ $DIFF -lt 3600 ]; then
  # Less than 1 hour
  MINS=$((DIFF / 60))
  COUNTDOWN="${MINS}m"
  ICON_COLOR=$COLOR_MINT
else
  # More than 1 hour
  HOURS=$((DIFF / 3600))
  MINS=$(((DIFF % 3600) / 60))
  COUNTDOWN="${HOURS}h${MINS}m"
  ICON_COLOR=$COLOR_FG_DIM
fi

# Truncate title
if [ ${#TITLE} -gt 25 ]; then
  TITLE="${TITLE:0:23}.."
fi

# Update sketchybar
sketchybar --set $NAME label="${COUNTDOWN} ${TITLE}" icon.color=$ICON_COLOR
