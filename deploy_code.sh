#!/bin/bash
# Deploy badge application code to Supercon 2025 Badge
# Usage: ./deploy_code.sh [--reset]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

RESET_FLAG=""
if [[ "$1" == "--reset" ]]; then
    RESET_FLAG="--reset"
fi

echo -e "${GREEN}Supercon 2025 Badge Code Deployer${NC}"
echo "===================================="

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo -e "${RED}Error: Virtual environment not found!${NC}"
    echo "Please run: python3 -m venv venv && source venv/bin/activate && pip install -r firmware/requirements.txt"
    exit 1
fi

# Activate virtual environment
echo -e "${YELLOW}Activating virtual environment...${NC}"
source venv/bin/activate

# Check if badge directory exists
if [ ! -d "firmware/badge" ]; then
    echo -e "${RED}Error: Badge code directory not found!${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Method 1: Using mpremote (simpler)${NC}"
echo -e "${YELLOW}Method 2: Using update.py script (more control)${NC}"
echo ""
read -p "$(echo -e ${YELLOW}Choose method [1/2, default=2]:${NC} )" -n 1 -r
echo

if [[ $REPLY =~ ^1$ ]]; then
    echo -e "${YELLOW}Deploying code using mpremote...${NC}"
    cd firmware
    mpremote cp -r badge/* :
    echo -e "${GREEN}✓ Code deployed!${NC}"

    if [[ "$RESET_FLAG" == "--reset" ]]; then
        echo -e "${YELLOW}Resetting badge...${NC}"
        mpremote reset
    fi
else
    echo -e "${YELLOW}Deploying code using update.py script...${NC}"
    cd firmware
    if [[ "$RESET_FLAG" == "--reset" ]]; then
        python scripts/update.py --reset push
    else
        python scripts/update.py push
    fi
    echo -e "${GREEN}✓ Code deployed!${NC}"
fi

echo ""
echo -e "${GREEN}All done!${NC}"
echo ""
echo "Your badge is ready. Press RESET on the badge to start."
echo ""
echo -e "${YELLOW}Tips:${NC}"
echo "- Access REPL: source venv/bin/activate && mpremote repl"
echo "- Update code: ./deploy_code.sh --reset"
echo "- View files: source venv/bin/activate && mpremote ls"
echo ""
