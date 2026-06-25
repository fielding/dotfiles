# Keybinding Catalog

The current state of every keybinding layer on the machine, so it can be
reviewed and de-drifted. Generated 2026-06-22 from the live configs.

## How the layers stack (precedence)

A physical keypress flows top → bottom; each layer can swallow or rewrite it
before the next sees it:

```
Karabiner   (remaps keys/modifiers, per-device)        ← layer 0, runs first
   ↓
skhd        (global hotkeys + modal system)            ← layer 2
yabai       (mouse modifiers only)
   ↓
app         tmux (inside terminal) · Ghostty · Zed · vim
```

So skhd and every app see the **post-Karabiner** key. That's why the Karabiner
remaps below matter so much — they're invisible from every layer above.

---

## Layer 0 — Karabiner  (`~/.config/karabiner/karabiner.json`)

Profile: **usb keyboard and mouse**. The important, easy-to-forget stuff:

### Global remaps (all keyboards)
| Physical | Becomes | Notes |
|----------|---------|-------|
| `caps_lock` | `control` held / `escape` tapped alone | classic dual-role |
| `escape` (the physical Esc key) | `` ` `` / `~` (grave/tilde) | **Esc key no longer sends Escape** |
| `left_shift`+`right_shift` together | toggle `caps_lock` | otherwise normal shift |

### Device-specific — a RETIRED board (vendor 1241 / product 6168, Holtek)
| Physical | Becomes | Notes |
|----------|---------|-------|
| `left_command` ⇄ `left_option` | **swapped** | ⌘ and ⌥ positions trade places |
| `right_command` ⇄ `right_option` | **swapped** | same on the right |
| `application` (menu key) | `fn` | |
| `insert` | disabled | |

> ⚠️ **This board is not connected** (confirmed 2026-06-23). The current external
> keyboard is a **GMMK 3 PRO HE Wireless (vendor 13357)**, which has no Karabiner
> device entry — so it gets only the global rules above and **no ⌘/⌥ swap**. This
> whole block is dead config for a retired keyboard; candidate for deletion. Any
> modifier weirdness on the GMMK is its own firmware Mac/Win mode, not Karabiner.

### fn function keys
`f3`→Mission Control · `f4`→Launchpad · `f5`/`f6`→keyboard illumination ∓ ·
`f9`→fast-forward

### Disabled rules (present but off)
- "Block left/right-handed shift + same-hand key" (two typing-discipline drills)
- Nox App Player: ⌘+PageUp/Down → mouse wheel (app-specific)

---

## Layer 1 — yabai mouse  (`~/.yabairc`)

| Input | Action |
|-------|--------|
| `fn` + left-drag | move window |
| `fn` + right-drag | resize window |

`mouse_follows_focus` and `focus_follows_mouse` are **off**. No keyboard binds
live in yabai — those are all skhd.

---

## Layer 2 — skhd  (`~/.skhdrc`)  — the modal system

### Modes & transitions
| Mode | Border color | Enter from default | Exit |
|------|--------------|--------------------|------|
| default | pink | — | — |
| switcher | cyan | `ctrl-f` | `ctrl-f` / `escape`* |
| swap | blue | switcher → `m` | `escape`* |
| layout | purple | switcher → `l` | `escape`* |
| tree | amber | switcher → `s` | `escape`* |
| meet | orange | `ctrl-m` | `ctrl-m` / `escape`* |
| tmux | lime | switcher → `t` | `escape`* |

> *“escape” here means the skhd `escape` keysym = **caps-lock tapped** (your real
> Escape). The physical Esc key sends `` ` `` (see Karabiner), so it will **not**
> exit a mode. Exit with caps-lock or `ctrl-f`.

### Default mode (no mode needed)
| Key | Action |
|-----|--------|
| `alt-e` | balance space |
| `alt-r` | rotate space 90° |
| `alt-f` | toggle zoom-fullscreen |
| `alt-t` | toggle float + 2×2 center grid |
| `alt-w` | **fuzzy window picker (pik)** — new |
| `ctrl-1`…`ctrl-0` | focus space 1–10; re-press = cycle that space's windows |
| `ctrl-h/j/k/l` | focus west/south/north/east (**passes through inside terminals**) |
| `shift+alt-up/left/right` | floating window: full / left-half / right-half |
| `cmd+shift+ctrl+alt-d` (hyper-d) | Meet mic toggle (quick) |
| `cmd+shift-return` | new Ghostty window |
| `ctrl-/` | toggle cheatsheet popup |
| `ctrl-f` → switcher · `ctrl-m` → meet | mode entry |

### switcher mode (cyan)
| Key | Action |
|-----|--------|
| `m`/`l`/`s`/`g`/`t` | → swap / layout / tree / meet / tmux modes |
| `o` | LLM window organize |
| `return` | new terminal |
| `cmd+shift-1…0` | move window to space 1–10 **and follow** |
| `shift-1…0` | send window to space 1–10 (no follow) |
| `x`/`z`/`c` | focus monitor last / prev / next |
| `1`/`2` | focus monitor 1 / 2 |
| `cmd-x`/`z`/`c` | send window to monitor last/prev/next + follow |
| `cmd-1`/`2` | send window to monitor 1 / 2 + follow |

### swap mode (blue)
| Key | Action |
|-----|--------|
| `h/j/k/l` | swap window west/south/north/east |
| `shift+h/j/k/l` | warp window |
| `y` / `x` | mirror tree y-axis / x-axis |
| `s` | stack next |

### layout mode (purple)
| Key | Action |
|-----|--------|
| `a` / `s` / `d` | layout bsp / stack / float |
| `o` | toggle padding + gap |

### tree mode (amber)
| Key | Action |
|-----|--------|
| `f` / `shift-f` | zoom fullscreen / native fullscreen |
| `d` | zoom parent |
| `w` | float + center grid |
| `r` | rotate 90° |
| `s` | toggle split |
| `m` | minimize |
| `h/j/k/l` | grow toward edge |
| `shift+h/j/k/l` | shrink |
| `e` | balance |
| `p` | pip (top-right grid) |

### meet mode (orange)
| Key | Action |
|-----|--------|
| `d` / `e` / `q` | mic / camera / leave (sends ⌘D / ⌘E / ⌘⇧B to browser) |

### tmux mode (lime) — drives tmux from outside it
| Key | Action |
|-----|--------|
| `f` | sessionizer popup |
| `space` | last session |
| `r` / `s` | rename / new session |
| `x` / `shift-x` | kill session / pick-kill popup |
| `1`…`9` | select window 1–9 |
| `h` / `l` | prev / next window |
| `n` / `p` | next / prev session |
| `c` / `d` / `w` | new / kill / rename window |
| `return` / `\` | split (labelled h/v — see drift #6) |

---

## Layer 3 — tmux  (`~/.tmux.conf`)  — prefix `Ctrl-Space`

| Key (after prefix) | Action |
|--------------------|--------|
| `Enter` / `\` | split vertical / horizontal (inherit cwd) |
| `c` | new window (inherit cwd) |
| `C-p` / `C-n` / `a` | prev / next / last window |
| `1`…`9` | select window |
| `f` | sessionizer (new window) |
| `s` | choose-tree session picker |
| `d` | detach |
| `X` | kill session (confirm) |
| `Space` | last session |
| `r` / `w` | rename session / window |
| `C` | claude-sessions launcher |
| `R` / `S` | reload config / toggle status bar |
| copy-mode `v` / `y` | begin selection / copy to pbcopy |

**Plugins that add bindings:**
- `tmux-pain-control` — `h/j/k/l` pane nav, `H/J/K/L` pane resize (no prefix mode)
- `vim-tmux-navigator` — **`C-h/j/k/l` move seamlessly across vim splits + tmux panes** (this is what "eats" ctrl-hjkl in the terminal)
- `tmux-better-mouse-mode`, `tmux-resurrect`, `tmux-continuum` (restore)

---

## Layer 4 — apps

- **Ghostty** — **no custom keybinds** (config is theme + shader only). Uses
  stock bindings: `⌘T` tab, `⌘W` close, `⌘D`/`⌘⇧D` split, `⌘↵` fullscreen,
  `⌘[`/`⌘]` + `⌘⇧[`/`⌘⇧]` navigate splits/tabs.
- **Zed** — **no custom keymap** (`~/.config/zed/keymap.json` bindings all
  commented out). Stock Zed + whatever vim mode setting is on.
- **vim** — minimal `.vimrc` (30 lines); not catalogued here. Say the word to
  include it.

---

## Drift, conflicts & things to make sense of

1. **~~⌘/⌥ swap~~ — RESOLVED.** The swap is bound to a retired board (1241) that
   isn't connected; the current GMMK gets no swap. The dead device block in
   `karabiner.json` is a deletion candidate.
2. **Physical Esc doesn't Escape.** It sends `` ` ``; real Escape is caps-lock.
   Mode-exit therefore needs caps-lock or `ctrl-f`, never the Esc key. Easy to
   forget when a mode "won't exit."
3. **skhd tmux-mode vs native tmux prefix = two diverged interfaces.** Same ops,
   different keys (e.g. `s` = new-session in skhd, choose-tree in tmux; `f`
   popup vs new-window). Pick a canonical one or align them.
4. **`s` is overloaded** across modes: size(switcher) / stack(swap & layout) /
   split(tree) / new-session(tmux). Modal so not a *conflict*, but mnemonically
   noisy.
5. **`hjkl` action differs by mode**: focus / swap / resize / window-nav. The
   vim-direction metaphor holds, but the verb changes each mode.
6. **Split-label inversion (tmux mode):** `return` is labelled `split:h` but runs
   `split-window -v`; `\` labelled `split:v` runs `-h`. Labels are backwards.
7. **Directional focus stops at the terminal boundary.** `ctrl-hjkl` passes
   through in terminals (→ vim-tmux-navigator), so you can't directionally move
   focus *out of* a terminal to a GUI window. `focus:west/east` is ~unused in the
   data — likely the mouse fills this gap.
8. **Stale cheatsheet.** New binds (`alt-w`, tmux `shift-x`) won't be on the
   `ctrl-/` popup if it's hand-maintained.
9. **Meet mic has two paths** — `meet`-mode `d` and global hyper-`d`. Intentional
   redundancy; just noting.
