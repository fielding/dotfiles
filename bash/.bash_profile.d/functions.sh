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

  i=$filenumber; while [ true ];do screencapture -t jpg -x $scdir$i.jpg; echo "Capturing to $i.jpg";let i++;sleep $delay; done
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

define(){
  if [[ $# -ge 2 ]]; then
    echo "getdef: too many arguments" >&2
    return 1
  else
    curl "dict://dict.org/d:$1"
  fi
}

explain () {
  if [ "$#" -eq 0 ]; then
    while read  -p "Command: " cmd; do
      curl -Gs "https://www.mankier.com/api/explain/?cols="$(tput cols) --data-urlencode "q=$cmd"
    done
    echo "Bye!"
  elif [ "$#" -eq 1 ]; then
    curl -Gs "https://www.mankier.com/api/explain/?cols="$(tput cols) --data-urlencode "q=$1"
  else
    echo "Usage"
    echo "explain                  interactive mode."
    echo "explain 'cmd -o | ...'   one quoted command to explain it."
  fi
}

function duckduckgo {

    query=`php -r 'echo urlencode($argv[1]);' "$1"`
    open -g 'https://duckduckgo.com/?q='$query
}

function gignore { curl -L -s https://www.gitignore.io/api/$@ ;}

function nfo () {
  if [[ -e "$1" && $# -eq 1 ]]; then
    iconv -f cp437 -t utf8 "$1"
  elif [[ $# -gt 1 ]]; then
    echo "Usage: nfo <filename>"
    echo "Error: nfo can only read one file at a time."
  elif [[ $# -eq 0 ]]; then
    echo "Usage: nfo <filename>"
    echo "Please specify a file."
  else
    echo "Usage: nfo <filename>"
    echo "Error: $1 not found."
  fi
};

#
# move to generic shell functions
#

z() {
	local dir=$(fdb -q "(?i)$@" | head -n 1)
	[ -z "$dir" ] && return 1
	cd "$dir" || fdb -d "$dir"
}

zc() {
	z "$PWD" "$@"
}

oz() {
	local fp="$(fdb -i "$XDG_DATA_HOME"/open.json -q "(?i)$@" | head -n 1)"
	[ -e "$fp" ] && o "$fp"
}

lc() {
  local start=${1:-1}
  local end=${2:-"$start"}
  fc -ln -$start -$end | sed 's/^[[:space:]]*//'
}

yc() {
  lc "$@" | pbcopy
}
