#!/bin/sh
# Default Editor set to vim
export EDITOR=vim
export PAGER=less
export BROWSER=open

# Prefer English and use Unicode
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Timezone
export TZ=America/Chicago


# XDG

# set android_home directory for android development
export ANDROID_HOME=/usr/local/opt/android-sdk

export CLICOLOR=1

# Set Grep highlighting color - 1;33 aka Bold Yellow
export GREP_COLOR="1;33"


# Less Colors for Man Pages
LESS_TERMCAP_mb=$(tput bold; tput setaf 2)
LESS_TERMCAP_md=$(tput bold; tput setaf 1)
LESS_TERMCAP_me=$(tput sgr0)
LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
LESS_TERMCAP_se=$(tput rmso; tput sgr0)
LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 3)
LESS_TERMCAP_ue=$(tput rmul; tput sgr0)

export LESS_TERMCAP_mb LESS_TERMCAP_md LESS_TERMCAP_me LESS_TERMCAP_se LESS_TERMCAP_so LESS_TERMCAP_ue LESS_TERMCAP_us
