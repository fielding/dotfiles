#!/bin/sh

# Path
PATH="$HOME/bin:/usr/local/opt/coreutils/libexec/gnubin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/X11/bin:/usr/local/git/bin:/opt/bin:$HOME/.cabal/bin:$HOME/.rbenv/bin:$HOME/perl5/bin:/Library/TeX/texbin:$HOME/.cargo/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:/usr/local/lib/python2.7/site-packages:/opt/metasploit-framework/bin:/usr/local/Cellar/openssl/1.0.2l/bin"
export PATH

# set android_home directory for android development
ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_HOME

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

CFLAGS="-I/opt/X11/include -I/usr/local/include"
CXXFLAGS="$CFLAGS"
LDFLAGS="-L/opt/X11/lib -L/usr/local/lib"
PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/opt/X11/lib/pkgconfig
export CFLAGS CXXFLAGS LDFLAGS PKG_CONFIG_PATH

# help slimerjs find firefox
export SLIMERJSLAUNCHER=/Applications/Firefox52.0.2.app/Contents/MacOS/firefox

CLICOLOR=1
#GREP_OPTIONS
#LSCOLORS=ExDxCxcxBxGxgxHxHxFxfx
#Go over the commented settings
GREP_COLORS='ms=33:mc=33:sl=37:cx=37:fn=34:ln=1;31:bn=1;35:se=1;30'
export CLICOLOR GREP_COLORS
# Less Colors for Man Pages
LESS_TERMCAP_mb=$(tput bold; tput setaf 2)
LESS_TERMCAP_md=$(tput bold; tput setaf 1)
LESS_TERMCAP_me=$(tput sgr0)
LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
LESS_TERMCAP_se=$(tput rmso; tput sgr0)
LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 3)
LESS_TERMCAP_ue=$(tput rmul; tput sgr0)

export LESS_TERMCAP_mb LESS_TERMCAP_md LESS_TERMCAP_me LESS_TERMCAP_se LESS_TERMCAP_so LESS_TERMCAP_ue LESS_TERMCAP_us


export FZF_DEFAULT_COMMAND='ag -g ""'

# the fuck is this
# eval $(docker-machine env)



[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export HOMEBREW_NO_ANALYTICS=1

export PATH=/usr/local/Cellar/openssl/1.0.2l/bin:$PATH
