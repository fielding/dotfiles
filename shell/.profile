#!/bin/sh
# shell agnostic version

# set BREW_PREFIX for one time eval and many time use through out dotfiles
BREW_PREFIX=/usr/local
export BREW_PREFIX

# set android_home directory for android development
JAVA_HOME=`/usr/libexec/java_home`
ANDROID_HOME=$HOME/Library/Android/sdk
export JAVA_HOME ANDROID_HOME

# Attempt to keep macos system ruby seperate and not have to sudo gem install
RBENV_ROOT="$HOME/.rbenv"
GEM_HOME="$BREW_PREFIX/opt/gems"
GEM_PATH="$BREW_PREFIX/opt/gems"
export RBENV_ROOT GEM_HOME GEM_PATH

# golang go get'em
GOPATH="$HOME/.go"
GOROOT="/usr/local/opt/go/libexec"
export GOPATH GOROOT

# ESP32 toolchain path requirement
ESP_PATH="$HOME/esp/xtensa-esp32-elf/bin"
IDF_PATH="$HOME/esp/esp-idf"
export IDF_PATH

# Mongoose OS
MOS_BIN="$HOME/.mos/bin"

# Default
EDITOR=nvim
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

# Less Colors for Man Pages
LESS_TERMCAP_mb=$(tput bold; tput setaf 1)
LESS_TERMCAP_md=$(tput setaf 1)
LESS_TERMCAP_me=$(tput sgr0)
LESS_TERMCAP_so=$(tput bold; tput setaf 7; tput setab 1)
LESS_TERMCAP_se=$(tput rmso; tput sgr0)
LESS_TERMCAP_us=$(tput smul; tput setaf 3)
LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
LESS_TERMCAP_mr=$(tput rev)
LESS_TERMCAP_mh=$(tput dim)
export LESS_TERMCAP_mb LESS_TERMCAP_md LESS_TERMCAP_me LESS_TERMCAP_se LESS_TERMCAP_so LESS_TERMCAP_ue LESS_TERMCAP_us LESS_TERMCAP_mr LESS_TERMCAP_mh

# Fuzzy Find
FZF_DEFAULT_OPTS='--color fg:7,bg:0,hl:1,fg+:15,bg+:0,hl+:9
  --color info:10,prompt:12,spinner:13,pointer:14,marker:5
  --preview "[[ $(file --mime {}) =~ binary ]] &&
   echo {} is a binary file ||
   (highlight -O xterm256 -s molokai -l {} ||
    coderay {} ||
    rougify {} ||
    cat {}) 2> /dev/null | head -500"'
FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob="!.git/*"'
export FZF_DEFAULT_COMMAND FZF_DEFAULT_OPTS

# Path
# Need to go over this mess
PATH="$HOME/bin:/usr/local/opt/coreutils/libexec/gnubin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/X11/bin:/usr/local/git/bin:/opt/bin:$HOME/.cabal/bin:$HOME/perl5/bin:/Library/TeX/texbin:$HOME/.cargo/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:/usr/local/lib/python2.7/site-packages:/opt/metasploit-framework/bin:/usr/local/Cellar/openssl/1.0.2l/bin:$GEM_PATH/bin:$GOPATH/bin:$HOME/Library/Python/3.6/bin:$ESP_PATH:/usr/local/opt/llvm/bin:$MOS_BIN:$HOME/Library/Application Support/itch/apps/butler:$PATH"
export PATH
