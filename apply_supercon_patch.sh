#!/bin/bash
# apply_supercon_patch.sh - Patches device-ui library for Supercon 2025
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🔧 Applying Supercon 2025 patches to device-ui library..."

# Find device-ui library
DEVICE_UI_DIR=$(find meshtastic-firmware/.pio -path "*/libdeps/*/meshtastic-device-ui" -type d 2>/dev/null | head -1)

if [ -z "$DEVICE_UI_DIR" ]; then
    echo "❌ ERROR: device-ui library not found!"
    echo "Run: cd meshtastic-firmware && pio pkg install -e supercon_2025"
    exit 1
fi

echo "Found device-ui at: $DEVICE_UI_DIR"

# 1. Copy LGFX header file
echo "📝 Installing LGFX_SUPERCON_2025.h..."
mkdir -p "$DEVICE_UI_DIR/include/graphics/LGFX"
cp meshtastic_variant/supercon_2025/device-ui-patches/graphics/LGFX/LGFX_SUPERCON_2025.h \
   "$DEVICE_UI_DIR/include/graphics/LGFX/"

# 2. Patch DisplayDriverFactory.cpp to include our header
FACTORY_FILE="$DEVICE_UI_DIR/source/graphics/driver/DisplayDriverFactory.cpp"

echo "🩹 Patching DisplayDriverFactory.cpp..."

# Check if already patched
if grep -q "SUPERCON_2025" "$FACTORY_FILE"; then
    echo "✓ Already patched!"
else
    # Add the include after the UNPHONE block
    sed -i '/^#ifdef UNPHONE$/a\
#ifdef SUPERCON_2025\
#include "graphics/LGFX/LGFX_SUPERCON_2025.h"\
#endif' "$FACTORY_FILE"

    echo "✓ Patch applied!"
fi

# Verify the patch
if grep -q "LGFX_SUPERCON_2025" "$FACTORY_FILE"; then
    echo "✅ DisplayDriverFactory.cpp successfully patched!"
else
    echo "❌ ERROR: Patch verification failed!"
    exit 1
fi

echo ""
echo "✅ All patches applied successfully!"
echo ""
echo "Now rebuild:"
echo "  cd meshtastic-firmware"
echo "  pio run --target clean"
echo "  pio run -e supercon_2025 -j \$(nproc)"
