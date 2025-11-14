# Meshtastic Variant for Supercon 2025 Badge

This directory contains the board variant files for porting Meshtastic firmware to the Hackaday Supercon 2025 Communicator Badge with **full NV3007 TFT display support** (428×142).

## Features

✅ ESP32-S3 (16MB Flash, 8MB PSRAM)
✅ SX1262 LoRa Radio (915MHz)
✅ **NV3007 TFT Display (428×142)** - NEW!
✅ BLE & WiFi
✅ LED Status Indicator
⏳ TCA8418 Keyboard (Phase 3 - planned)
⏳ SAO Expansion (Phase 4 - planned)

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

**With Display (default):**
```bash
../build_meshtastic.sh
# Or: pio run -e supercon_2025
```

**Headless (no display):**
```bash
cd meshtastic-firmware
pio run -e supercon_2025_headless
```

### 4. Flash to Badge
```bash
# Put badge in bootloader mode (hold BOOT, press RESET, release BOOT)
../build_meshtastic.sh /dev/ttyACM0 upload
```

## Files

- `variant.h` - Pin definitions and hardware configuration
- `pins_arduino.h` - Arduino framework pin mappings
- `platformio.ini` - PlatformIO build configurations
- `DISPLAY.md` - Display-specific documentation

## Display Support

The **NV3007 TFT display** (428×142) is now fully supported:
- LovyanGFX with ST7789S driver base
- Landscape orientation (270° rotation)
- Full Meshtastic UI
- PWM backlight control
- RGB565 color (65K colors)

See `DISPLAY.md` for detailed display documentation.

## Build Variants

### supercon_2025 (default)
Full-featured build with display, LoRa, BLE, WiFi

### supercon_2025_headless
Minimal build without display (BLE/WiFi control only)

## Documentation

- `DISPLAY.md` - Display support and troubleshooting
- `../MESHTASTIC_PORT_GUIDE.md` - Complete porting guide
- `../HARDWARE_SPEC.md` - Hardware specifications

## Compatibility Note

If you're using a Heltec firmware build that works on the badge, this variant provides:
- Proper pin mappings for Supercon badge hardware
- Optimized display configuration for 428×142
- Native support for badge peripherals
- Better power management

## Testing Checklist

- [ ] Firmware builds successfully
- [ ] Badge boots and shows Meshtastic logo
- [ ] Display shows UI correctly (428×142)
- [ ] LoRa transmit/receive works
- [ ] BLE connects to phone app
- [ ] WiFi AP mode works
- [ ] Messages display on screen
- [ ] Node list populates
- [ ] Settings menu accessible

## Known Issues

1. Keyboard not yet supported (use BLE/WiFi for input)
2. Battery monitoring needs testing
3. SAO expansion not configured
4. Touch screen not available (hardware limitation)

## Next Steps

See `../MESHTASTIC_PORT_GUIDE.md` for:
- Flashing instructions
- Configuration guide
- Troubleshooting
- Development tips
