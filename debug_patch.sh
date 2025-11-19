#!/bin/bash
# debug_patch.sh - Debug why the patch isn't working
set -e

cd "$(dirname "$0")"

echo "════════════════════════════════════════════════════"
echo "  DEBUG: Checking DisplayDriverFactory.cpp"
echo "════════════════════════════════════════════════════"
echo ""

# Find the file
LINUX_DIR="$HOME/meshtastic-supercon-build"
cd "$LINUX_DIR"

FACTORY=$(find meshtastic-firmware/.pio -name "DisplayDriverFactory.cpp" -path "*/meshtastic-device-ui/*" 2>/dev/null | head -1)

if [ -z "$FACTORY" ]; then
    echo "ERROR: DisplayDriverFactory.cpp not found!"
    exit 1
fi

echo "Found file at:"
echo "  $FACTORY"
echo ""

echo "Checking for UNPHONE block:"
grep -n "^#ifdef UNPHONE" "$FACTORY" || echo "  NOT FOUND!"
echo ""

echo "Checking for SUPERCON_2025:"
grep -n "SUPERCON_2025" "$FACTORY" || echo "  NOT FOUND!"
echo ""

echo "Lines 45-55 of the file:"
sed -n '45,55p' "$FACTORY" | cat -n
echo ""

echo "Now applying patch manually..."
sed -i '/^#ifdef UNPHONE$/a\
#ifdef SUPERCON_2025\
#include "graphics/LGFX/LGFX_SUPERCON_2025.h"\
#endif' "$FACTORY"

echo ""
echo "After patch, checking for SUPERCON_2025:"
grep -n "SUPERCON_2025" "$FACTORY" || echo "  STILL NOT FOUND!"
echo ""

echo "Lines 45-60 after patch:"
sed -n '45,60p' "$FACTORY" | cat -n
echo ""

# Check if LGFX header exists
LGFX_DIR=$(dirname "$FACTORY" | sed 's|source/graphics/driver|include/graphics/LGFX|')
echo "Checking for LGFX header at:"
echo "  $LGFX_DIR/LGFX_SUPERCON_2025.h"
ls -lh "$LGFX_DIR/LGFX_SUPERCON_2025.h" 2>&1
echo ""

echo "════════════════════════════════════════════════════"
echo "If patch was applied, try building again:"
echo "  cd $LINUX_DIR/meshtastic-firmware"
echo "  pio run -e supercon_2025 -j \$(nproc)"
echo "════════════════════════════════════════════════════"
