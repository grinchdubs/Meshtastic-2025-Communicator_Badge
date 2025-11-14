#!/bin/bash
# Flash MicroPython firmware to Supercon 2025 Badge
# Usage: ./flash_badge.sh [port]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default port
PORT="${1:-/dev/ttyACM0}"

echo -e "${GREEN}Supercon 2025 Badge Firmware Flasher${NC}"
echo "======================================="

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo -e "${RED}Error: Virtual environment not found!${NC}"
    echo "Please run: python3 -m venv venv && source venv/bin/activate && pip install -r firmware/requirements.txt"
    exit 1
fi

# Activate virtual environment
echo -e "${YELLOW}Activating virtual environment...${NC}"
source venv/bin/activate

# Check if firmware file exists
FIRMWARE="firmware/micropython/lvgl_micropy_ESP32_GENERIC_S3-SPIRAM_OCT-16.bin"
if [ ! -f "$FIRMWARE" ]; then
    echo -e "${RED}Error: Firmware file not found at $FIRMWARE${NC}"
    exit 1
fi

echo -e "${YELLOW}Using port: $PORT${NC}"
echo -e "${YELLOW}Firmware: $FIRMWARE${NC}"
echo ""

# Prompt user
read -p "$(echo -e ${YELLOW}Do you want to erase flash first? [y/N]:${NC} )" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Erasing flash...${NC}"
    esptool --port "$PORT" erase_flash
    echo -e "${GREEN}Flash erased!${NC}"
    echo ""
fi

echo -e "${YELLOW}Flashing MicroPython firmware...${NC}"
echo "This may take a minute..."
esptool --port "$PORT" --baud 1500000 write_flash 0 "$FIRMWARE"

echo ""
echo -e "${GREEN}✓ Firmware flashed successfully!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Reset your badge"
echo "2. Run: ./deploy_code.sh to copy the badge application code"
echo ""
