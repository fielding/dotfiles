##-----------------------------------------------------------------------------
## file:         ~/.bash_profile
## author:       fielding johnston - http://www.justfielding.com
##----------------------------------------------------------------------------

# Load ~/.profile regardless of shell version
if [ -e "$HOME"/.profile ] ; then
  . "$HOME"/.profile
fi

if [ -d "$HOME"/.bash_profile.d ]; then
  for bash_profile in "$HOME"/.bash_profile.d/*.sh; do
    if [[ -e $bash_profile ]]; then
      source "$bash_profile"
    fi
  done
  unset -v bash_profile
fi

# History Settings
export HISTCONTROL=ignoredups
export HISTSIZE=1000
export HISTFILESIZE=10000
export HISTIGNORE="ls:ls *:cd:cd -:pwd;exit:date:* --help"
shopt -s histappend         # append to (not overwrite) the history file
shopt -s cmdhist            # save multi-line commands in history as single line

shopt -s cdable_vars        # if cd arg is not valid, assumes its a var defining a dir
shopt -s cdspell            # autocorrects cd misspellings
shopt -s checkwinsize       # update the value of LINES and COLUMNS after each command if altered
shopt -s dotglob            # include dotfiles in pathname expansion
shopt -s expand_aliases     # expand aliases
shopt -s extglob            # enable extended pattern-matching features
shopt -s hostcomplete       # attempt hostname expansion when @ is at the beginning of a word
shopt -s nocaseglob         # pathname expansion will be treated as case-insensitive
shopt -s globstar           # enable ** pattern during globbing

set -o vi                   # set vi-style command line editing

### Additional sources
### bash completion time!

if which brew &> /dev/null && [ -f "$BREW_PREFIX/share/bash-completion/bash_completion" ]; then
  source /usr/local/etc/bash_completion;
elif [ -f /etc/bash_completion ]; then
  source /etc/bash_completion;
fi

# For Travis gem
[ -f /Users/fielding/.travis/travis.sh ] && source /Users/fielding/.travis/travis.sh


# rbenv setup
if [[ "$(type -P rbenv)" && ! "$(type -t _rbenv)" ]]; then
  eval "$(rbenv init -)"
fi

# go version manager
# [[ -s "/home/fielding/.gvm/scripts/gvm" ]] && source "/home/fielding/.gvm/scripts/gvm"

# let luarocks setup suitable env variables for us
eval $(luarocks path --bin)


# local:lib for perl modules
[ -d "$HOME/perl5/lib/perl5" ] && eval "$(perl -I${HOME}/perl5/lib/perl5 -Mlocal::lib)"

## Platform Specific


## REDO THIS to something like the following
## Move/incorporate it in to sourcing of bash_profile.d files
## still considering host and os specific file, so will need
## to adjust the commented idea. Still serves as food for thought

# [[ $(uname -s) == 'Darwin' ]] && source bash_profile.d/*.mac.sh
# [[ $(uname -s) == 'FreeBSD' ]] && source bash_profile.d/*.bsd.sh
# [[ $(uname -s) == 'Linux' ]] && source bash_profile.d/*.linux.sh
# [[ $(uname -s) == MINGW32_* ]] && source bash_profile.d/*.win.sh


case $(uname -s) in
  Darwin|FreeBSD)
    export PROMPT_COMMAND='echo -ne "\033]0;${PWD/#$HOME/~}\007";[ "$PWD" -ef "$HOME" ] || fdb -a "$PWD"'

    # use gdircolors and gls from homebrew's coreutilities for pretty ls output
    # might not need this, or at least need to put it inline with my EXA_COLORS
    eval $(dircolors -b ~/.dir_colors)

    # TODO: Figure out a way to incorporate the following alias/command/ifunction
    # colourify `alias ls |awk -F "'" '{print $2}'` -al ~

    # Generic Colourizer
    grc_resource="$brew_prefix/etc/grc.bashrc"
    [[ -f $grc_resource ]] && source "$grc_resource"

    ;;
  Linux)

    # TODO: PYTHONPATH do I need to uncomment the line below?
    # export PYTHONPATH=$HOME/.local/lib/python3.4/site-packages
    # TODO: Do I need to worry about PROMPT_COMMAND on linux machines?
    # TODO: still using keychain?
    # Keychain alias (autostarting it causes SLIM to hang)
    # alias keychain_start='eval `keychain --eval --agents ssh id_rsa`'

    # Keychain alias (autostarting it causes SLIM to hang)
    alias keychain_start='eval `keychain --eval --agents ssh id_rsa`'

    # use dircolors for pretty ls output
    eval $(dircolors -b ~/.dir_colors)
    alias ls="ls --color=always -hF"
    ;;
  NetBSD|OpenBSD)
    alias ls="ls -hf"
    ;;
esac

source <(npx --shell-auto-fallback bash)
