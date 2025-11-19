#!/bin/bash
# patch_and_build.sh - Patch device-ui and build Supercon 2025 firmware
set -e

cd "$(dirname "$0")"

echo "════════════════════════════════════════════════════"
echo "  Supercon 2025 - Patch & Build"
echo "════════════════════════════════════════════════════"
echo ""

# Step 1: Find DisplayDriverFactory.cpp
echo "[1/4] Finding device-ui library..."
FACTORY=$(find meshtastic-firmware/.pio -name "DisplayDriverFactory.cpp" -path "*/meshtastic-device-ui/*" 2>/dev/null | head -1)

if [ -z "$FACTORY" ]; then
    echo "ERROR: DisplayDriverFactory.cpp not found!"
    echo "Run this first: cd meshtastic-firmware && pio pkg install -e supercon_2025"
    exit 1
fi

echo "✓ Found: $FACTORY"

# Step 2: Patch DisplayDriverFactory.cpp
echo ""
echo "[2/4] Patching DisplayDriverFactory.cpp..."
if grep -q "SUPERCON_2025" "$FACTORY" 2>/dev/null; then
    echo "✓ Already patched"
else
    sed -i '/^#ifdef UNPHONE$/a\
#ifdef SUPERCON_2025\
#include "graphics/LGFX/LGFX_SUPERCON_2025.h"\
#endif' "$FACTORY"
    echo "✓ Patch applied"
fi

# Step 3: Copy LGFX header
echo ""
echo "[3/4] Installing LGFX_SUPERCON_2025.h..."
LGFX_DIR=$(dirname "$FACTORY" | sed 's|source/graphics/driver|include/graphics/LGFX|')
mkdir -p "$LGFX_DIR"
cp meshtastic_variant/supercon_2025/device-ui-patches/graphics/LGFX/LGFX_SUPERCON_2025.h "$LGFX_DIR/"
echo "✓ LGFX header installed"

# Verify both files exist
if [ -f "$LGFX_DIR/LGFX_SUPERCON_2025.h" ] && grep -q "SUPERCON_2025" "$FACTORY"; then
    echo "✓ Patch verification successful"
else
    echo "ERROR: Patch verification failed!"
    exit 1
fi

# Step 4: Build firmware
echo ""
echo "[4/4] Building firmware..."
echo "This will take 5-10 minutes on first build..."
echo ""

cd meshtastic-firmware
pio run -e supercon_2025 -j $(nproc)

echo ""
echo "════════════════════════════════════════════════════"
echo "  ✅ BUILD SUCCESSFUL!"
echo "════════════════════════════════════════════════════"
echo ""
echo "Firmware: meshtastic-firmware/.pio/build/supercon_2025/firmware.bin"
echo ""
echo "To flash:"
echo "  cd meshtastic-firmware"
echo "  pio run -e supercon_2025 -t upload"
echo ""
