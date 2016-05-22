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
XDG_CONFIG_HOME=$HOME/.config
XDG_DATA_HOME=$HOME/.local/share
XDG_CACHE_HOME=$HOME/.cache
export XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME

XDG_DOWNLOAD_DIR=$HOME/Downloads
XDG_ETC_DIR=/etc
XDG_BIN_DIR=/bin
XDG_TMP_DIR=/tmp
export XDG_DOWNLOAD_DIR XDG_ETC_DIR XDG_BIN_DIR XDG_TMP_DIR

# set android_home directory for android development
export ANDROID_HOME=/usr/local/opt/android-sdk

export CLICOLOR=1

# Set Grep highlighting color - 1;33 aka Bold Yellow
# export GREP_COLOR="1;33"
export GREP_COLORS='ms=33:mc=33:sl=37:cx=37:fn=34:ln=1;31:bn=1;35:se=1;30'

# Less Colors for Man Pages
LESS_TERMCAP_mb=$(tput bold; tput setaf 2)
LESS_TERMCAP_md=$(tput bold; tput setaf 1)
LESS_TERMCAP_me=$(tput sgr0)
LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
LESS_TERMCAP_se=$(tput rmso; tput sgr0)
LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 3)
LESS_TERMCAP_ue=$(tput rmul; tput sgr0)

export LESS_TERMCAP_mb LESS_TERMCAP_md LESS_TERMCAP_me LESS_TERMCAP_se LESS_TERMCAP_so LESS_TERMCAP_ue LESS_TERMCAP_us
