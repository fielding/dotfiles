#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────
# Calendar Plugin - Shows next meeting with countdown, click to join
# ─────────────────────────────────────────────────────────────────────────────

CLICK="$1"
MEETING_LINK_FILE="/tmp/sketchybar_meeting_link"

# Colors
COLOR_FG_DIM=0xff6272a4
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

# Get next event within the next 12 hours
NEXT_EVENT=$(icalBuddy -n -li 1 -nc -nrd -ea -ec "Birthdays,US Holidays" -ps "| : |" -po "datetime,title,notes,location" -df "%s" -tf "%s" eventsToday+1 2>/dev/null | head -1)

if [ -z "$NEXT_EVENT" ] || [ "$NEXT_EVENT" = "" ]; then
  sketchybar --set $NAME label="No meetings" icon.color=$COLOR_FG_DIM
  rm -f "$MEETING_LINK_FILE"
  exit 0
fi

# Parse event - format is "datetime : title : notes : location"
IFS='|' read -r DATETIME TITLE NOTES LOCATION <<< "$NEXT_EVENT"
DATETIME=$(echo "$DATETIME" | xargs)
TITLE=$(echo "$TITLE" | xargs)
NOTES=$(echo "$NOTES" | xargs)
LOCATION=$(echo "$LOCATION" | xargs)

# Extract meeting link from notes, location, or title
MEETING_LINK=""
for field in "$NOTES" "$LOCATION" "$TITLE"; do
  if [[ "$field" =~ (https://meet\.google\.com/[a-z-]+) ]]; then
    MEETING_LINK="${BASH_REMATCH[1]}"
    break
  elif [[ "$field" =~ (https://[a-z]+\.zoom\.us/j/[0-9]+[^[:space:]]*) ]]; then
    MEETING_LINK="${BASH_REMATCH[1]}"
    break
  fi
done

# Save meeting link for click handler
if [ -n "$MEETING_LINK" ]; then
  echo "$MEETING_LINK" > "$MEETING_LINK_FILE"
else
  rm -f "$MEETING_LINK_FILE"
fi

# Calculate time until meeting
NOW=$(date +%s)
# Try to parse the datetime
EVENT_TIME=$(date -j -f "%s" "$DATETIME" +%s 2>/dev/null)

if [ -z "$EVENT_TIME" ]; then
  # Fallback - try to get from icalBuddy with different format
  EVENT_TIME=$(icalBuddy -n -li 1 -nc -nrd -ea -ps "|||" -po "datetime" -df "" -tf "%H:%M" eventsToday+1 2>/dev/null | head -1)
  if [[ "$EVENT_TIME" =~ ([0-9]+):([0-9]+) ]]; then
    HOUR="${BASH_REMATCH[1]}"
    MIN="${BASH_REMATCH[2]}"
    EVENT_TIME=$(date -j -v${HOUR}H -v${MIN}M -v0S +%s)
  else
    EVENT_TIME=$NOW
  fi
fi

DIFF=$((EVENT_TIME - NOW))

# Format countdown
if [ $DIFF -lt 0 ]; then
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
if [ ${#TITLE} -gt 20 ]; then
  TITLE="${TITLE:0:18}.."
fi

# Update sketchybar
sketchybar --set $NAME label="${COUNTDOWN} ${TITLE}" icon.color=$ICON_COLOR
