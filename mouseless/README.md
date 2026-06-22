# mouseless

Objectively find where the keyboard falls short and the mouse takes over —
so keyboard-navigation effort gets spent where you actually bleed to the mouse,
not where you *think* you do.

## Idea

Three local logs, joined by time:

| Log | Source | What it is |
|-----|--------|------------|
| `~/.local/share/skhd/usage.log` | `skl` (already running) | every intentional keyboard action (mode key action) |
| `~/.local/share/mouseless/focus.jsonl` | `log-focus` via yabai signals | **ground truth**: which window/app/space/display got focus, when |
| `~/.local/share/mouseless/mouse.jsonl` | `mouse-tap` (launchd) | mouse-down + scroll + a 1/sec keyboard-activity heartbeat |

A focus change with **no keyboard nav-binding in the ~2s around it** = you used
the mouse. Ranked by app→app transition, those are your highest-value keybind
targets. `mouse-report` is the analyzer; it's the complement to `skl-report`,
which ranks the keyboard side.

Privacy: `mouse-tap` records button + location + timestamp only. The keyboard
heartbeat is timestamps only — **no keycodes, ever**. Everything stays local.

## Components

| File | Installed to | Role |
|------|--------------|------|
| `bin/bin/log-focus` | `~/bin/log-focus` | yabai signal handler → appends focus rows |
| `mouseless/mouse-tap.swift` | (source) | listen-only CGEventTap |
| `mouseless/build.sh` | — | compiles → `~/.local/libexec/mouseless/mouse-tap.app` |
| `bootstrap/launchagents/com.fielding.mouse-tap.plist` | `~/Library/LaunchAgents/` | runs mouse-tap with KeepAlive |
| `bin/bin/mouse-report` | `~/bin/mouse-report` | the analyzer |
| `yabai/.yabairc` | (signals) | `window_focused` / `application_front_switched` / `display_changed` → log-focus |

## Install (per machine)

```sh
sh ~/etc/mouseless/build.sh                    # compile the .app bundle
./bootstrap.sh --agents mouse-tap              # render + load the launchd agent
#   (yabai signals + scripts come via stow + .yabairc on a normal bootstrap)
```

Then grant **Input Monitoring** to `mouse-tap` in
System Settings → Privacy & Security → Input Monitoring, and restart the agent:

```sh
launchctl kickstart -k "gui/$(id -u)/com.fielding.mouse-tap"
```

The grant is keyed partly on the binary's cdhash, so **recompiling may require
re-granting** Input Monitoring once.

## Use

```sh
mouse-report              # full report
mouse-report --days 3     # last 3 days only
mouse-report --top 25     # widen the ranked tables
```

## Phase 3 (after a week of data)

Build the fixes the data points to. Early candidates: a native fuzzy
window-switcher (yabai query → `choose` → focus), un-gating directional focus
out of terminals, and the ctrl-j/k passthrough leak. Let `mouse-report`
prioritize.
