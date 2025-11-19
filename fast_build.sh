#!/bin/bash
# fast_build.sh - Build on native Linux filesystem (10-100x faster!)
set -e

WINDOWS_DIR="/mnt/d/Users/PC/Documents/GitHub/Meshtastic-2025-Communicator_Badge"
LINUX_DIR="$HOME/meshtastic-supercon-build"

echo "════════════════════════════════════════════════════"
echo "  FAST BUILD - Using Native Linux Filesystem"
echo "════════════════════════════════════════════════════"
echo ""
echo "⚡ This builds on native Linux FS (5-10 min vs 1+ hour)"
echo ""

# Step 1: Sync to Linux filesystem
echo "[1/5] Syncing project to Linux filesystem..."
if [ -d "$LINUX_DIR" ]; then
    echo "Updating existing build directory..."
    rsync -a --delete --exclude '.pio' --exclude '.git' "$WINDOWS_DIR/" "$LINUX_DIR/"
else
    echo "Creating new build directory..."
    cp -r "$WINDOWS_DIR" "$LINUX_DIR"
fi
echo "✓ Synced to: $LINUX_DIR"

# Step 2: Copy variant files
echo ""
echo "[2/5] Copying variant files..."
cd "$LINUX_DIR"
mkdir -p meshtastic-firmware/variants/esp32s3/supercon_2025
cp -r meshtastic_variant/supercon_2025/* meshtastic-firmware/variants/esp32s3/supercon_2025/
echo "✓ Variant files copied"

# Step 3: Install dependencies
echo ""
echo "[3/5] Installing dependencies..."
cd meshtastic-firmware
pio pkg install -e supercon_2025 > /dev/null 2>&1
cd ..
echo "✓ Dependencies installed"

# Step 4: Patch device-ui
echo ""
echo "[4/5] Patching device-ui library..."
FACTORY=$(find meshtastic-firmware/.pio -name "DisplayDriverFactory.cpp" -path "*/meshtastic-device-ui/*" 2>/dev/null | head -1)

if [ -z "$FACTORY" ]; then
    echo "ERROR: DisplayDriverFactory.cpp not found!"
    exit 1
fi

# Patch if needed
if ! grep -q "LGFX_SUPERCON_2025" "$FACTORY" 2>/dev/null; then
    echo "Applying patch..."
    # Use awk for reliable patching - insert after UNPHONE block
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

    # Verify patch
    if grep -q "LGFX_SUPERCON_2025" "$FACTORY"; then
        echo "✓ Patch applied successfully"
    else
        echo "ERROR: Patch failed!"
        exit 1
    fi
else
    echo "✓ Already patched"
fi

# Copy LGFX header
LGFX_DIR=$(dirname "$FACTORY" | sed 's|source/graphics/driver|include/graphics/LGFX|')
mkdir -p "$LGFX_DIR"
cp meshtastic_variant/supercon_2025/device-ui-patches/graphics/LGFX/LGFX_SUPERCON_2025.h "$LGFX_DIR/"
echo "✓ Patches applied"

# Step 5: Build firmware
echo ""
echo "[5/5] Building firmware (5-10 minutes)..."
echo ""
cd meshtastic-firmware

# Use all CPU cores for maximum speed
pio run -e supercon_2025 -j $(nproc)

echo ""
echo "════════════════════════════════════════════════════"
echo "  ✅ BUILD SUCCESSFUL!"
echo "════════════════════════════════════════════════════"
echo ""
echo "Linux build: $LINUX_DIR/meshtastic-firmware/.pio/build/supercon_2025/firmware.bin"
echo ""

# Copy firmware back to Windows drive
echo "Copying firmware to Windows drive..."
cp .pio/build/supercon_2025/firmware.bin "$WINDOWS_DIR/firmware.bin"
echo "✓ Firmware copied to: $WINDOWS_DIR/firmware.bin"
echo ""

# Show file size
SIZE=$(ls -lh "$WINDOWS_DIR/firmware.bin" | awk '{print $5}')
echo "Firmware size: $SIZE"
echo ""
echo "To flash:"
echo "  cd meshtastic-firmware"
echo "  pio run -e supercon_2025 -t upload"
echo ""
echo "💡 Tip: Keep building from $LINUX_DIR for speed!"
echo ""
