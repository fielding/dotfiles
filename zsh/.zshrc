. ~/.shell_aliases
. ~/.shell_functions
. ~/.shell_extra


source $ZPLUG_HOME/init.zsh

zplug mafredri/zsh-async, from:github
zplug fielding/zsh-brew-switcher, from:github, at:main
# zplug DFurnes/purer, use:pure.zsh, from:github, as:theme
zplug "spaceship-prompt/spaceship-prompt", use:spaceship.zsh, from:github, as:theme
zplug "spaceship-prompt/spaceship-vi-mode"
zplug "windwhinny/spaceship-arch", use:spaceship-arch.plugin.zsh, from:github, as:theme



# Install plugins that haven't been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load

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

# Created by `pipx` on 2021-12-21 22:47:34
export PATH="$PATH:/Users/fielding/.local/bin"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/fielding/src/warez/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/fielding/src/warez/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/fielding/src/warez/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/fielding/src/warez/google-cloud-sdk/completion.zsh.inc'; fi

test -s \"\$HOME/.kiex/scripts/kiex\" && source \"\$HOME/.kiex/scripts/kiex\"
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


. /opt/homebrew/opt/asdf/libexec/asdf.sh


# JINA_CLI_BEGIN

## autocomplete
if [[ ! -o interactive ]]; then
    return
fi

compctl -K _jina jina

_jina() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(jina commands)"
  else
    completions="$(jina completions ${words[2,-2]})"
  fi

  reply=(${(ps:
:)completions})
}

# session-wise fix
ulimit -n 4096
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# JINA_CLI_END

# if [[ -n "$SPACESHIP_PROMPT_ORDER" ]]; then

#   local current_order=$SPACESHIP_PROMPT_ORDER
#   SPACESHIP_PROMPT_ORDER=("arch" $current_order)
  
#   # Configure arch segment
#   SPACESHIP_ARCH_SHOW=true
#   SPACESHIP_ARCH_PREFIX="[%ARCH%]"

#   spaceship_arch() {
#      [[ $SPACESHIP_FOOBAR_SHOW == false ]] && return
#      spaceship::exists arch || return

#   }
# fi
# bun completions
[ -s "/Users/fielding/.bun/_bun" ] && source "/Users/fielding/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"


# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/Users/fielding/.opam/opam-init/init.zsh' ]] || source '/Users/fielding/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration

# pnpm
export PNPM_HOME="/Users/fielding/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
