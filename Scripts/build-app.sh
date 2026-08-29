#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -d "/Applications/Xcode.app/Contents/Developer" ]; then
    export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
fi

echo "Building Pocket (release)…"
swift build -c release

BIN_PATH=".build/release/Pocket"
APP="Pocket.app"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp "$BIN_PATH" "$APP/Contents/MacOS/Pocket"
cp "Resources/Info.plist" "$APP/Contents/Info.plist"

if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"
else
    echo "Warning: Resources/AppIcon.icns not found — run Scripts/generate-icon.sh first. Continuing without a bundle icon."
fi

codesign --force --deep --sign - "$APP"

echo "Built $APP"
echo "Run it with: open \"$(pwd)/$APP\""
echo "Move it to /Applications with: cp -R \"$(pwd)/$APP\" /Applications/"
