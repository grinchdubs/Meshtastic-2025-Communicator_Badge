# Meshtastic Firmware Port for Supercon 2025 Badge

## Overview

This guide documents the port of Meshtastic firmware to the Hackaday Supercon 2025 Communicator Badge. The port is being developed in phases to incrementally add hardware support.

## Port Status

### Phase 1: Headless Node ✅ (IN PROGRESS)
- **Status**: Board variant created, ready for testing
- **Features**:
  - SX1262 LoRa radio (915MHz)
  - BLE for configuration
  - WiFi support
  - Basic LED status indicator
  - Battery monitoring (if available)
- **Use Case**: Meshtastic node accessible via smartphone app over BLE

### Phase 2: Display Support (PLANNED)
- **Features**:
  - NV3007 TFT display driver (428×142)
  - Custom UI layout for unusual aspect ratio
  - LVGL integration
- **Challenges**: Custom display controller, non-standard resolution

### Phase 3: Keyboard Support (PLANNED)
- **Features**:
  - TCA8418 I2C keyboard controller
  - Text input for messages
  - Navigation controls
- **Challenges**: Custom keyboard driver needed

### Phase 4: Advanced Features (PLANNED)
- SAO expansion port support
- Power optimization
- Custom badge-specific apps

## Hardware Support Matrix

| Component | Status | Notes |
|-----------|--------|-------|
| ESP32-S3 | ✅ Supported | Native Meshtastic support |
| SX1262 LoRa | ✅ Supported | RadioLib has native support |
| BLE | ✅ Supported | ESP32-S3 built-in |
| WiFi | ✅ Supported | ESP32-S3 built-in |
| Debug LED | ✅ Configured | GPIO1 (active low) |
| Boot Button | ✅ Configured | GPIO0 |
| NV3007 Display | ⏳ Planned | Needs custom driver |
| TCA8418 Keyboard | ⏳ Planned | Needs I2C driver |
| SAO Expansion | ⏳ Planned | I2C ready |
| Battery Charger | ⏳ Needs testing | MCP73831 present |

## Prerequisites

### Software Requirements
- **PlatformIO**: Core 6.0+ or PlatformIO IDE
- **Python**: 3.9 or newer
- **Git**: For cloning repositories

### Installation

#### Option 1: PlatformIO Core (Command Line)
```bash
# Install PlatformIO Core
pip install platformio

# Or via package manager
# Ubuntu/Debian
curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/scripts/get-platformio.py | python3

# macOS
brew install platformio
```

#### Option 2: VS Code + PlatformIO IDE
1. Install Visual Studio Code
2. Install PlatformIO IDE extension
3. Restart VS Code

## Building Meshtastic Firmware

### Step 1: Navigate to Meshtastic Directory
```bash
cd meshtastic-firmware
```

### Step 2: Install Dependencies
```bash
# PlatformIO will automatically download dependencies
# when you first build, but you can pre-install:
pio lib install
```

### Step 3: Build the Firmware
```bash
# Build for Supercon 2025 badge
pio run -e supercon_2025

# The compiled firmware will be in:
# .pio/build/supercon_2025/firmware.bin
```

### Step 4: Flash to Badge

#### Via USB (Bootloader Mode)
```bash
# Put badge in bootloader mode:
# 1. Hold BOOT button (GPIO0)
# 2. Press RESET
# 3. Release BOOT

# Flash using PlatformIO
pio run -e supercon_2025 -t upload

# Or use esptool directly
esptool --port /dev/ttyACM0 --baud 1500000 write_flash 0x0 \
  .pio/build/supercon_2025/firmware.bin
```

#### Find Your Serial Port
```bash
# Linux
ls /dev/tty* | grep -E "ACM|USB"

# macOS
ls /dev/cu.*

# Windows
# Check Device Manager → Ports (COM & LPT)
```

### Step 5: Monitor Serial Output
```bash
# Using PlatformIO
pio device monitor -e supercon_2025

# Or use screen
screen /dev/ttyACM0 115200

# Or minicom
minicom -D /dev/ttyACM0 -b 115200
```

## Configuration

### First Boot
On first boot, the badge will:
1. Generate a node ID
2. Start LoRa radio
3. Enable BLE (name: "Meshtastic_XXXX")
4. Enable WiFi AP mode (SSID: "MeshtasticXXXX")

### Connect via Smartphone
1. Install Meshtastic app (iOS/Android)
2. Enable Bluetooth
3. Open Meshtastic app
4. Tap "+" → "Bluetooth"
5. Select your badge from the list
6. Configure region, LoRa settings, etc.

### LoRa Settings for Supercon Badge
The badge hardware is designed for 915MHz operation:
- **Region**: US (902-928 MHz)
- **Frequency Slot**: Default to 9 (for Supercon 9)
- **Modem Preset**: Long Fast (recommended) or Medium Fast
- **TX Power**: 10-22 dBm (depending on regulations and testing)

### WiFi Configuration
Access via web browser:
1. Connect to WiFi AP: "MeshtasticXXXX"
2. Password: "meshtastic"
3. Browse to: http://172.19.0.1
4. Configure settings via web UI

## Troubleshooting

### Build Errors

**Missing dependencies:**
```bash
pio lib install
pio run -e supercon_2025
```

**PlatformIO not found:**
```bash
export PATH=$PATH:~/.platformio/penv/bin
```

### Flash Errors

**Permission denied (Linux):**
```bash
sudo usermod -a -G dialout $USER
# Log out and back in
```

**Badge not detected:**
- Try different USB cable (must support data)
- Check if device appears: `lsusb` or `dmesg -w`
- Try manual bootloader mode (hold BOOT, press RESET)

**Flash verification failed:**
- Try lower baud rate: `--baud 115200`
- Erase flash first: `esptool --port /dev/ttyACM0 erase_flash`

### Runtime Issues

**LoRa not working:**
- Check SPI pins in variant.h
- Verify SX1262 power and reset
- Check RF_SW pin (GPIO10) state
- Monitor serial output for radio initialization errors

**BLE not visible:**
- Ensure BLE is enabled in build flags
- Check if BLE is disabled in user settings
- Reset device to factory defaults

**High power consumption:**
- Verify power save settings
- Check if RF_SW pin is correctly configured
- Ensure display backlight is off (Phase 1 headless)

## Testing Checklist

### Phase 1 Testing
- [ ] Firmware builds successfully
- [ ] Badge boots and shows LED activity
- [ ] BLE appears in Meshtastic app
- [ ] Can connect via BLE
- [ ] Can send/receive messages
- [ ] WiFi AP starts correctly
- [ ] Web UI accessible
- [ ] LoRa packets transmit successfully
- [ ] LoRa packets received from other nodes
- [ ] Boot button works for reset

## Development

### Directory Structure
```
meshtastic-firmware/
├── variants/
│   └── esp32s3/
│       └── supercon_2025/
│           ├── variant.h          # Pin definitions and features
│           ├── pins_arduino.h      # Arduino pin mappings
│           └── platformio.ini      # Build configuration
├── src/                            # Main Meshtastic source code
└── .pio/                           # Build output (generated)
```

### Modifying Pin Definitions
Edit `variants/esp32s3/supercon_2025/variant.h` to change:
- GPIO pin mappings
- Radio configuration
- Enabled features
- Hardware peripherals

### Adding Display Support (Phase 2)
See commented section in `platformio.ini`:
1. Uncomment display build flags
2. Add LovyanGFX library
3. Create `LGFX_SUPERCON2025.h` display driver
4. Configure 428×142 resolution
5. Adapt UI for landscape format

### Adding Keyboard Support (Phase 3)
1. Implement TCA8418 I2C driver
2. Add input event handling
3. Map keys to Meshtastic functions
4. Enable canned message module

## Pin Reference

### LoRa Radio (SX1262)
```
GPIO 17 - CS
GPIO 18 - RESET
GPIO 3  - MOSI
GPIO 8  - SCK
GPIO 9  - MISO
GPIO 10 - RF_SW (Antenna switch)
GPIO 15 - BUSY
GPIO 16 - DIO1 (IRQ)
```

### I2C Buses
```
I2C0 (Keyboard):
  GPIO 14 - SCL
  GPIO 47 - SDA
  GPIO 13 - Interrupt
  GPIO 48 - Reset

I2C1 (SAO Expansion):
  GPIO 5 - SCL
  GPIO 4 - SDA
  GPIO 7 - SAO_GPIO1
  GPIO 6 - SAO_GPIO2
```

### Display (Future)
```
GPIO 38 - LCD_SCL
GPIO 21 - LCD_SDA
GPIO 40 - LCD_RST
GPIO 41 - LCD_CS
GPIO 42 - LCD_TE
GPIO 2  - LCD_BACKLIGHT (PWM)
GPIO 39 - LCD_DC
```

### Status/Control
```
GPIO 0  - Boot button
GPIO 1  - Debug LED (active low)
```

## Contributing

To contribute improvements to this port:

1. Test thoroughly on hardware
2. Document changes
3. Create pull request to this repository
4. Consider upstreaming to official Meshtastic once stable

## Resources

### Documentation
- [Meshtastic Documentation](https://meshtastic.org/docs/)
- [PlatformIO Documentation](https://docs.platformio.org/)
- [ESP32-S3 Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-s3-wroom-1_wroom-1u_datasheet_en.pdf)
- [SX1262 Datasheet](https://www.semtech.com/products/wireless-rf/lora-core/sx1262)
- [RadioLib Documentation](https://jgromes.github.io/RadioLib/)

### Badge Resources
- Badge Repository: [Meshtastic-2025-Communicator_Badge](.)
- Hardware Specs: `HARDWARE_SPEC.md`
- Original MicroPython Firmware: `firmware/badge/`
- Schematics: `hardware/communicator_pcb/`

### Community
- [Meshtastic Discord](https://discord.gg/meshtastic)
- [Hackaday Supercon](https://hackaday.io/superconference/)

## License

This port follows the Meshtastic firmware license (GPL-3.0).

## Known Issues

1. **Battery monitoring**: Pin/circuit needs verification
2. **RF_SW control**: May need initialization code
3. **Display**: Not yet implemented
4. **Keyboard**: Not yet implemented
5. **Power optimization**: Needs tuning for badge hardware

## Changelog

### 2025-11-14 - Phase 1 Initial Release
- Created board variant for Supercon 2025 badge
- Configured SX1262 LoRa radio
- Enabled BLE and WiFi for headless operation
- Ready for testing on hardware
