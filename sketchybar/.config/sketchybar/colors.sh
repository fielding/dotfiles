#!/bin/bash
# Human++ - Base24
# Generated from palette.toml

# Base grayscale (cool)
export COLOR_BG=0xff1a1c22           # base00 - background
export COLOR_BG_LIGHT=0xff282b31     # base01 - elevation
export COLOR_BG_ALT=0xff3a3d42       # base02 - selection/panels
export COLOR_FG=0xffdbd6cc           # base05 - main text
export COLOR_FG_DIM=0xff5a5d62       # base03 - comments
export COLOR_FG_SECONDARY=0xff828079 # base04 - UI secondary
export COLOR_TRANSPARENT=0x00000000

# Loud accents (diagnostics, signals)
export COLOR_RED=0xffe7349c          # base08 - errors, attention
export COLOR_ORANGE=0xfff26c33       # base09 - warnings
export COLOR_YELLOW=0xfff2a633       # base0A - caution
export COLOR_GREEN=0xff04b372        # base0B - success
export COLOR_CYAN=0xff1ad0d6         # base0C - info
export COLOR_BLUE=0xff458ae2         # base0D - links, focus
export COLOR_PURPLE=0xff9871fe       # base0E - special
export COLOR_HUMAN=0xffbbff00        # base0F - human intent marker

# Quiet accents (UI state, less urgent)
export COLOR_RED_QUIET=0xffc8518f    # base10
export COLOR_ORANGE_QUIET=0xffd68c6f # base11
export COLOR_YELLOW_QUIET=0xffdfb683 # base12
export COLOR_GREEN_QUIET=0xff61b186  # base13
export COLOR_CYAN_QUIET=0xff91cbcd   # base14
export COLOR_BLUE_QUIET=0xff5e84b6   # base15
export COLOR_PURPLE_QUIET=0xff8f72e3 # base16

# Mode colors (using loud accents for visibility)
export MODE_DEFAULT=0xffe7349c       # base08 - hot pink
export MODE_SWITCHER=0xff04b372      # base0B - green
export MODE_SWAP=0xff1ad0d6          # base0C - cyan
export MODE_TREE=0xfff2a633          # base0A - amber
export MODE_LAYOUT=0xff9871fe        # base0E - purple
export MODE_MEET=0xfff26c33          # base09 - orange
