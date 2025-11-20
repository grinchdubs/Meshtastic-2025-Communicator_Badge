#!/bin/bash
# check_board.sh - Verify board definition is installed locally

BUILD_DIR="$HOME/meshtastic-supercon-build/meshtastic-firmware"

echo "Checking board definition installation..."
echo ""

if [ -f "$BUILD_DIR/boards/supercon_2025.json" ]; then
    echo "✅ Board JSON found at: $BUILD_DIR/boards/supercon_2025.json"
    echo ""
    echo "Flash size configured:"
    grep "flash_size" "$BUILD_DIR/boards/supercon_2025.json"
    echo ""
    echo "PSRAM config:"
    grep -E "memory_type|psram_type|PSRAM" "$BUILD_DIR/boards/supercon_2025.json"
else
    echo "❌ Board JSON NOT found!"
    echo ""
    echo "Installing from repo..."
    mkdir -p "$BUILD_DIR/boards"
    cp /mnt/d/Users/PC/Documents/GitHub/Meshtastic-2025-Communicator_Badge/meshtastic_variant/supercon_2025/supercon_2025.json \
       "$BUILD_DIR/boards/"

    if [ -f "$BUILD_DIR/boards/supercon_2025.json" ]; then
        echo "✅ Board JSON installed successfully"
    else
        echo "❌ Failed to install board JSON"
        exit 1
    fi
fi

echo ""
echo "PlatformIO board cache:"
ls -lh ~/.platformio/platforms/espressif32/boards/ 2>/dev/null | grep supercon || echo "Not in cache yet (will be added on first build)"
