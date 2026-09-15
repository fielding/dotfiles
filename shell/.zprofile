eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# Added by Obsidian
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source "$HOME/.orbstack/shell/init.zsh" 2>/dev/null || :

export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
