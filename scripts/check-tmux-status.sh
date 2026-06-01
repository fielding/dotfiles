#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/home/src/hack/human-plus-plus/dist/tmux" "$tmp/bin"
cat > "$tmp/home/src/hack/human-plus-plus/dist/tmux/colors.sh" <<'COLORS'
HMPP_BG="#101010"
HMPP_BG_ELEVATION="#202020"
HMPP_CYAN="#00ffff"
HMPP_PINK="#ff00ff"
HMPP_FG="#eeeeee"
COLORS

cat > "$tmp/bin/pmset" <<'PMSET'
#!/bin/sh
cat <<'OUT'
Now drawing from 'Battery Power'
 -InternalBattery-0 (id=1234567) 87%; discharging; 4:21 remaining
OUT
PMSET
chmod +x "$tmp/bin/pmset"

cat > "$tmp/bin/istats" <<'ISTATS'
#!/bin/sh
echo "CPU temp 47.0 C"
ISTATS
chmod +x "$tmp/bin/istats"

cat > "$tmp/bin/top" <<'TOP'
#!/bin/sh
echo "CPU usage: 12.5% user, 10.0% sys, 77.5% idle"
TOP
chmod +x "$tmp/bin/top"

cat > "$tmp/bin/iostat" <<'IOSTAT'
#!/bin/sh
touch "$TMUX_STATUS_IOSTAT_CALLED"
echo "iostat should not be used by tmux-status" >&2
exit 99
IOSTAT
chmod +x "$tmp/bin/iostat"

export HOME="$tmp/home"
export PATH="$tmp/bin:$PATH"
export TMUX_STATUS_IOSTAT_CALLED="$tmp/iostat-called"

output=$("$repo_root/bin/bin/tmux-status")

case "$output" in
  *"(id="*)
    echo "tmux-status leaked pmset battery id instead of battery percent:" >&2
    echo "$output" >&2
    exit 1
    ;;
esac

case "$output" in
  *"-87%"*) : ;;
  *)
    echo "tmux-status did not render parsed battery percentage (-87%):" >&2
    echo "$output" >&2
    exit 1
    ;;
esac

if [ -e "$TMUX_STATUS_IOSTAT_CALLED" ]; then
  echo "tmux-status used slow iostat path instead of single-sample top CPU usage" >&2
  exit 1
fi

printf '%s\n' "tmux-status smoke OK"
