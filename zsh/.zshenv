.  ~/.profile

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
export HISTFILE HISTSIZE SAVEHIST

KEYTIMEOUT=1
export KEYTIMEOUT

if [ -z "${ZPLUG_HOME:-}" ]; then
  if [ -d "$BREW_PATH/opt/zplug" ]; then
    ZPLUG_HOME="$BREW_PATH/opt/zplug"
  elif [ -d "$HOME/.zplug" ]; then
    ZPLUG_HOME="$HOME/.zplug"
  fi
fi

[ -n "${ZPLUG_HOME:-}" ] && export ZPLUG_HOME
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -f "$HOME/.aftman/env" ] && . "$HOME/.aftman/env"
