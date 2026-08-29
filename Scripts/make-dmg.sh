#!/bin/bash
# Builds Pocket.app (release) and packages it into a distributable, branded .dmg in dist/.
set -euo pipefail
cd "$(dirname "$0")/.."

APP_NAME="Pocket"
VERSION=$(plutil -extract CFBundleShortVersionString raw -o - Resources/Info.plist)
DIST_DIR="dist"
STAGING_DIR="$DIST_DIR/dmg-staging"
RW_DMG="$DIST_DIR/${APP_NAME}-rw.dmg"
FINAL_DMG="$DIST_DIR/${APP_NAME}-${VERSION}.dmg"

echo "Building ${APP_NAME} ${VERSION} (release)…"
./Scripts/build-app.sh

rm -rf "$STAGING_DIR" "$RW_DMG" "$FINAL_DMG"
mkdir -p "$STAGING_DIR"

cp -R "${APP_NAME}.app" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"
cp Resources/AppIcon.icns "$STAGING_DIR/.VolumeIcon.icns"

hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING_DIR" -ov -format UDRW -fs HFS+ "$RW_DMG" -quiet

MOUNT_DIR=$(mktemp -d)
hdiutil attach "$RW_DMG" -mountpoint "$MOUNT_DIR" -nobrowse -quiet
SetFile -a C "$MOUNT_DIR" 2>/dev/null || true
hdiutil detach "$MOUNT_DIR" -quiet
rmdir "$MOUNT_DIR"

hdiutil convert "$RW_DMG" -format UDZO -ov -o "$FINAL_DMG" -quiet
rm -f "$RW_DMG"
rm -rf "$STAGING_DIR"

echo
echo "Created $FINAL_DMG"
