#!/bin/bash
# Creates the full Arduino board package zip for Bluepad32.
# Run from the repo root after a successful build:
#   bash ./tools/package-bluepad32.sh
#
# Output: dist/esp32-bluepad32-<version>.zip

set -e
source ./tools/config.sh

VERSION=$(grep '"version"' bluepad32_files/package.json | sed 's/.*: *"\(.*\)".*/\1/')
STAGING="/tmp/esp32-bluepad32"
BOARD_ZIP="$AR_ROOT/dist/esp32-bluepad32-$VERSION.zip"

echo "* Packaging Bluepad32 board zip v$VERSION"

rm -rf "$STAGING"
mkdir -p "$STAGING"

# ── arduino-esp32 framework source ──────────────────────────────────────────
echo "  copying arduino-esp32 source..."
for d in cores libraries variants tools; do
    [ -d "$AR_COMPS/arduino/$d" ] && cp -r "$AR_COMPS/arduino/$d" "$STAGING/"
done
for f in boards.txt programmers.txt; do
    [ -f "$AR_COMPS/arduino/$f" ] && cp "$AR_COMPS/arduino/$f" "$STAGING/"
done

# ── precompiled libs (all targets that were built) ───────────────────────────
echo "  embedding precompiled libs..."
mkdir -p "$STAGING/tools"
cp -r "$AR_TOOLS/esp32-arduino-libs" "$STAGING/tools/"

# ── bluepad32_files overlay ───────────────────────────────────────────────────
echo "  applying bluepad32_files overlay..."
cp bluepad32_files/boards.txt      "$STAGING/"
cp bluepad32_files/platform.txt    "$STAGING/"
cp bluepad32_files/package.json    "$STAGING/"
[ -f bluepad32_files/programmers.txt ] && cp bluepad32_files/programmers.txt "$STAGING/"
if [ -d bluepad32_files/libraries ]; then
    mkdir -p "$STAGING/libraries"
    cp -r bluepad32_files/libraries/* "$STAGING/libraries/"
fi

# ── fix libs path to use embedded location ────────────────────────────────────
# platform.txt default references {runtime.tools.esp32-arduino-libs.path}
# which requires a board-manager tools download; replace with the embedded path.
sed -i 's|tools\.esp32-arduino-libs\.path={runtime\.tools\.esp32-arduino-libs\.path}|tools.esp32-arduino-libs.path={runtime.platform.path}/tools/esp32-arduino-libs|' \
    "$STAGING/platform.txt"

# ── zip ───────────────────────────────────────────────────────────────────────
mkdir -p "$AR_ROOT/dist"
rm -f "$BOARD_ZIP"
echo "  creating zip..."
cd /tmp && zip -r "$BOARD_ZIP" "esp32-bluepad32" > /dev/null
echo "* Done: $BOARD_ZIP"
echo "  Size: $(du -sh "$BOARD_ZIP" | cut -f1)"
