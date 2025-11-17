#!/bin/bash
# ABSOLUTE FIX for LGFX_DRIVER issue
set -e

cd "$(dirname "$0")"

echo "========================================="
echo "INSTALLING LGFX DRIVER - ABSOLUTE FIX"
echo "========================================="

# Source file
SRC="meshtastic_variant/supercon_2025/device-ui-patches/graphics/LGFX/LGFX_SUPERCON_2025.h"

# Find device-ui
DEST=$(find meshtastic-firmware/.pio -path "*/libdeps/*/meshtastic-device-ui/include/graphics/LGFX" -type d 2>/dev/null | head -1)

if [ -z "$DEST" ]; then
    echo "ERROR: device-ui not found in .pio directory!"
    echo "Run: cd meshtastic-firmware && pio pkg install -e supercon_2025"
    exit 1
fi

echo "Source: $SRC"
echo "Destination: $DEST"

cp -v "$SRC" "$DEST/" || exit 1

echo ""
echo "✅ LGFX_SUPERCON_2025.h installed!"
ls -lh "$DEST/LGFX_SUPERCON_2025.h"

echo ""
echo "Now rebuild:"
echo "  cd meshtastic-firmware && pio run -e supercon_2025 -j \$(nproc)"
