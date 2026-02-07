#!/bin/bash

if pgrep -x "ghostty" > /dev/null; then
  osascript <<'EOF'
    tell application "System Events"
      tell process "Ghostty"
        click menu item "New Window" of menu "File" of menu bar 1
      end tell
    end tell
EOF
else
  open -a Ghostty
fi
