# Supercon 2025 Badge Hardware Specifications

## Overview
This document details the hardware specifications for porting Meshtastic firmware to the Hackaday Supercon 2025 Communicator Badge.

## Main Components

### MCU
- **Model**: ESP32-S3-WROOM-1
- **Flash**: 16MB Quad SPI
- **PSRAM**: 8MB Octal SPI (SPIRAM_OCT)
- **WiFi**: 2.4 GHz 802.11b/g/n
- **Bluetooth**: BLE 5.0
- **Voltage**: 3.3V
- **Datasheet**: https://www.espressif.com/sites/default/files/documentation/esp32-s3-wroom-1_wroom-1u_datasheet_en.pdf

### LoRa Radio
- **Model**: Wio-SX1262-N (Seeed)
- **Chipset**: Semtech SX1262
- **Frequency**: 902-928 MHz (US ISM band)
- **Interface**: SPI
- **Datasheet**: https://files.seeedstudio.com/products/SenseCAP/Wio_SX1262/Wio-SX1262-N_Module_Datasheet.pdf

### Display
- **Controller**: NV3007
- **Resolution**: 428×142 pixels
- **Interface**: I2C/SPI
- **Type**: TFT LCD
- **Backlight**: PWM controlled

### Keyboard
- **Controller**: TCA8418 (Texas Instruments)
- **Interface**: I2C
- **Features**: 18-key matrix scanner with interrupt
- **Keys**:
  - QWERTY keyboard matrix
  - 5 function keys (F1-F5)
  - Direction keys
- **Datasheet**: https://www.ti.com/lit/ds/symlink/tca8418.pdf

### Power Management
- **Battery Charger**: MCP73831-2-OT (Microchip)
- **LDO Regulator**: AP2112K-3.3 (Diodes Inc)
- **Battery**: JST PH2.0 connector
- **USB**: USB-C connector (Amphenol 12402012E212A)

### Expansion
- **SAO**: Simple Add-On v2 connector (2x3, I2C)
- **Antenna**: SMA edge connector

## Pin Mappings

### Debug/Status
```
GPIO 0  - Boot button
GPIO 1  - Debug LED (active low)
```

### Keyboard (I2C)
```
GPIO 14 - KBD_SCL
GPIO 47 - KBD_SDA
GPIO 13 - KBD_INT (interrupt)
GPIO 48 - KBD_RST (reset)
```

### Display (I2C/SPI)
```
GPIO 38 - LCD_SCL
GPIO 21 - LCD_SDA
GPIO 40 - LCD_RST
GPIO 41 - LCD_CS
GPIO 42 - LCD_TE
GPIO 2  - LCD_BACKLIGHT (PWM)
GPIO 39 - LCD_DATA_CMD
```

### LoRa Radio (SPI)
```
GPIO 17 - RF_NSS (CS)
GPIO 18 - RF_RST
GPIO 3  - RF_MOSI
GPIO 8  - RF_SCK
GPIO 9  - RF_MISO
GPIO 10 - RF_SW (antenna switch, default high)
GPIO 15 - RF_BUSY
GPIO 16 - RF_DIO1
```

### SAO Expansion (I2C)
```
GPIO 5 - SAO_SCL
GPIO 4 - SAO_SDA
GPIO 7 - SAO_GPIO1
GPIO 6 - SAO_GPIO2
```

## Meshtastic Port Considerations

### Supported Features
- ✅ ESP32-S3 platform (well supported by Meshtastic)
- ✅ SX1262 LoRa radio (native support)
- ✅ Battery monitoring
- ✅ BLE support
- ✅ WiFi support

### Challenges
- ⚠️ **Display**: NV3007 controller - may need custom driver
  - Alternative: Use as headless node with BLE/WiFi UI
  - Or: Port LVGL driver from MicroPython firmware
- ⚠️ **Keyboard**: TCA8418 I2C controller
  - Custom input driver needed
  - Alternative: Use rotary encoder or simple buttons initially
- ⚠️ **Form Factor**: Unique 428×142 display requires UI adaptation

### Initial Port Strategy

**Phase 1: Headless Node** (Simplest)
- Get basic Meshtastic running without display
- Configure SX1262 radio
- Use BLE/WiFi for configuration and messaging
- Add simple status LED support

**Phase 2: Display Support**
- Port NV3007 driver from MicroPython
- Adapt Meshtastic UI for 428×142 resolution
- Implement custom screen layouts

**Phase 3: Keyboard Support**
- Add TCA8418 driver
- Map keys to Meshtastic functions
- Implement text input for messaging

**Phase 4: Advanced Features**
- SAO expansion support
- Power optimization
- Custom apps/plugins

## Reference Meshtastic Boards

Similar ESP32-S3 boards in Meshtastic:
- **TLORA_T3_S3**: T-Beam S3 with SX1262
- **TECHO**: T-Echo with similar form factor
- **HELTEC_V3**: Heltec V3 with SX1262

## Build Configuration

### PlatformIO Environment
```ini
[env:supercon_2025]
extends = esp32s3_base
board = esp32-s3-devkitc-1
board_build.partitions = default_16MB.csv

build_flags =
  ${esp32s3_base.build_flags}
  -D SUPERCON_2025
  -I variants/supercon_2025
```

### Required Libraries
- RadioLib (for SX1262)
- TFT_eSPI or LVGL (for display)
- Wire (for I2C)

## Resources

### Datasheets
- [ESP32-S3-WROOM-1](https://www.espressif.com/sites/default/files/documentation/esp32-s3-wroom-1_wroom-1u_datasheet_en.pdf)
- [SX1262](https://www.semtech.com/products/wireless-rf/lora-core/sx1262)
- [TCA8418](https://www.ti.com/lit/ds/symlink/tca8418.pdf)
- [MCP73831](http://ww1.microchip.com/downloads/en/DeviceDoc/20001984g.pdf)

### Existing Firmware
- MicroPython implementation: `firmware/badge/`
- Pin definitions: `firmware/badge/hardware/board.py`
- LoRa driver: `firmware/badge/net/lora.py`
- Display driver: `firmware/badge/hardware/display.py`

### Meshtastic Resources
- [Meshtastic GitHub](https://github.com/meshtastic/firmware)
- [Hardware Documentation](https://meshtastic.org/docs/hardware/)
- [Development Guide](https://meshtastic.org/docs/development/)
