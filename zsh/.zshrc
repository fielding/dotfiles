[ -f "$HOME/.shell_aliases" ] && . "$HOME/.shell_aliases"
[ -f "$HOME/.shell_functions" ] && . "$HOME/.shell_functions"
[ -f "$HOME/.shell_extra" ] && . "$HOME/.shell_extra"

# Initialize completions early so zplug (and anything else that calls
# compinit transitively) inherits the -i flag and skips the insecure-
# directories prompt for /opt/homebrew/share.
zstyle ':completion:*' completer _complete _ignored _correct _approximate
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'l:|=* r:|=*'
zstyle :compinstall filename '/Users/fielding/.zshrc'
if type brew &> /dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi
autoload -Uz compinit
compinit -i -u

# zplug's load.zsh calls `compinit -d ...` without security flags, which
# prompts about /opt/homebrew/share (group-writable since brew 4.x) and
# aborts. Shadow compinit with a function that re-adds -i; it self-clears
# after one call so the autoloaded compinit is restored.
compinit() {
  unfunction compinit
  autoload -Uz compinit
  compinit -i "$@"
}

# zplug uses `git` directly; temporarily unalias so it doesn't call `nit`
unalias git 2>/dev/null
if [ -n "${ZPLUG_HOME:-}" ] \
   && [ -r "$ZPLUG_HOME/init.zsh" ] \
   && [ -d "$ZPLUG_HOME/log" ] && [ -w "$ZPLUG_HOME/log" ] \
   && [ -d "$ZPLUG_HOME/cache" ] && [ -w "$ZPLUG_HOME/cache" ]; then
  source "$ZPLUG_HOME/init.zsh"

  zplug mafredri/zsh-async, from:github
  zplug fielding/zsh-brew-switcher, from:github, at:main
  zplug DFurnes/purer, use:pure.zsh, from:github, as:theme

  if ! zplug check --verbose; then
      printf "Install? [y/N]: "
      if read -q; then
          echo; zplug install
      fi
  fi

  zplug load
fi
alias git='nit' g='nit'

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

[ -r "$BREW_PATH/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] \
  && . "$BREW_PATH/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

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

autoload -Uz promptinit
promptinit

# pipx local bin
export PATH="$PATH:$HOME/.local/bin"

# direnv
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# fork-safety / file descriptor limits
ulimit -n 4096
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# fzf
[ -r ~/.fzf.zsh ] && . ~/.fzf.zsh

# uv completions
command -v uv  >/dev/null && eval "$(uv generate-shell-completion zsh)"
command -v uvx >/dev/null && eval "$(uvx --generate-shell-completion zsh)"

# pnpm
if [ -d "$HOME/.local/share/pnpm" ]; then
  export PNPM_HOME="$HOME/.local/share/pnpm"
  case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
  esac
fi

# openjdk@17 (Android Studio compatibility)
[ -d "$BREW_PATH/opt/openjdk@17" ] && export PATH="$BREW_PATH/opt/openjdk@17/bin:$PATH"

# Human++ color scheme
[ -f "$HOME/src/hack/human-plus-plus/dist/shell-init.sh" ] \
  && . "$HOME/src/hack/human-plus-plus/dist/shell-init.sh"
