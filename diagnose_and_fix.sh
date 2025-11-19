#!/bin/bash
# diagnose_and_fix.sh - Fix LGFX driver setup and build
set -e

LINUX_DIR="$HOME/meshtastic-supercon-build"

cd "$LINUX_DIR/meshtastic-firmware"

# Find and show the file
FACTORY=$(find .pio/libdeps/supercon_2025 -name "DisplayDriverFactory.cpp" -path "*/meshtastic-device-ui/*" 2>/dev/null | head -1)

echo "════════════════════════════════════════"
echo "File: $FACTORY"
echo "════════════════════════════════════════"
echo ""
echo "Current lines 45-55:"
sed -n '45,55p' "$FACTORY"
echo ""

# Check if patch needed
if ! grep -q "LGFX_SUPERCON_2025" "$FACTORY"; then
    echo "❌ Patch NOT applied - applying now..."
    cp "$FACTORY" "$FACTORY.backup"
    awk '/^#ifdef UNPHONE$/,/^#endif$/ {print; if (/^#endif$/) {print "#ifdef SUPERCON_2025"; print "#include \"graphics/LGFX/LGFX_SUPERCON_2025.h\""; print "#endif"}; next} {print}' "$FACTORY.backup" > "$FACTORY"
    echo ""
    echo "✅ Patch applied. New lines 45-58:"
    sed -n '45,58p' "$FACTORY"
else
    echo "✅ Patch already applied"
fi

# Verify LGFX header exists
echo ""
LGFX_HEADER=$(find .pio/libdeps/supercon_2025 -path "*/meshtastic-device-ui/include/graphics/LGFX/LGFX_SUPERCON_2025.h" 2>/dev/null | head -1)
if [ -f "$LGFX_HEADER" ]; then
    echo "✅ LGFX header found: $LGFX_HEADER"
else
    echo "❌ LGFX header missing - copying now..."
    LGFX_DIR=$(dirname "$FACTORY" | sed 's|source/graphics/driver|include/graphics/LGFX|')
    mkdir -p "$LGFX_DIR"
    cp meshtastic_variant/supercon_2025/device-ui-patches/graphics/LGFX/LGFX_SUPERCON_2025.h "$LGFX_DIR/"
    echo "✅ Copied to: $LGFX_DIR/LGFX_SUPERCON_2025.h"
fi

# Clean and build
echo ""
echo "🧹 Cleaning build cache..."
rm -rf .pio/build/supercon_2025
echo "✅ Cache cleared"
echo ""
echo "🔨 Building firmware..."
pio run -e supercon_2025 -j $(nproc)
