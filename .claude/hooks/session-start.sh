#!/bin/bash
# SessionStart hook for Supercon 2025 Badge - Meshtastic Port
# This hook sets up the development environment for building Meshtastic firmware

set -euo pipefail

# Only run in remote (Claude Code on the web) environment
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

echo "🚀 Setting up Supercon 2025 Badge development environment..."

# Install Python dependencies for MicroPython firmware tools
echo "📦 Installing Python dependencies (esptool, mpremote)..."
pip install -q --ignore-installed esptool mpremote || pip install -q esptool mpremote || true

# Install PlatformIO for Meshtastic firmware builds
echo "🔧 Installing PlatformIO..."
if ! command -v pio &> /dev/null; then
    pip install -q platformio || true
fi

# Copy Meshtastic variant files if not already present
if [ -d "meshtastic_variant/supercon_2025" ] && [ -d "meshtastic-firmware" ]; then
    echo "📋 Installing Supercon 2025 board variant..."
    mkdir -p meshtastic-firmware/variants/esp32s3/supercon_2025
    cp -r meshtastic_variant/supercon_2025/* meshtastic-firmware/variants/esp32s3/supercon_2025/ 2>/dev/null || true
fi

# Pre-install PlatformIO libraries for faster first build
if [ -d "meshtastic-firmware" ]; then
    echo "📚 Pre-installing PlatformIO libraries..."
    cd meshtastic-firmware
    # Run a quick library install without building
    pio pkg install -e supercon_2025 2>/dev/null || true
    cd ..
fi

echo "✅ Development environment ready!"
echo "   - Python tools: esptool, mpremote"
echo "   - PlatformIO installed"
echo "   - Supercon 2025 variant configured"
echo ""
echo "Quick start:"
echo "  Build: ./build_meshtastic.sh"
echo "  Flash: ./build_meshtastic.sh /dev/ttyACM0 upload"
