##-----------------------------------------------------------------------------
## file:         ~/.bash_profile
## author:       fielding johnston - http://www.justfielding.com
##----------------------------------------------------------------------------

# Set PATH
# TODO: Fgure out why the hell I have to add $HOME/perl5/bin here, which causes
#   double listing in $PATH in everything except tmux, for functionality in tmux
export PATH="$HOME/bin:/usr/local/opt/coreutils/libexec/gnubin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/X11/bin:/usr/local/git/bin:/opt/bin:$HOME/.cabal/bin:$HOME/.rbenv/bin:$HOME/perl5/bin"

### Load the bash profile configurations
# for file in ~/.{exports,aliases,functions,extra}; do
#   [ -r "$file" ] && [ -f "$file" ] && source "$file";
# done;

for file in `ls $HOME/.bash_profile.d/*.bash`; do
    source "$file"
done

unset file;

shopt -s cdable_vars        # if cd arg is not valid, assumes its a var defining a dir
shopt -s cdspell            # autocorrects cd misspellings
shopt -s checkwinsize       # update the value of LINES and COLUMNS after each command if altered
shopt -s cmdhist            # save multi-line commands in history as single line
shopt -s dotglob            # include dotfiles in pathname expansion
shopt -s expand_aliases     # expand aliases
shopt -s extglob            # enable extended pattern-matching features
shopt -s histappend         # append to (not overwrite) the history file
shopt -s hostcomplete       # attempt hostname expansion when @ is at the beginning of a word
shopt -s nocaseglob         # pathname expansion will be treated as case-insensitive

set -o vi                   # set vi-style command line editing

### Additional sources

# Iterm2 shell integration
if [ -f /Users/fielding/.iterm2_shell_integration.bash ]; then
	source /Users/fielding/.iterm2_shell_integration.bash;
fi

# local:lib for perl modules
eval $(perl -I${HOME}/perl5/lib/perl5 -Mlocal::lib)

### Completions

if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
  source "$(brew --prefix)/share/bash-completion/bash_completion";
fi

## Platform Specific

case $(uname -s) in
  Darwin|FreeBSD)

    # TODO: PYTHONPATH, is this the best way to deal with this?
    export PYTHONPATH=$(brew --prefix)/lib/python2.7/site-packages
    # TODO: PROMPT_COMMAND placement and further explore what all this does
    #   other than allow for iterm2 to show the correct window title
    export PROMPT_COMMAND='echo -ne "\033]0;${PWD/#$HOME/~}\007"'

    # use gdircolors and gls from homebrew's coreutilities for pretty ls output
    eval $(dircolors -b ~/.dir_colors)
    alias ls="ls --color=always -hF"

    # TODO: Figure out a way to incorporate the following alias/command/ifunction
    # colourify `alias ls |awk -F "'" '{print $2}'` -al ~

    # Generic Colourizer
    grc_resource="$(brew --prefix)/etc/grc.bashrc"
    [[ -f $grc_resource ]] && source "$grc_resource"

    if [[ $(command -v colourify) ]]; then
      alias ps='colourify ps'
      alias dig='colourify dig'
      alias mount='colourify mount'
      alias df='colourify df'
      alias cal='colourify cal'
      alias curl='colourify curl'
      alias colorJSON='colourify python -m json.tool'
    fi
  ;;
  Linux)

    # TODO: PYTHONPATH questions, same as on Darwin machines
    export PYTHONPATH=$HOME/.local/lib/python3.4/site-packages
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


# Setup the prompt
# TODO: Why does this have to be last in this current setup
# TODO: Find a better way to do the prompt/powerline mess
if [ -f /usr/local/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh ]; then
  source /usr/local/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh
elif [ -f $HOME/.local/lib/python3.4/site-packages/powerline/bindings/bash/powerline.sh ]; then
  source $HOME/.local/lib/python3.4/site-packages/powerline/bindings/bash/powerline.sh
else
  source ~/.bash_prompt
fi