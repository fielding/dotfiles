#!/bin/sh
# build.sh — compile holdpeek into a minimal .app bundle.
#
# Like mouse-tap: a bare CLI binary can't reliably get the Input Monitoring
# (TCC) grant, so we wrap it in a tiny LSUIElement .app with a stable bundle id
# (com.fielding.holdpeek). The binary is per-machine and NOT committed; only the
# source lives in the repo. The launchd agent runs the binary inside the bundle.
#
# Note: the grant is keyed partly on the binary's cdhash, so recompiling may
# require re-granting Input Monitoring once.

set -eu

src_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
app="$HOME/.local/libexec/holdpeek/holdpeek.app"
macos="$app/Contents/MacOS"

mkdir -p "$macos"
swiftc -O "$src_dir/holdpeek.swift" -o "$macos/holdpeek"

cat > "$app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key><string>holdpeek</string>
  <key>CFBundleIdentifier</key><string>com.fielding.holdpeek</string>
  <key>CFBundleName</key><string>holdpeek</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

codesign --force --sign - "$app" >/dev/null 2>&1 || true
echo "built $app"
