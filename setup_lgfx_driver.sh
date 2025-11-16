#!/bin/bash
# Setup script to copy LGFX_SUPERCON_2025.h to device-ui library
# This must be run after PlatformIO downloads the device-ui library

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VARIANT_DIR="$SCRIPT_DIR/meshtastic_variant/supercon_2025"
LGFX_SOURCE="$VARIANT_DIR/device-ui-patches/graphics/LGFX/LGFX_SUPERCON_2025.h"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Setting up LGFX driver for Supercon 2025...${NC}"

# Check if source file exists
if [ ! -f "$LGFX_SOURCE" ]; then
    echo -e "${RED}✗ Error: LGFX_SUPERCON_2025.h not found at: $LGFX_SOURCE${NC}"
    exit 1
fi

# Find device-ui library in .pio directory
DEVICE_UI_DIR=$(find "$SCRIPT_DIR/meshtastic-firmware/.pio" -path "*/libdeps/*/meshtastic-device-ui" -type d 2>/dev/null | head -1)

if [ -z "$DEVICE_UI_DIR" ]; then
    echo -e "${RED}✗ Error: meshtastic-device-ui library not found!${NC}"
    echo -e "${YELLOW}  Please run PlatformIO build first to download dependencies:${NC}"
    echo -e "  cd $SCRIPT_DIR/meshtastic-firmware"
    echo -e "  pio pkg install -e supercon_2025"
    exit 1
fi

# Create LGFX directory if it doesn't exist
LGFX_TARGET_DIR="$DEVICE_UI_DIR/include/graphics/LGFX"
mkdir -p "$LGFX_TARGET_DIR"

# Copy the LGFX header
cp "$LGFX_SOURCE" "$LGFX_TARGET_DIR/"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ LGFX_SUPERCON_2025.h copied successfully!${NC}"
    echo -e "  From: $LGFX_SOURCE"
    echo -e "  To:   $LGFX_TARGET_DIR/"
    echo -e ""
    echo -e "${GREEN}You can now build the firmware:${NC}"
    echo -e "  ./build_meshtastic.sh"
else
    echo -e "${RED}✗ Error: Failed to copy LGFX header${NC}"
    exit 1
fi
