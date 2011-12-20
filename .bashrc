##--------------------------------------------------------------
## file:         ~/.bashrc
## author:       fielding johnston - http://www.justfielding.com
##--------------------------------------------------------------


## Bash Options ------------------------------------------------
#shopt -s autocd             # change to named directory
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

## End Bash Options ------------------------------------------

## Environment Variables -------------------------------------

export EDITOR="vim"
export GREP_COLOR="1;33"

# Less Colors for Man Pages 
export LESS_TERMCAP_mb=$'\E[01;31m'     # begin blinking
export LESS_TERMCAP_md=$'\E[01;34m'     # begin bold
export LESS_TERMCAP_me=$'\E[0m'         # end mode
export LESS_TERMCAP_se=$'\E[0m'         # end standout-mode
export LESS_TERMCAP_so=$'\E[01;44;33m'  # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'         # end underline
export LESS_TERMCAP_us=$'\E[01;32m'     # begin underline

## End Environment Variables --------------------------------

## Default Paths --------------------------------------------

PATH=$PATH:~/.bin
PATH=$PATH:/opt/bin

## End Default Paths ----------------------------------------

## RVM defaults ---------------------------------------------

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source $HOME/.rvm/scripts/rvm


## End RVM defaults -----------------------------------------

## Prompt Style ---------------------------------------------

export LANG="en_US.UTF-8"

set_prompt_style () {

source ~/.includes/.prompt

}

set_prompt_style

## End Prompt Style -----------------------------------------

## Begin Aliases --------------------------------------------

# Frequented directories
alias h="cd ~"
alias home="cd ~"
alias mybin="cd ~/.bin"
alias wd="cd ~/works/.scratch/dev.thenomm/"


# Improved Command Options

alias ls="ls -hFG"         # add colors for filetype recognition
alias grep='grep --color=auto'


# Shortcuts
alias t="todo"
alias tl="todo list"
alias sv="sudo vim"
alias irc="rm -f ~/.irssi/saved_colors & irssi"
alias reboot="sudo shutdown -r now"
alias shutdown="sudo shutdown -h now"

# Wiki via DNS leetsauce
wiki() { dig +short txt $1.wp.dg.cx; }


## End Aliases ----------------------------------------------

## Begin Functions ------------------------------------------

extract () { # Command to use based on file extension
  if [ -f $1 ] ; then
      case $1 in
          *.tar.bz2)   tar xvjf $1    ;;
          *.tar.gz)    tar xvzf $1    ;;
          *.tar.xz)    tar xvJf $1    ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       unrar x $1     ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xvf $1     ;;
          *.tbz2)      tar xvjf $1    ;;
          *.tgz)       tar xvzf $1    ;;
          *.zip)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *.xz)        unxz $1        ;;
          *.exe)       cabextract $1  ;;
          *)           echo "\`$1': unrecognized file compression" ;;
      esac
  else
      echo "\`$1' is not a valid file"
  fi
}

## End Functions --------------------------------------------



