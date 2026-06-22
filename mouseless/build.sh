#!/bin/sh
# build.sh — compile mouse-tap into a minimal .app bundle.
#
# A bare CLI binary can't reliably trigger the Input Monitoring (TCC) prompt or
# show up in System Settings. Wrapping it in a tiny LSUIElement .app gives it a
# stable bundle identity (com.fielding.mouse-tap) so macOS prompts for the grant
# and lists it. The launchd agent runs the binary inside the bundle.
#
# Output: ~/.local/libexec/mouseless/mouse-tap.app  (NOT committed; per-machine)
#
# Note: the grant is keyed partly on the binary's cdhash, so recompiling may
# require re-granting Input Monitoring. Acceptable for a personal tool.

set -eu

src_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
app="$HOME/.local/libexec/mouseless/mouse-tap.app"
macos="$app/Contents/MacOS"

mkdir -p "$macos"
swiftc -O "$src_dir/mouse-tap.swift" -o "$macos/mouse-tap"

cat > "$app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key><string>mouse-tap</string>
  <key>CFBundleIdentifier</key><string>com.fielding.mouse-tap</string>
  <key>CFBundleName</key><string>mouse-tap</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

# Ad-hoc sign so the bundle has a consistent code identity for TCC.
codesign --force --sign - "$app" >/dev/null 2>&1 || true

echo "built $app"
