#!/bin/bash
# verify_and_fix.sh - Diagnose and fix the LGFX patch once and for all
set -e

LINUX_DIR="$HOME/meshtastic-supercon-build"

echo "════════════════════════════════════════════════════"
echo "  DIAGNOSTIC & FIX - LGFX Driver Setup"
echo "════════════════════════════════════════════════════"
echo ""

cd "$LINUX_DIR/meshtastic-firmware"

# Find the actual file
echo "[1] Locating DisplayDriverFactory.cpp..."
FACTORY=$(find .pio/libdeps/supercon_2025 -name "DisplayDriverFactory.cpp" -path "*/meshtastic-device-ui/*" 2>/dev/null | head -1)

if [ -z "$FACTORY" ]; then
    echo "ERROR: DisplayDriverFactory.cpp not found!"
    exit 1
fi

echo "Found: $FACTORY"
echo ""

# Show current state
echo "[2] Current state of the file (lines 45-55):"
echo "─────────────────────────────────────────────────────"
sed -n '45,55p' "$FACTORY" | cat -A
echo "─────────────────────────────────────────────────────"
echo ""

# Check if already patched
if grep -q "LGFX_SUPERCON_2025" "$FACTORY"; then
    echo "✓ File already contains LGFX_SUPERCON_2025"
    echo ""
    echo "Showing all SUPERCON_2025 references:"
    grep -n "SUPERCON_2025" "$FACTORY"
else
    echo "✗ File does NOT contain LGFX_SUPERCON_2025 - applying patch..."
    echo ""

    # Create backup
    cp "$FACTORY" "$FACTORY.backup"

    # Apply patch with awk
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
    ' "$FACTORY.backup" > "$FACTORY"

    echo "Patch applied. New state (lines 45-58):"
    echo "─────────────────────────────────────────────────────"
    sed -n '45,58p' "$FACTORY" | cat -A
    echo "─────────────────────────────────────────────────────"
fi

echo ""

# Verify LGFX header location
echo "[3] Checking LGFX header file..."
LGFX_DIR=$(dirname "$FACTORY" | sed 's|source/graphics/driver|include/graphics/LGFX|')
LGFX_HEADER="$LGFX_DIR/LGFX_SUPERCON_2025.h"

if [ -f "$LGFX_HEADER" ]; then
    echo "✓ Found: $LGFX_HEADER"
    ls -lh "$LGFX_HEADER"
else
    echo "✗ LGFX header missing - copying..."
    mkdir -p "$LGFX_DIR"
    cp "$LINUX_DIR/meshtastic_variant/supercon_2025/device-ui-patches/graphics/LGFX/LGFX_SUPERCON_2025.h" "$LGFX_DIR/"
    echo "✓ Copied to: $LGFX_HEADER"
fi

echo ""

# Clean build cache
echo "[4] Cleaning build cache..."
rm -rf .pio/build/supercon_2025
echo "✓ Build cache cleared"

echo ""
echo "════════════════════════════════════════════════════"
echo "  ✅ SETUP COMPLETE"
echo "════════════════════════════════════════════════════"
echo ""
echo "Files verified:"
echo "  1. $FACTORY (patched)"
echo "  2. $LGFX_HEADER (header file)"
echo ""
echo "Build cache cleared. Ready to build!"
echo ""
echo "Run:"
echo "  pio run -e supercon_2025 -j \$(nproc)"
echo ""
