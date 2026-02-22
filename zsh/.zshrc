[ -f "$HOME/.shell_aliases" ] && . "$HOME/.shell_aliases"
[ -f "$HOME/.shell_functions" ] && . "$HOME/.shell_functions"
[ -f "$HOME/.shell_extra" ] && . "$HOME/.shell_extra"


if [ -n "${ZPLUG_HOME:-}" ] \
   && [ -r "$ZPLUG_HOME/init.zsh" ] \
   && [ -d "$ZPLUG_HOME/log" ] && [ -w "$ZPLUG_HOME/log" ] \
   && [ -d "$ZPLUG_HOME/cache" ] && [ -w "$ZPLUG_HOME/cache" ]; then
  source "$ZPLUG_HOME/init.zsh"

  zplug mafredri/zsh-async, from:github
  zplug fielding/zsh-brew-switcher, from:github, at:main
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

# Override purer's vim-mode color: use base08 (pink) in normal mode
# so it grabs attention. Insert mode stays cyan.
prompt_purer_vim_mode() {
  STATUS_COLOR="${${KEYMAP/vicmd/red}/(main|viins)/cyan}"
  prompt_pure_preprompt_render
}


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

if type brew &> /dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit -i -u
fi
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

autoload -Uz promptinit
promptinit

# The next line updates PATH for Netlify's Git Credential Helper.
if [ -f '/Users/fielding/.netlify/helper/path.zsh.inc' ]; then source '/Users/fielding/.netlify/helper/path.zsh.inc'; fi
[ -f "/Users/fielding/.ghcup/env" ] && source "/Users/fielding/.ghcup/env" # ghcup-env
# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true

# pipx local bin
export PATH="$PATH:/Users/fielding/.local/bin"

# Node
export PATH="/opt/homebrew/opt/node@22/bin:$PATH"
export PATH="/opt/homebrew/opt/node@24/bin:$PATH"

# Antigravity
export PATH="/Users/fielding/.antigravity/antigravity/bin:$PATH"

# Go configuration
export GOROOT=/opt/homebrew/opt/go/libexec
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# direnv
eval "$(direnv hook zsh)"

# Google Cloud SDK (homebrew cask)
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'; fi

# kiex (elixir)
test -s "$HOME/.kiex/scripts/kiex" && source "$HOME/.kiex/scripts/kiex"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# asdf
[ -f /opt/homebrew/opt/asdf/libexec/asdf.sh ] && . /opt/homebrew/opt/asdf/libexec/asdf.sh

# session-wise fix
ulimit -n 4096
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# bun
[ -s "/Users/fielding/.bun/_bun" ] && source "/Users/fielding/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# uv completions
command -v uv >/dev/null && eval "$(uv generate-shell-completion zsh)"
command -v uvx >/dev/null && eval "$(uvx --generate-shell-completion zsh)"

# langflow
[ -f "$HOME/.langflow/uv/env" ] && . "$HOME/.langflow/uv/env"

# opam
[[ ! -r '/Users/fielding/.opam/opam-init/init.zsh' ]] || source '/Users/fielding/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null

# pnpm
export PNPM_HOME="/Users/fielding/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# nvm
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Human++ color scheme
[ -f "$HOME/src/hack/human-plus-plus/dist/shell-init.sh" ] && source "$HOME/src/hack/human-plus-plus/dist/shell-init.sh"

# added by Speedscale
export SPEEDSCALE_HOME=/Users/fielding/.speedscale
export PATH=$PATH:$SPEEDSCALE_HOME

