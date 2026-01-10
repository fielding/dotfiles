#!/bin/sh
# shell agnostic version

HOSTNAME=$(hostname)

export HOSTNAME
# set BREW_PATH for one time eval and many time use through out dotfiles
BREW_PATH=/opt/homebrew
export BREW_PATH

# GPG
GPG_TTY=$(tty)
export GPG_TTY

# set android_home directory for android development
if [ -x /usr/libexec/java_home ]; then
  JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null)
  if [ -n "$JAVA_HOME" ]; then
    export JAVA_HOME
  fi
fi
ANDROID_HOME=$HOME/Library/Android/sdk
ANDROID_SDK_ROOT=$ANDROID_HOME
export ANDROID_HOME ANDROID_SDK_ROOT

# Attempt to keep macos system ruby seperate and not have to sudo gem install
RBENV_ROOT="$HOME/.rbenv"
GEM_HOME="$BREW_PATH/opt/gems"
# GEM_PATH="$BREW_PATH/opt/gems"
GEM_PATH="$BREW_PATH/lib/ruby/gems/2.7.0/bin"
export RBENV_ROOT GEM_HOME GEM_PATH

GOROOT=/opt/homebrew/Cellar/go/1.22.3/libexec
GOPATH=$HOME/golang
GOPROXY=https://goproxy.cn 
export GOPATH GOROOT GOPROXY


#GOPROXY setup, this is qiniu proxy


# ESP32 toolchain path requirement
ESP_PATH="$HOME/esp/xtensa-esp32-elf/bin"
IDF_PATH="$HOME/esp/esp-idf"
export IDF_PATH

# Mongoose OS
MOS_BIN="$HOME/.mos/bin"

# Google Cloud SDK
# CLOUDSDK_PYTHON=python2.7
# export CLOUDSDK_PYTHON

# Default
EDITOR=vim
PAGER=less
BROWSER=open
LESSOPEN="| /usr/local/bin/src-hilite-lesspipe.sh %s"
LESS="-R"
export EDITOR PAGER BROWSER LESSOPEN LESS

# Timezone, Language and use Unicode
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

CFLAGS="-I/usr/local/include -I/usr/local/opt/openssl/include -I/usr/local/Cellar/glib/2.56.0/include/glib-2.0 -I/usr/local/Cellar/glib/2.56.0/lib/glib-2.0/include"
CXXFLAGS="$CFLAGS"
LDFLAGS="-L/usr/local/lib -L/usr/local/opt/openssl/lib"
PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/opt/X11/lib/pkgconfig
export CFLAGS CXXFLAGS LDFLAGS PKG_CONFIG_PATH

# help slimerjs find firefox
export SLIMERJSLAUNCHER=/Applications/Firefox52.0.2.app/Contents/MacOS/firefox

#GREP_OPTIONS
#LSCOLORS=ExDxCxcxBxGxgxHxHxFxfx
#Go over the commented settings
CLICOLOR=1
EXA_COLORS='uu=33:gu=33:ur=33:gr=33:tr=33:uw=31:gw=31:tw=31:ue=32:ux=32:gx=32:tx=32:lc=31:sn=32'
GREP_COLORS='ms=33:mc=33:sl=37:cx=37:fn=34:ln=1;31:bn=1;35:se=1;30'
export CLICOLOR EXA_COLORS GREP_COLORS

# # Less Colors for Man Pages
# LESS_TERMCAP_mb=$(tput bold; tput setaf 1)
# LESS_TERMCAP_md=$(tput setaf 1)
# LESS_TERMCAP_me=$(tput sgr0)
# LESS_TERMCAP_so=$(tput bold; tput setaf 7; tput setab 1)
# LESS_TERMCAP_se=$(tput rmso; tput sgr0)
# LESS_TERMCAP_us=$(tput smul; tput setaf 3)
# LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
# LESS_TERMCAP_mr=$(tput rev)
# LESS_TERMCAP_mh=$(tput dim)
# export LESS_TERMCAP_mb LESS_TERMCAP_md LESS_TERMCAP_me LESS_TERMCAP_se LESS_TERMCAP_so LESS_TERMCAP_ue LESS_TERMCAP_us LESS_TERMCAP_mr LESS_TERMCAP_mh


# Fuzzy Find
# FZF_DEFAULT_OPTS='--color fg:7,bg:0,hl:1,fg+:15,bg+:0,hl+:9
#   --color info:10,prompt:12,spinner:13,pointer:14,marker:5
#   --preview "[[ $(file --mime {}) =~ binary ]] &&
#    echo {} is a binary file ||
#    (highlight -O xterm256 -s molokai -l {} ||
#     coderay {} ||
#     rougify {} ||
#     cat {}) 2> /dev/null | head -500"'
# Fuzzy Find

FZF_DEFAULT_OPTS='--color fg:7,bg:0,hl:1,fg+:15,bg+:0,hl+:9
  --color info:10,prompt:12,spinner:13,pointer:14,marker:5'

FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob="!.git/*"'
export FZF_DEFAULT_COMMAND FZF_DEFAULT_OPTS


export AIR_HOME="$HOME/src/sdk/air"

# Path
# Need to go over this mess
PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
PATH=$PATH:$GOROOT/bin
PATH=$PATH:$GOPATH/bin
PATH="$HOME/bin:$BREW_PATH/bin:$BREW_PATH/opt/coreutils/libexec/gnubin:/usr/local/bin:/opt/homebrew/opt/gems:$GEM_PATH:${AIR_HOME}/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/X11/bin:/usr/local/git/bin:/opt/bin:$HOME/.cabal/bin:$HOME/perl5/bin:/Library/TeX/texbin:$HOME/.cargo/env:$ANDROID_HOME/tools:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:/usr/local/lib/python2.7/site-packages:/opt/metasploit-framework/bin:$BREW_PATH/Cellar/openssl/1.0.2l/bin:$GOPATH/bin:$HOME/Library/Python/3.6/bin:$ESP_PATH:$BREW_PATH/opt/llvm/bin:$MOS_BIN:$HOME/Library/Application Support/itch/apps/butler:$PATH"
export PATH

. "$HOME/.local/share/../bin/env"
. "$HOME/.aftman/env"

. "$HOME/.langflow/uv/env"
