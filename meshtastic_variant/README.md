# Meshtastic Variant for Supercon 2025 Badge

This directory contains the board variant files for porting Meshtastic firmware to the Hackaday Supercon 2025 Communicator Badge.

## Quick Setup

### 1. Clone Meshtastic Firmware
```bash
git clone --depth 1 https://github.com/meshtastic/firmware.git meshtastic-firmware
cd meshtastic-firmware
```

### 2. Copy Variant Files
```bash
# From the root of this repository
cp -r meshtastic_variant/supercon_2025 meshtastic-firmware/variants/esp32s3/
```

### 3. Build Firmware
```bash
# Use the helper script
../build_meshtastic.sh
```

## Files

- `variant.h` - Pin definitions and hardware configuration
- `pins_arduino.h` - Arduino framework pin mappings
- `platformio.ini` - PlatformIO build configuration

## Documentation

See `../MESHTASTIC_PORT_GUIDE.md` for complete build, flash, and usage instructions.

## Hardware Specs

See `../HARDWARE_SPEC.md` for detailed hardware information.
