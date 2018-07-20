. ~/.shell_aliases
. ~/.shell_functions


source $ZPLUG_HOME/init.zsh

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
compinit
# End of lines added by compinstall


. /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# not sure if this is needed yet
# fpath=(/usr/local/share/zsh-completions $fpath)


# autoload -Uz promptinit
# promptinit
