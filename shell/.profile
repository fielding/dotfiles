#!/bin/sh
# shell-agnostic environment

HOSTNAME=$(hostname)
export HOSTNAME

# brew prefix used throughout the dotfiles
BREW_PATH=/opt/homebrew
export BREW_PATH

# GPG
GPG_TTY=$(tty)
export GPG_TTY

# Java (whichever JDK is current)
if [ -x /usr/libexec/java_home ]; then
  JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null)
  [ -n "$JAVA_HOME" ] && export JAVA_HOME
fi

# Android
if [ -d "$HOME/Library/Android/sdk" ]; then
  ANDROID_HOME=$HOME/Library/Android/sdk
  ANDROID_SDK_ROOT=$ANDROID_HOME
  export ANDROID_HOME ANDROID_SDK_ROOT
fi

# Defaults
EDITOR=vim
PAGER=less
BROWSER=open
LESS="-R"
export EDITOR PAGER BROWSER LESS

# Locale
TZ=America/Chicago
LANG="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
export TZ LANG LC_ALL

# XDG
XDG_CONFIG_HOME="$HOME/.config"
XDG_DATA_HOME="$HOME/.local/share"
XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME

XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_ETC_DIR=/etc
XDG_BIN_DIR=/bin
XDG_TMP_DIR=/tmp
export XDG_DOWNLOAD_DIR XDG_ETC_DIR XDG_BIN_DIR XDG_TMP_DIR

# Colors
CLICOLOR=1
EXA_COLORS='uu=33:gu=33:ur=33:gr=33:tr=33:uw=31:gw=31:tw=31:ue=32:ux=32:gx=32:tx=32:lc=31:sn=32'
GREP_COLORS='ms=33:mc=33:sl=37:cx=37:fn=34:ln=1;31:bn=1;35:se=1;30'
export CLICOLOR EXA_COLORS GREP_COLORS

# fzf
FZF_DEFAULT_OPTS='--color fg:7,bg:0,hl:1,fg+:15,bg+:0,hl+:9
  --color info:10,prompt:12,spinner:13,pointer:14,marker:5'
FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob="!.git/*"'
export FZF_DEFAULT_COMMAND FZF_DEFAULT_OPTS

# PATH
PATH="$HOME/bin:$BREW_PATH/bin:$BREW_PATH/opt/coreutils/libexec/gnubin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
[ -n "${ANDROID_HOME:-}" ] && PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"
export PATH

# OpenAI key for codex / non-Claude tools
OPENAI_API_KEY=$(security find-generic-password -s "OPENAI_API_KEY" -w 2>/dev/null)
export OPENAI_API_KEY
