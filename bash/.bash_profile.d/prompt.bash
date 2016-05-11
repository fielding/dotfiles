function parse_git_dirty() {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working directory clean" ]] && echo "+"
}

function parse_git_branch() {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

function git_status() {
  if [ $(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}") == '0' ]; then
    echo "$(tput setaf 3)╺─╸$(tput bold)$(tput setaf 7)[$(tput sgr0)$(tput setaf 7)$(parse_git_branch)$(tput setaf 7)$(tput bold)]"
  fi
}


export PS1="\[$(tput setaf 3)\]┌─╼ \[$(tput bold)$(tput setaf 7)\][\[$(tput sgr0)\]\[$(tput setaf 7)\]\w\[$(tput bold)$(tput setaf 7)\]]\[$(tput sgr0)\]\$(git_status)\n\[$(tput sgr0)$(tput setaf 3)\]\$(if [[ \$? == 0 ]]; then echo \"\[$(tput setaf 3)\]└────╼\"; else echo \"\[$(tput setaf 3)\]└╼\"; fi) \[$(tput setaf 7)$(tput sgr0)\]"

export PS1;
