#!/bin/bash
# Regenerates Resources/AppIcon.icns from the light-appearance source icon.
#
# Classic .icns doesn't support macOS's automatic light/dark Dock-icon switching
# (that needs Xcode's asset-catalog "Icon Composer" pipeline, which requires a full
# Xcode project rather than a hand-assembled SPM app bundle) — so this ships one
# icon design that reads clearly on both backgrounds. Resources/icon-source/ keeps
# both the light and dark originals for whenever that pipeline is worth adopting.
set -euo pipefail
cd "$(dirname "$0")/.."

SRC="Resources/icon-source/pocket-icon-light.png"
ICONSET=$(mktemp -d)/AppIcon.iconset
mkdir -p "$ICONSET"

sips -z 16 16     "$SRC" --out "$ICONSET/icon_16x16.png" > /dev/null
sips -z 32 32     "$SRC" --out "$ICONSET/icon_16x16@2x.png" > /dev/null
sips -z 32 32     "$SRC" --out "$ICONSET/icon_32x32.png" > /dev/null
sips -z 64 64     "$SRC" --out "$ICONSET/icon_32x32@2x.png" > /dev/null
sips -z 128 128   "$SRC" --out "$ICONSET/icon_128x128.png" > /dev/null
sips -z 256 256   "$SRC" --out "$ICONSET/icon_128x128@2x.png" > /dev/null
sips -z 256 256   "$SRC" --out "$ICONSET/icon_256x256.png" > /dev/null
sips -z 512 512   "$SRC" --out "$ICONSET/icon_256x256@2x.png" > /dev/null
sips -z 512 512   "$SRC" --out "$ICONSET/icon_512x512.png" > /dev/null
sips -z 1024 1024 "$SRC" --out "$ICONSET/icon_512x512@2x.png" > /dev/null

iconutil -c icns "$ICONSET" -o Resources/AppIcon.icns
rm -rf "$(dirname "$ICONSET")"

echo "Wrote Resources/AppIcon.icns"
