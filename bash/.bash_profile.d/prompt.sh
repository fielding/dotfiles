bold="$(tput bold)"
reset="$(tput sgr0)"

black="$(tput setaf 0)"
red="$(tput setaf 1)"
green="$(tput setaf 2)"
yellow="$(tput setaf 3)"
blue="$(tput setaf 4)"
magenta="$(tput setaf 5)"
cyan="$(tput setaf 6)"
white="$(tput setaf 7)"

if [ "$(hostname -s)" == "sage" ]; then
  line="$red"
elif [ "$(hostname -s)" == "mace" ]; then
  line="$yellow"
elif [ "$(hostname -s)" == "jasmine" ]; then
  line="$green"
elif [ "$(hostname -s)" == "BASIL" ]; then
  line="$cyan"
fi

function parse_git_dirty() {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working directory clean" ]] && echo "+"
}

function parse_git_branch() {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

function git_status() {
  if [ "$(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}")" == '0' ]; then
    echo "╺─╸$white[$reset$bold$white$(parse_git_branch)$reset$white]"
  fi
}

export PS1="\[$reset\]\[$line\]┌─╼ \[$bold$white\][\[$reset\]\[$white\]\w\[$bold$white\]]\[$reset$line\]\$(git_status)\n\[$reset\]\$(if [[ \$? == 0 ]]; then echo \"\[$line\]└────╼\"; else echo \"\[$line\]└╼\"; fi) \[$white$reset\]"
export PS1
