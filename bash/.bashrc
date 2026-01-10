### Debugging/Profiling
## Comment out the following lines when debugging
# # open file descriptor 5 such that anything written to /dev/fd/5
# # is piped through ts and then to /tmp/timestamps
# exec 5> >(ts -i "%.s" >> /tmp/timestamps)
#
# # https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html
# export BASH_XTRACEFD="5"
#
# # Enable tracing
# set -x

[ -n "$PS1" ] && source ~/.bash_profile;



# JINA_CLI_BEGIN

## autocomplete
_jina() {
  COMPREPLY=()
  local word="${COMP_WORDS[COMP_CWORD]}"

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$(jina commands)" -- "$word") )
  else
    local words=("${COMP_WORDS[@]}")
    unset words[0]
    unset words[$COMP_CWORD]
    local completions=$(jina completions "${words[@]}")
    COMPREPLY=( $(compgen -W "$completions" -- "$word") )
  fi
}

complete -F _jina jina

# session-wise fix
ulimit -n 4096
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
# default workspace for Executors

# JINA_CLI_END


. "$HOME/.cargo/env"

# [ -f ~/.fzf.bash ] && source ~/.fzf.bash

