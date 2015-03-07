##--------------------------------------------------------------
## file:         ~/.bashrc
## author:       fielding johnston - http://www.justfielding.com
##--------------------------------------------------------------

## Bash Options ------------------------------------------------
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

set -o vi

# Default Editor set to vim
export EDITOR="vim"

# Set Grep highlighting color - 1;33 aka Bold Yellow
export GREP_COLOR="1;33"

# Add additional default paths
export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin:/usr/local/git/bin:$HOME/bin:/opt/bin:$HOME/.cabal/bin:$HOME/.rbenv/bin"
export PYTHONPATH=$(brew --prefix)/lib/python2.7/site-packages:$PYTHONPATH
eval "$(rbenv init -)"

# Prefer English and use Unicode
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# History Settings
export HISTCONTROL=ignoredups
export HISTSIZE=10000
export HISTIGNORE="ls:ls *:cd:cd -:pwd;exit:date:* --help"

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[01;31m'     # begin blinking
export LESS_TERMCAP_md=$'\E[00;35m'     # begin bold
export LESS_TERMCAP_me=$'\E[0m'         # end mode
export LESS_TERMCAP_se=$'\E[0m'         # end standout-mode
export LESS_TERMCAP_so=$'\E[01;44;33m'  # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'         # end underline
export LESS_TERMCAP_us=$'\E[01;33m'     # begin underline

## End Environment Variables --------------------------------

## Includes ---------------------------------------------

# If this machine has powerline then use it, otherwise default to old prompt

if [ "$(which powerline)" ]; then
  source /usr/local/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh
else
  source ~/.includes/.prompt
fi

## End Includes -----------------------------------------

## Begin Aliases --------------------------------------------

# Frequented directories
alias mybin="cd $HOME/bin"

# Improved Command Options
alias la="ls -al" # high frequency in history, so I made an alias
alias grep="grep --color=auto" # always grep with color

# Shortcuts
alias sv="sudo vim"
alias irc="rm -f ~/.irssi/saved_colors & irssi"
alias reboot="sudo shutdown -r now"
alias shutdown="sudo shutdown -h now"
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias copyLastCmd='fc -ln -1 | awk '\''{$1=$1}1'\'' ORS='\'''\'' | pbcopy'
alias prettyJSON='python -m json.tool'

## Show/hide hidden files in Finder
alias show="defaults write com.apple.Finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.Finder AppleShowAllFiles -bool false && killall Finder"
## btmm shortcuts
alias rmt-sage="ssh sage.1002170465.members.btmm.icloud.com"
## Program shortcuts
alias marked="open -a 'Marked'"
alias vlc='/Applications/VLC.app/Contents/MacOS/VLC'

# Shortcuts to scripts
alias log="$HOME/bin/logtodayone.rb"
alias note-se="$HOME/bin/vw/vw-update.pl /Users/fielding/notes"
alias fm="$HOME/bin/fieldMatter.rb"

alias git="hub"

## End Aliases ----------------------------------------------

## Platform Specific

case $(uname -s) in
  Darwin|FreeBSD)
    # use gdircolors and gls from homebrew's coreutilities for pretty ls output
    eval $(gdircolors -b ~/.colors/.dir_colors)
    alias ls="gls --color=always -hF"

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
    # Keychain alias (autostarting it causes SLIM to hang)
    alias keychain_start='eval `keychain --eval --agents ssh id_rsa`'

    # use dircolors for pretty ls output
    eval $(dircolors -b ~/.colors/.dir_colors)
    alias ls="ls --color=always -hF"
    ;;
  NetBSD|OpenBSD)
    alias ls="ls -hf"
  ;;
esac

## End Platform Specific Aliases

## Begin Functions ------------------------------------------

# Wiki via DNS leetsauce
wiki () { dig +short txt $1.wp.dg.cx; }

# search man page
sman () { man $1 | less -p $2 ; }

# All encompassing extract function
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

logc () {
  msg=$*
  path=$(pwd)
  ~/bin/logtodayone.rb "@${path##*/} $msg"
  git commit -m "$msg"
}

timecap () {
  filenumber=${1:-1}
  delay=${2:-5}
  scdir=${3:-./}

  i=$filenumber; while [ 1 ];do screencapture -t jpg -x $scdir$i.jpg; echo "Capturing to $i.jpg";let i++;sleep $delay; done
}

toggledesktopicons () {
  defaults write com.apple.finder CreateDesktop `echo "($(defaults read com.apple.finder CreateDesktop)-1)*-1"|bc` && killall "Finder"
}

whereisthis() {
  lat=$(mdls -raw -name kMDItemLatitude "$1")
  if [ "$lat" != "(null)" ]; then
    long=$(mdls -raw -name kMDItemLongitude "$1")
    echo -n $lat,$long | pbcopy
    echo $lat,$long copied
    open https://www.google.com/maps?q=$lat,$long
  else
    echo "No Geo-Data Available"
  fi
}

getdef(){
  if [[ $# -ge 2 ]]; then
    echo "getdef: too many arguments" >&2
    return 1
  else
    curl "dict://dict.org/d:$1"
  fi
}

## End Functions --------------------------------------------
