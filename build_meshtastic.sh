#!/bin/bash
# Build and Flash Meshtastic Firmware for Supercon 2025 Badge
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
PORT="${1:-/dev/ttyACM0}"
ACTION="${2:-build}"

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   Meshtastic Firmware Builder - Supercon 2025     ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo

# Check if PlatformIO is installed
if ! command -v pio &> /dev/null; then
    echo -e "${RED}Error: PlatformIO not found!${NC}"
    echo
    echo "Install PlatformIO using one of these methods:"
    echo "  1. pip install platformio"
    echo "  2. curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/scripts/get-platformio.py | python3"
    echo "  3. Install VS Code + PlatformIO IDE extension"
    echo
    exit 1
fi

echo -e "${GREEN}✓ PlatformIO found${NC}"
echo

# Navigate to meshtastic-firmware directory
cd meshtastic-firmware

case "$ACTION" in
    build)
        echo -e "${YELLOW}Building firmware for Supercon 2025 badge...${NC}"
        pio run -e supercon_2025

        echo
        echo -e "${GREEN}✓ Build successful!${NC}"
        echo
        echo "Firmware location: meshtastic-firmware/.pio/build/supercon_2025/firmware.bin"
        echo
        echo "Next steps:"
        echo "  1. Put badge in bootloader mode (hold BOOT, press RESET, release BOOT)"
        echo "  2. Run: ./build_meshtastic.sh $PORT upload"
        ;;

    upload|flash)
        echo -e "${YELLOW}Flashing firmware to badge on $PORT...${NC}"
        echo
        echo "Make sure badge is in bootloader mode:"
        echo "  1. Hold BOOT button (GPIO0)"
        echo "  2. Press RESET button"
        echo "  3. Release BOOT button"
        echo
        read -p "Press Enter when ready to flash..."

        pio run -e supercon_2025 -t upload --upload-port "$PORT"

        echo
        echo -e "${GREEN}✓ Flash successful!${NC}"
        echo
        echo "Press RESET on badge to boot Meshtastic firmware"
        ;;

    monitor)
        echo -e "${YELLOW}Starting serial monitor on $PORT...${NC}"
        echo "Press Ctrl+C to exit"
        echo
        pio device monitor --port "$PORT" --baud 115200
        ;;

    clean)
        echo -e "${YELLOW}Cleaning build files...${NC}"
        pio run -e supercon_2025 -t clean
        echo -e "${GREEN}✓ Clean successful!${NC}"
        ;;

    erase)
        echo -e "${YELLOW}Erasing flash on $PORT...${NC}"
        echo
        read -p "This will erase all data. Continue? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            esptool --port "$PORT" erase_flash
            echo -e "${GREEN}✓ Flash erased!${NC}"
        else
            echo "Cancelled."
        fi
        ;;

    help|*)
        echo "Usage: $0 [PORT] [ACTION]"
        echo
        echo "Arguments:"
        echo "  PORT    Serial port (default: /dev/ttyACM0)"
        echo "  ACTION  What to do (default: build)"
        echo
        echo "Actions:"
        echo "  build     Build firmware (default)"
        echo "  upload    Build and flash to badge"
        echo "  flash     Same as upload"
        echo "  monitor   Open serial monitor"
        echo "  clean     Clean build files"
        echo "  erase     Erase flash completely"
        echo "  help      Show this help"
        echo
        echo "Examples:"
        echo "  $0                          # Build firmware"
        echo "  $0 /dev/ttyACM0 upload      # Build and flash"
        echo "  $0 /dev/ttyACM0 monitor     # Monitor serial output"
        echo "  $0 COM3 upload              # Flash on Windows"
        echo
        exit 0
        ;;
esac
