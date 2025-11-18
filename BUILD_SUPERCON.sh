#!/bin/bash
# BUILD_SUPERCON.sh - One-step build for Supercon 2025 firmware
set -e

cd "$(dirname "$0")"

echo "════════════════════════════════════════════════════"
echo "  Supercon 2025 Meshtastic Firmware Builder"
echo "════════════════════════════════════════════════════"
echo ""

# Step 1: Copy variant files
echo "[1/5] Copying variant files..."
mkdir -p meshtastic-firmware/variants/esp32s3/supercon_2025
cp -r meshtastic_variant/supercon_2025/* meshtastic-firmware/variants/esp32s3/supercon_2025/
echo "✓ Variant files copied"

# Step 2: Install dependencies
echo ""
echo "[2/5] Installing PlatformIO dependencies..."
cd meshtastic-firmware
pio pkg install -e supercon_2025
cd ..
echo "✓ Dependencies installed"

# Step 3: Find and patch device-ui
echo ""
echo "[3/5] Patching device-ui library..."
DEVICE_UI_DIR=$(find meshtastic-firmware/.pio -path "*/libdeps/*/meshtastic-device-ui" -type d 2>/dev/null | head -1)

if [ -z "$DEVICE_UI_DIR" ]; then
    echo "ERROR: Could not find device-ui library!"
    exit 1
fi

echo "Found device-ui at: $DEVICE_UI_DIR"

# Copy LGFX header
mkdir -p "$DEVICE_UI_DIR/include/graphics/LGFX"
cp meshtastic_variant/supercon_2025/device-ui-patches/graphics/LGFX/LGFX_SUPERCON_2025.h \
   "$DEVICE_UI_DIR/include/graphics/LGFX/"
echo "✓ LGFX header installed"

# Patch DisplayDriverFactory.cpp
FACTORY_FILE="$DEVICE_UI_DIR/source/graphics/driver/DisplayDriverFactory.cpp"
if ! grep -q "SUPERCON_2025" "$FACTORY_FILE" 2>/dev/null; then
    sed -i '/^#ifdef UNPHONE$/a\
#ifdef SUPERCON_2025\
#include "graphics/LGFX/LGFX_SUPERCON_2025.h"\
#endif' "$FACTORY_FILE"
    echo "✓ DisplayDriverFactory.cpp patched"
else
    echo "✓ Already patched"
fi

# Step 4: Clean build
echo ""
echo "[4/5] Cleaning previous build..."
cd meshtastic-firmware
pio run --target clean -e supercon_2025 > /dev/null 2>&1 || true
echo "✓ Clean complete"

# Step 5: Build firmware
echo ""
echo "[5/5] Building firmware (this will take 5-10 minutes)..."
echo ""
pio run -e supercon_2025 -j $(nproc)

echo ""
echo "════════════════════════════════════════════════════"
echo "  ✅ BUILD SUCCESSFUL!"
echo "════════════════════════════════════════════════════"
echo ""
echo "Firmware location:"
echo "  .pio/build/supercon_2025/firmware.bin"
echo ""
echo "To flash to badge:"
echo "  pio run -e supercon_2025 -t upload"
echo ""
