[ -f "$HOME/.shell_aliases" ] && . "$HOME/.shell_aliases"
[ -f "$HOME/.shell_functions" ] && . "$HOME/.shell_functions"
[ -f "$HOME/.shell_extra" ] && . "$HOME/.shell_extra"


if [ -n "${ZPLUG_HOME:-}" ] \
   && [ -r "$ZPLUG_HOME/init.zsh" ] \
   && [ -d "$ZPLUG_HOME/log" ] && [ -w "$ZPLUG_HOME/log" ] \
   && [ -d "$ZPLUG_HOME/cache" ] && [ -w "$ZPLUG_HOME/cache" ]; then
  source "$ZPLUG_HOME/init.zsh"

  zplug mafredri/zsh-async, from:github
  zplug DFurnes/purer, use:pure.zsh, from:github, as:theme

  # Install plugins that haven't been installed
  if ! zplug check --verbose; then
      printf "Install? [y/N]: "
      if read -q; then
          echo; zplug install
      fi
  fi

  zplug load
fi

PURE_PROMPT_SYMBOL_COLOR=red
export PURE_PROMPT_SYMBOL_COLOR


setopt extended_history
setopt extendedglob
setopt hist_ignore_dups
setopt interactive_comments
setopt sharehistory

bindkey -v

# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored _correct _approximate
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'l:|=* r:|=*'
zstyle :compinstall filename '/Users/fielding/.zshrc'

autoload -Uz compinit
compinit -i -u
# End of lines added by compinstall


. $BREW_PATH/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# only show commands matching up to cursor in history
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey -M vicmd 'k' up-line-or-beginning-search
bindkey -M vicmd 'j' down-line-or-beginning-search

bindkey -r "^H"
bindkey -r "^J"
bindkey -r "^K"
bindkey -r "^L"

# rbenv
[[ -d ~/.rbenv ]] && \
  export PATH=${HOME}/.rbenv/bin:${PATH} && \
  eval "$(rbenv init -)"

# not sure if this is needed yet
# fpath=(/usr/local/share/zsh-completions $fpath)


# autoload -Uz promptinit
# promptinit

# The next line updates PATH for Netlify's Git Credential Helper.
if [ -f '/Users/fielding/.netlify/helper/path.zsh.inc' ]; then source '/Users/fielding/.netlify/helper/path.zsh.inc'; fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/fielding/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/fielding/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/fielding/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/fielding/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
[ -f "/Users/fielding/.ghcup/env" ] && source "/Users/fielding/.ghcup/env" # ghcup-env
# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true


export PATH="/opt/homebrew/opt/node@22/bin:$PATH"
. "$HOME/.local/share/../bin/env"

# Added by Antigravity
export PATH="/Users/fielding/.antigravity/antigravity/bin:$PATH"
export PATH="/opt/homebrew/opt/node@24/bin:$PATH"

# Go configuration
export GOROOT=/opt/homebrew/opt/go/libexec
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

eval "$(direnv hook zsh)"

. "$HOME/.langflow/uv/env"
