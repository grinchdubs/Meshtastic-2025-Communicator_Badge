#!/bin/bash
# fix_patch.sh - Foolproof patch for DisplayDriverFactory.cpp
set -e

cd "$(dirname "$0")"

echo "════════════════════════════════════════════════════"
echo "  PATCH FIX - Adding SUPERCON_2025 support"
echo "════════════════════════════════════════════════════"
echo ""

LINUX_DIR="$HOME/meshtastic-supercon-build"
cd "$LINUX_DIR"

# Find DisplayDriverFactory.cpp
FACTORY=$(find meshtastic-firmware/.pio -name "DisplayDriverFactory.cpp" -path "*/meshtastic-device-ui/*" 2>/dev/null | head -1)

if [ -z "$FACTORY" ]; then
    echo "ERROR: DisplayDriverFactory.cpp not found!"
    exit 1
fi

echo "Patching: $FACTORY"

# Check if already patched
if grep -q "LGFX_SUPERCON_2025" "$FACTORY"; then
    echo "✓ Already patched!"
else
    # Insert after the UNPHONE #endif block (line 49)
    # Use awk for precise line insertion
    awk '
    /^#ifdef UNPHONE$/,/^#endif$/ {
        print
        if (/^#endif$/) {
            print "#ifdef SUPERCON_2025"
            print "#include \"graphics/LGFX/LGFX_SUPERCON_2025.h\""
            print "#endif"
        }
        next
    }
    {print}
    ' "$FACTORY" > "$FACTORY.tmp" && mv "$FACTORY.tmp" "$FACTORY"

    echo "✓ Patch applied!"
fi

# Verify
if grep -q "LGFX_SUPERCON_2025" "$FACTORY"; then
    echo "✓ Patch verified!"
else
    echo "✗ ERROR: Patch failed!"
    exit 1
fi

# Copy LGFX header
LGFX_DIR=$(dirname "$FACTORY" | sed 's|source/graphics/driver|include/graphics/LGFX|')
mkdir -p "$LGFX_DIR"
cp meshtastic_variant/supercon_2025/device-ui-patches/graphics/LGFX/LGFX_SUPERCON_2025.h "$LGFX_DIR/"
echo "✓ LGFX header installed!"

echo ""
echo "════════════════════════════════════════════════════"
echo "  ✅ PATCH COMPLETE - Ready to build!"
echo "════════════════════════════════════════════════════"
echo ""
echo "Now run:"
echo "  cd $LINUX_DIR/meshtastic-firmware"
echo "  pio run -e supercon_2025 -j \$(nproc)"
echo ""
