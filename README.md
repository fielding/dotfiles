# dotfiles

My macOS configuration, managed with GNU Stow. Each top-level directory
is a stow package; running `stow <name>` symlinks its contents into `~`.

## Active packages

| Package      | What it is                                                         |
|--------------|--------------------------------------------------------------------|
| `bin`        | personal scripts (`tmux-sessionizer`, `sync-tix-to-vault`, …)      |
| `borders`    | JankyBorders — window outlines tinted by skhd mode                 |
| `claude`     | Claude Code global settings, hooks, status line                    |
| `codex`      | OpenAI Codex CLI config                                            |
| `fastfetch`  | system info banner at shell startup                                |
| `fonts`      | installed font files                                               |
| `ghostty`    | Ghostty terminal config                                            |
| `git`        | gitconfig, commit template, global gitignore                       |
| `karabiner`  | keyboard remapping                                                 |
| `shell`      | shell-agnostic `.profile`, aliases, functions                      |
| `sketchybar` | macOS status bar with mode indicator, calendar, battery, clock     |
| `skhd`       | modal hotkey daemon (yabai control, tmux mode, …)                  |
| `terminfo`   | italic-capable iterm and tmux terminfo entries                     |
| `tmux`       | true-color tmux with bell alerts and per-session colors            |
| `vim`        | vim config and plugin set                                          |
| `yabai`      | tiling window manager                                              |
| `zsh`        | zsh config with zplug, purer prompt, Human++ theme                 |

## Legacy

Kept around for reference or because something on disk still expects
them, but no longer maintained: `babel`, `bash`, `chunkwm` (replaced by
yabai), `clang-format`, `dircolors`, `eslint`, `grc`, `homebrew` (the
Brewfile is from 2020 and stale), `iterm2` (replaced by ghostty), `khd`
(replaced by skhd), `mpv`, `neovim`, `readline`, `ruby`, `spaceship`,
`vint`.

## Installation

```sh
brew install stow

# Symlink the active set:
stow bin borders claude codex fastfetch fonts ghostty git karabiner \
     shell sketchybar skhd terminfo tmux vim yabai zsh

# Compile terminfo entries (italic support in tmux):
tic ~/.terminfo/74/tmux.terminfo
tic ~/.terminfo/74/tmux-256color.terminfo
```

`bootstrap.sh` covers a from-scratch macOS setup (timezone, hostname,
Homebrew, sane Finder defaults). It is dated and may need editing
before re-running on a fresh machine.

## Theme

Most colors come from [Human++](https://github.com/justfielding/human-plus-plus),
my base24 palette. The shell-init script under
`~/src/hack/human-plus-plus/dist/shell-init.sh` is sourced from `.zshrc`
and emits the OSC palette overrides at startup.

## Inspiration / thanks

- [Jeffrey Carpenter](https://github.com/i8degrees) and his [dotfiles](https://github.com/i8degrees/dotfiles) — for somebody to "talk nerdy" to.
- [Mathias Bynens](https://mathiasbynens.be/) and his [dotfiles](https://github.com/mathiasbynens/dotfiles).
- [Xero Harrison](http://xero.nu) and his [dotfiles](https://github.com/xero/dotfiles).
