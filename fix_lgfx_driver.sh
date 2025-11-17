#!/bin/bash
# fix_lgfx_driver.sh - Install LGFX_SUPERCON_2025.h to device-ui library
# Run this script on your local WSL machine after PlatformIO has downloaded dependencies

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== LGFX Driver Installation Fix ===${NC}"
echo ""

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Source LGFX header
LGFX_SOURCE="meshtastic_variant/supercon_2025/device-ui-patches/graphics/LGFX/LGFX_SUPERCON_2025.h"

if [ ! -f "$LGFX_SOURCE" ]; then
    echo -e "${RED}✗ Error: LGFX_SUPERCON_2025.h not found!${NC}"
    echo "  Expected at: $LGFX_SOURCE"
    exit 1
fi

echo -e "${GREEN}✓ Found LGFX source file${NC}"

# Find ALL device-ui library locations (there might be multiple)
echo ""
echo -e "${YELLOW}Searching for device-ui library installations...${NC}"

DEVICE_UI_DIRS=()

# Search in project .pio directory
while IFS= read -r dir; do
    DEVICE_UI_DIRS+=("$dir")
done < <(find meshtastic-firmware/.pio -path "*/libdeps/*/meshtastic-device-ui" -type d 2>/dev/null)

# Search in global platformio cache
while IFS= read -r dir; do
    DEVICE_UI_DIRS+=("$dir")
done < <(find ~/.platformio -path "*/libdeps/*/meshtastic-device-ui" -type d 2>/dev/null)

# Check /tmp/device-ui (used in remote sessions)
if [ -d "/tmp/device-ui/include/graphics/LGFX" ]; then
    DEVICE_UI_DIRS+=("/tmp/device-ui")
fi

if [ ${#DEVICE_UI_DIRS[@]} -eq 0 ]; then
    echo -e "${RED}✗ No device-ui library installations found!${NC}"
    echo ""
    echo -e "${YELLOW}The device-ui library needs to be installed first.${NC}"
    echo "Run this command to install dependencies:"
    echo ""
    echo "  cd meshtastic-firmware"
    echo "  pio pkg install -e supercon_2025"
    echo ""
    echo "Then run this script again."
    exit 1
fi

echo -e "${GREEN}✓ Found ${#DEVICE_UI_DIRS[@]} device-ui installation(s)${NC}"
echo ""

# Copy LGFX header to all found locations
SUCCESS_COUNT=0
for DEVICE_UI_DIR in "${DEVICE_UI_DIRS[@]}"; do
    LGFX_TARGET_DIR="$DEVICE_UI_DIR/include/graphics/LGFX"

    echo "Installing to: $LGFX_TARGET_DIR"

    if mkdir -p "$LGFX_TARGET_DIR" 2>/dev/null; then
        if cp "$LGFX_SOURCE" "$LGFX_TARGET_DIR/" 2>/dev/null; then
            echo -e "  ${GREEN}✓ Installed successfully${NC}"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            echo -e "  ${RED}✗ Copy failed (permission denied?)${NC}"
        fi
    else
        echo -e "  ${RED}✗ Failed to create directory${NC}"
    fi
    echo ""
done

if [ $SUCCESS_COUNT -eq 0 ]; then
    echo -e "${RED}✗ Failed to install LGFX driver to any location${NC}"
    exit 1
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ LGFX driver installed to $SUCCESS_COUNT location(s)!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "You can now build the firmware:"
echo "  cd meshtastic-firmware"
echo "  pio run -e supercon_2025 -j \$(nproc)"
echo ""
echo "Or use the build script:"
echo "  ./build_meshtastic.sh"
