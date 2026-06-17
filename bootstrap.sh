#!/usr/bin/env bash
# ============================================================================
# bootstrap.sh - f'ng <fielding@justfielding.com> https://justfielding.com
#
# Brings a fresh (or existing) Mac up to my setup, end to end and idempotent:
#   preflight  - Xcode CLT, Rosetta, hostname, timezone
#   sshkey     - per-machine ed25519 key + agent/keychain wiring
#   homebrew   - install Homebrew, Rust toolchain, then `brew bundle`
#   stow       - symlink the active dotfiles packages into ~
#   terminfo   - compile italic-capable tmux terminfo entries
#   shell      - default shell -> brew zsh, zplug + vim plugins
#   macos      - `defaults write` system tweaks + dock cleanup
#   yabai      - scripting-addition sudoers wiring (SIP stays manual)
#   agents     - install selected LaunchAgents from templates
#   continuity - Handoff/Universal Control toggles + manual checklist
#   mlx        - Apple-Silicon local-model stack (mlx-lm via uv)
#
# Safe to run repeatedly: every step checks before it acts.
#
#   ./bootstrap.sh                 # run everything
#   ./bootstrap.sh --list          # list phases
#   ./bootstrap.sh --only homebrew,stow
#   ./bootstrap.sh --skip mlx,agents
#   ./bootstrap.sh --dry-run       # print what would happen
#   ./bootstrap.sh --yes           # never prompt (keep current hostname, etc.)
#   ./bootstrap.sh --agents cadence,glean   # which LaunchAgents to install
#   ./bootstrap.sh --no-agents
# ============================================================================

set -euo pipefail

# --- locations --------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"                       # bootstrap.sh lives at repo root
AGENT_TEMPLATES="$REPO_ROOT/bootstrap/launchagents"
BREWFILE="$REPO_ROOT/homebrew/.Brewfile"

# --- config -----------------------------------------------------------------
TIMEZONE="America/Chicago"
# Active stow packages (mirror of README's "Active packages" table).
STOW_PACKAGES=(bin borders claude codex fastfetch fonts ghostty git homebrew \
               karabiner shell sketchybar skhd terminfo tmux vim yabai zsh)
# LaunchAgents installed by default. ollama + pilot are opt-in (--agents):
# local models live on the M4, and pilot is the disabled screenpipe rig.
DEFAULT_AGENTS=(cadence glean weather sync-tix-to-vault)

# --- flags ------------------------------------------------------------------
DRY_RUN=0
ASSUME_YES=0
ONLY=""
SKIP=""
AGENTS_OVERRIDE=""
NO_AGENTS=0

ALL_PHASES=(preflight sshkey homebrew stow terminfo shell macos yabai agents continuity mlx)

# --- pretty logging ---------------------------------------------------------
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'; C_DIM=$'\033[2m'; C_BLUE=$'\033[34m'
  C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RED=$'\033[31m'; C_BOLD=$'\033[1m'
else
  C_RESET=""; C_DIM=""; C_BLUE=""; C_GREEN=""; C_YELLOW=""; C_RED=""; C_BOLD=""
fi
step() { printf '\n%s==>%s %s%s%s\n' "$C_BLUE$C_BOLD" "$C_RESET" "$C_BOLD" "$*" "$C_RESET"; }
info() { printf '    %s\n' "$*"; }
ok()   { printf '    %s✓%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '    %s!%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
die()  { printf '%serror:%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; exit 1; }

# run CMD... — execute, or just print under --dry-run
run() {
  if (( DRY_RUN )); then printf '    %s[dry-run]%s %s\n' "$C_DIM" "$C_RESET" "$*"; return 0; fi
  "$@"
}

# Run a shell snippet (for pipes/redirects) honoring --dry-run.
runsh() {
  if (( DRY_RUN )); then printf '    %s[dry-run]%s %s\n' "$C_DIM" "$C_RESET" "$*"; return 0; fi
  bash -c "$*"
}

confirm() { # confirm "prompt" -> 0 yes / 1 no ; auto-yes with --yes
  (( ASSUME_YES )) && return 0
  local reply; read -r -p "    $* [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

# ============================================================================
# phase: preflight
# ============================================================================
phase_preflight() {
  step "Preflight"

  # Establish sudo for the whole run. `sudo -v` demands a password even under
  # NOPASSWD and needs a tty, so it can't be the gate for SSH/automation runs:
  # prefer a non-interactive check, fall back to an interactive prompt only
  # when a terminal is actually attached.
  if (( ! DRY_RUN )); then
    if sudo -n true 2>/dev/null; then
      :  # passwordless (NOPASSWD) or already cached
    elif [[ -t 0 ]]; then
      sudo -v || die "need sudo to continue"
    else
      die "sudo needs a password but no terminal is attached — enable NOPASSWD or re-run with: ssh -t"
    fi
    # Keep the timestamp warm for the rest of the run (a no-op under NOPASSWD).
    ( while true; do sudo -n true 2>/dev/null; sleep 60; kill -0 "$$" 2>/dev/null || exit; done ) &
  fi

  # Xcode Command Line Tools (git, clang, make, ...).
  if xcode-select -p >/dev/null 2>&1; then
    ok "Xcode Command Line Tools present"
  else
    info "Installing Xcode Command Line Tools (a GUI dialog will appear)..."
    run xcode-select --install || true
    warn "Re-run bootstrap once the CLT install finishes."
    (( DRY_RUN )) || exit 0
  fi

  # Rosetta 2 — several casks (android-studio, unity, ...) still need it.
  if [[ "$(uname -m)" == "arm64" ]]; then
    if /usr/bin/pgrep -q oahd || arch -x86_64 /usr/bin/true >/dev/null 2>&1; then
      ok "Rosetta 2 present"
    else
      info "Installing Rosetta 2..."
      run softwareupdate --install-rosetta --agree-to-license || warn "Rosetta install skipped"
    fi
  fi

  # Hostname / computer name.
  local current new
  current="$(scutil --get LocalHostName 2>/dev/null || hostname -s)"
  if (( ASSUME_YES )); then
    new="$current"
  else
    read -r -p "    Hostname (default: $current): " new
    new="${new:-$current}"
  fi
  if [[ "$new" != "$current" ]]; then
    run sudo scutil --set ComputerName "$new"
    run sudo scutil --set HostName "$new"
    run sudo scutil --set LocalHostName "$new"
    run sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server \
        NetBIOSName -string "$new"
    ok "Hostname set to $new"
  else
    ok "Hostname stays $current"
  fi

  # Timezone.
  run sudo systemsetup -settimezone "$TIMEZONE" >/dev/null 2>&1 || warn "could not set timezone"
  ok "Timezone $TIMEZONE"
}

# ============================================================================
# phase: sshkey  (per-machine ed25519 key + agent/keychain wiring)
# ============================================================================
phase_sshkey() {
  step "SSH key"
  local key="$HOME/.ssh/id_ed25519" cfg="$HOME/.ssh/config"
  run mkdir -p "$HOME/.ssh"
  run chmod 700 "$HOME/.ssh"

  # Generate a key unique to THIS machine. Never overwrite an existing one.
  if [[ -f "$key" ]]; then
    ok "Key already present ($key) — leaving it untouched"
  else
    local comment; comment="$(whoami)@$(scutil --get LocalHostName 2>/dev/null || hostname -s)"
    info "Generating a per-machine ed25519 key ($comment)..."
    if (( ASSUME_YES )); then
      run ssh-keygen -t ed25519 -C "$comment" -f "$key" -N ""   # non-interactive: no passphrase
    else
      info "(set a passphrase when prompted — recommended on a reclaimable machine)"
      run ssh-keygen -t ed25519 -C "$comment" -f "$key"
    fi
    ok "Created $key"
  fi

  # Make the agent load it and stash the passphrase in the macOS keychain.
  if [[ ! -f "$cfg" ]] || ! grep -qs "AddKeysToAgent" "$cfg" 2>/dev/null; then
    runsh "cat >> '$cfg' <<'EOF'

Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF"
    run chmod 600 "$cfg"
    ok "Wrote agent/keychain defaults to ~/.ssh/config"
  else
    ok "~/.ssh/config already has agent defaults"
  fi
  run ssh-add --apple-use-keychain "$key" 2>/dev/null || true

  # Show the public key so it can be registered where this machine connects TO.
  if [[ -f "$key.pub" ]] && (( ! DRY_RUN )); then
    info "Public key — register on GitHub, mandy, and the other Mac:"
    printf '    %s\n' "$(cat "$key.pub")"
    info "GitHub (if gh is authed):  gh ssh-key add \"$key.pub\" --title \"$(scutil --get LocalHostName 2>/dev/null || hostname -s)\""
  fi
}

# ============================================================================
# phase: homebrew  (install brew, ensure rust for cargo entries, brew bundle)
# ============================================================================
phase_homebrew() {
  step "Homebrew"

  if command -v brew >/dev/null 2>&1; then
    ok "Homebrew present"
  else
    info "Installing Homebrew..."
    runsh '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  fi

  # Make brew available in this shell (Apple Silicon vs Intel prefix).
  if (( ! DRY_RUN )); then
    if [[ -x /opt/homebrew/bin/brew ]]; then eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then eval "$(/usr/local/bin/brew shellenv)"; fi
  fi

  # The Brewfile has `cargo "..."` entries, which need a cargo on PATH first.
  if command -v cargo >/dev/null 2>&1; then
    ok "Rust toolchain present"
  else
    info "Installing Rust (rustup) for the Brewfile's cargo entries..."
    runsh 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path'
    if [[ -f "$HOME/.cargo/env" ]] && (( ! DRY_RUN )); then source "$HOME/.cargo/env"; fi
  fi

  [[ -f "$BREWFILE" ]] || die "Brewfile not found at $BREWFILE"

  # Homebrew 6.0+ gates third-party taps behind a trust list
  # ($HOMEBREW_REQUIRE_TAP_TRUST); `brew bundle` refuses their formulae/casks
  # until trusted. Trust every tap the Brewfile declares.
  if brew trust --help >/dev/null 2>&1; then
    local t
    while IFS= read -r t; do
      [[ -n "$t" ]] && run brew trust "$t" >/dev/null 2>&1 || true
    done < <(grep -E '^[[:space:]]*tap "' "$BREWFILE" | sed -E 's/.*"([^"]+)".*/\1/')
    ok "Trusted Brewfile taps"
  fi

  info "Installing packages from Brewfile (this is the long one)..."
  run brew bundle --file="$BREWFILE" || warn "brew bundle reported errors — review above"
  ok "Brew bundle complete"
}

# ============================================================================
# phase: stow
# ============================================================================
phase_stow() {
  step "Stow dotfiles"
  command -v stow >/dev/null 2>&1 || die "stow not installed (run the homebrew phase first)"
  local pkg present=()
  for pkg in "${STOW_PACKAGES[@]}"; do
    if [[ -d "$REPO_ROOT/$pkg" ]]; then present+=("$pkg"); else warn "package '$pkg' missing, skipping"; fi
  done
  run stow --dir="$REPO_ROOT" --target="$HOME" --restow "${present[@]}"
  ok "Stowed: ${present[*]}"
}

# ============================================================================
# phase: terminfo  (italic-capable tmux entries)
# ============================================================================
phase_terminfo() {
  step "Terminfo"
  command -v tic >/dev/null 2>&1 || { warn "tic not found, skipping"; return 0; }
  local f found=0
  # Prefer the stowed copies under ~; fall back to the repo if not stowed yet.
  for f in "$HOME/.terminfo/74/tmux.terminfo"        "$REPO_ROOT/terminfo/.terminfo/74/tmux.terminfo" \
           "$HOME/.terminfo/74/tmux-256color.terminfo" "$REPO_ROOT/terminfo/.terminfo/74/tmux-256color.terminfo" \
           "$HOME/.terminfo/69/iterm.terminfo"         "$REPO_ROOT/terminfo/.terminfo/69/iterm.terminfo"; do
    if [[ -f "$f" ]]; then run tic -x "$f" && found=1; fi
  done
  if (( found )); then ok "Compiled terminfo entries"; else warn "no terminfo sources found (stow first)"; fi
}

# ============================================================================
# phase: shell  (default shell -> brew zsh, zplug, vim plugins)
# ============================================================================
phase_shell() {
  step "Shell"
  # Prefer brew zsh if it's installed; otherwise the system zsh is fine.
  local zsh_bin="" brew_zsh="$(brew --prefix 2>/dev/null)/bin/zsh"
  if [[ -x "$brew_zsh" ]]; then zsh_bin="$brew_zsh"
  elif [[ -x /bin/zsh ]]; then zsh_bin="/bin/zsh"; fi
  if [[ -n "$zsh_bin" ]]; then
    grep -qxF "$zsh_bin" /etc/shells 2>/dev/null || runsh "echo '$zsh_bin' | sudo tee -a /etc/shells >/dev/null"
    if [[ "$SHELL" != "$zsh_bin" ]]; then
      run chsh -s "$zsh_bin" "$USER" && ok "Default shell -> $zsh_bin"
    else
      ok "Default shell already $zsh_bin"
    fi
  else
    warn "no zsh found, leaving default shell alone"
  fi

  # zplug (zsh plugin manager) — best effort, non-fatal.
  if command -v zplug >/dev/null 2>&1 || [[ -d "$(brew --prefix 2>/dev/null)/opt/zplug" ]]; then
    info "Installing zsh plugins via zplug..."
    runsh "zsh -i -c 'zplug install' >/dev/null 2>&1" || warn "zplug install will retry on next shell start"
  fi

  # vim-plug plugins — best effort, non-fatal.
  if command -v vim >/dev/null 2>&1 && [[ -f "$HOME/.vim/autoload/plug.vim" ]]; then
    info "Installing vim plugins..."
    run vim +PlugInstall +qall >/dev/null 2>&1 || warn "vim PlugInstall had issues"
  fi
  ok "Shell configured"
}

# ============================================================================
# phase: macos  (defaults write tweaks + dock cleanup)
# ============================================================================
phase_macos() {
  step "macOS defaults"

  # --- the dock-cleanup one-liner: nuke the default app clutter ---
  info "Clearing the default Dock clutter..."
  run defaults write com.apple.dock persistent-apps -array
  run defaults write com.apple.dock persistent-others -array
  run killall Dock 2>/dev/null || true
  ok "Dock emptied (it'll repopulate as you pin apps)"

  # --- keyboard: fast key repeat, no press-and-hold accent popover ---
  run defaults write NSGlobalDomain KeyRepeat -int 2
  run defaults write NSGlobalDomain InitialKeyRepeat -int 15
  run defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

  # --- finder ---
  run defaults write com.apple.finder ShowStatusBar -bool true
  run defaults write com.apple.finder ShowPathbar -bool true
  run defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
  run defaults write com.apple.finder AppleShowAllFiles -bool true
  run defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
  run defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
  run defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # --- screenshots -> ~/Pictures/Screenshots as png ---
  run mkdir -p "$HOME/Pictures/Screenshots"
  run defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
  run defaults write com.apple.screencapture type -string "png"

  # --- misc quality-of-life ---
  run defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true   # no .DS_Store on shares
  run defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true          # AirDrop over ethernet
  run defaults write NSGlobalDomain _HIHideMenuBar -bool true                         # auto-hide menu bar
  run chflags nohidden "$HOME/Library"

  run killall Finder 2>/dev/null || true
  ok "Applied defaults (some need a logout/login to fully take)"
}

# ============================================================================
# phase: yabai  (scripting-addition wiring; SIP is a manual Recovery step)
# ============================================================================
phase_yabai() {
  step "yabai scripting addition"
  local yb; yb="$(command -v yabai || true)"
  [[ -n "$yb" ]] || { warn "yabai not installed (homebrew phase), skipping"; return 0; }

  # Passwordless sudoers entry so `yabai --load-sa` runs without a prompt.
  # The hash is tied to this exact yabai binary; re-run after `brew upgrade yabai`.
  local hash line
  hash="$(shasum -a 256 "$yb" | cut -d' ' -f1)"
  line="$(whoami) ALL=(root) NOPASSWD: sha256:$hash $yb --load-sa"
  if (( DRY_RUN )); then
    info "[dry-run] ensure /etc/sudoers.d/yabai has sha256:$hash"
  elif sudo grep -qsF "$hash" /etc/sudoers.d/yabai 2>/dev/null; then
    ok "sudoers entry already current"
  else
    runsh "echo '$line' | sudo tee /etc/sudoers.d/yabai >/dev/null"
    run sudo chmod 440 /etc/sudoers.d/yabai
    ok "Wrote /etc/sudoers.d/yabai"
  fi

  # Start the service and load the SA.
  run brew services start yabai 2>/dev/null || true
  run "$yb" --load-sa 2>/dev/null || warn "yabai --load-sa failed (expected until SIP is configured)"

  # SIP — cannot be changed from the booted OS; report and instruct.
  local sip; sip="$(csrutil status 2>/dev/null || echo unknown)"
  if echo "$sip" | grep -qi "disabled"; then
    ok "SIP already disabled/configured — full SA support available"
  else
    warn "SIP is enabled. The yabai scripting addition (spaces/SA features) needs it"
    warn "partially disabled. This is the ONE manual step:"
    info "  1. Apple menu -> Shut Down, then hold the power button to reach Recovery"
    info "  2. Utilities -> Terminal, then run:"
    info "       csrutil disable --with kext --with dtrace --with nvram --with basesystem"
    info "  3. Reboot, then re-run:  ./bootstrap.sh --only yabai"
  fi
}

# ============================================================================
# phase: agents  (install selected LaunchAgents from templates)
# ============================================================================
agent_label_for() { # map short name -> template filename
  case "$1" in
    cadence)          echo "com.justfielding.cadence.plist" ;;
    glean)            echo "com.glean.idle-trigger.plist" ;;
    weather)          echo "com.weather.desktop.plist" ;;
    sync-tix-to-vault)echo "com.fielding.sync-tix-to-vault.plist" ;;
    ollama)           echo "com.fielding.ollama.plist" ;;
    *)                echo "" ;;
  esac
}

phase_agents() {
  step "LaunchAgents"
  (( NO_AGENTS )) && { ok "Skipped (--no-agents)"; return 0; }
  [[ -d "$AGENT_TEMPLATES" ]] || { warn "no agent templates dir, skipping"; return 0; }

  local list=("${DEFAULT_AGENTS[@]}")
  if [[ -n "$AGENTS_OVERRIDE" ]]; then IFS=',' read -r -a list <<< "$AGENTS_OVERRIDE"; fi

  local brew_bin ollama_bin dest
  brew_bin="$(brew --prefix 2>/dev/null)/bin"; [[ -d "$brew_bin" ]] || brew_bin="/opt/homebrew/bin"
  ollama_bin="$(command -v ollama || echo "$brew_bin/ollama")"
  dest="$HOME/Library/LaunchAgents"
  run mkdir -p "$dest"

  local name tmpl out label tmplname
  for name in "${list[@]}"; do
    tmplname="$(agent_label_for "$name")"
    tmpl="$AGENT_TEMPLATES/$tmplname"
    if [[ -z "$tmplname" || ! -f "$tmpl" ]]; then
      warn "unknown agent '$name', skipping"; continue
    fi
    label="$tmplname"
    out="$dest/$label"
    if (( DRY_RUN )); then
      info "[dry-run] render+install $label"; continue
    fi
    sed -e "s|__HOME__|$HOME|g" \
        -e "s|__BREW_BIN__|$brew_bin|g" \
        -e "s|__OLLAMA_BIN__|$ollama_bin|g" \
        "$tmpl" > "$out"
    launchctl unload "$out" >/dev/null 2>&1 || true
    if launchctl load -w "$out" >/dev/null 2>&1; then ok "Loaded $label"; else warn "could not load $label"; fi
  done
  info "Available agents: cadence glean weather sync-tix-to-vault ollama"
}

# ============================================================================
# phase: continuity  (Handoff/Universal Control toggles + checklist)
# ============================================================================
phase_continuity() {
  step "Continuity / Universal Control"
  # Enable Handoff advertise/receive (Universal Control + Universal Clipboard ride on this).
  run defaults -currentHost write com.apple.coreservices.useractivityd ActivityAdvertisingAllowed -bool true
  run defaults -currentHost write com.apple.coreservices.useractivityd ActivityReceivingAllowed -bool true
  ok "Handoff advertise/receive enabled"
  info "Manual steps to make the M4 + M5 act like one desk:"
  info "  - Same Apple ID on both Macs (selective iCloud on the work machine is fine)"
  info "  - Wi-Fi + Bluetooth on, both on the same network"
  info "  - System Settings -> Displays -> Advanced -> 'Allow your pointer and"
  info "    keyboard to move between any nearby Mac' (toggle on BOTH machines)"
  info "  - Then drag the cursor off the screen edge toward the other Mac"
}

# ============================================================================
# phase: mlx  (Apple-Silicon local-model stack)
# ============================================================================
phase_mlx() {
  step "MLX local-model stack"
  if [[ "$(uname -m)" != "arm64" ]]; then warn "MLX is Apple-Silicon only, skipping"; return 0; fi
  if ! command -v uv >/dev/null 2>&1; then warn "uv not found (homebrew phase installs it), skipping"; return 0; fi
  info "Installing mlx-lm (run models with 'mlx_lm.generate', serve with 'mlx_lm.server')..."
  run uv tool install --upgrade mlx-lm || warn "mlx-lm install had issues"
  ok "MLX ready — 'mlx_lm.server --port 8080' gives an OpenAI-compatible local endpoint"
}

# ============================================================================
# runner
# ============================================================================
usage() {
  sed -n '2,29p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  echo
  echo "Phases: ${ALL_PHASES[*]}"
}

in_csv() { local n="$1" csv="$2" x; IFS=',' read -r -a _a <<< "$csv"; for x in "${_a[@]}"; do [[ "$x" == "$n" ]] && return 0; done; return 1; }

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --list)      printf 'Phases:\n'; printf '  %s\n' "${ALL_PHASES[@]}"; exit 0 ;;
      --only)      ONLY="$2"; shift 2 ;;
      --only=*)    ONLY="${1#*=}"; shift ;;
      --skip)      SKIP="$2"; shift 2 ;;
      --skip=*)    SKIP="${1#*=}"; shift ;;
      --agents)    AGENTS_OVERRIDE="$2"; shift 2 ;;
      --agents=*)  AGENTS_OVERRIDE="${1#*=}"; shift ;;
      --no-agents) NO_AGENTS=1; shift ;;
      --dry-run|-n) DRY_RUN=1; shift ;;
      --yes|-y)    ASSUME_YES=1; shift ;;
      -h|--help)   usage; exit 0 ;;
      *)           die "unknown option: $1 (try --help)" ;;
    esac
  done

  (( DRY_RUN )) && step "DRY RUN — no changes will be made"

  local p
  for p in "${ALL_PHASES[@]}"; do
    [[ -n "$ONLY" ]] && { in_csv "$p" "$ONLY" || continue; }
    [[ -n "$SKIP" ]] && { in_csv "$p" "$SKIP" && { info "skipping $p"; continue; }; }
    "phase_$p"
  done

  step "Done"
  info "If the shell or many defaults changed, log out and back in (or reboot)."
  (( DRY_RUN )) && info "That was a dry run — re-run without --dry-run to apply."
}

main "$@"
