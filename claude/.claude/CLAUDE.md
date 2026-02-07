# Fielding Johnston

## Environment

- macOS on Apple Silicon
- Shell: zsh (with shared .profile, .shell_aliases, .shell_functions)
- Terminal: Ghostty
- Multiplexer: tmux (prefix: C-Space)
- Window manager: yabai (BSP tiling) + skhd (modal keybindings) + JankyBorders
- Status bar: SketchyBar
- Editor: vim
- Theme: Human++ (custom Base24 palette applied across all tools)

## Dotfiles

- Repo lives at ~/etc, managed with GNU Stow
- Each top-level directory is a stow package (e.g. `stow git` symlinks `git/.gitconfig` to `~/.gitconfig`)
- This file is stowed from `claude/.claude/CLAUDE.md`

## Preferences

- Pragmatic and minimal — no over-engineering, no unnecessary abstractions
- Shell scripts in bash for portability, zsh for interactive config
- Use macOS Keychain for secrets, never .env files in repos
- Claude Max plan by default; API key loaded on-demand via `claude-api` alias
- Prefer direct solutions over frameworks when the problem is simple
