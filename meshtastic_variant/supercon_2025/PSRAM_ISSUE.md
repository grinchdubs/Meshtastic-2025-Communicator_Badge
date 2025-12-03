# Supercon 2025 Badge - PSRAM Issue Documentation

## Current Status: PSRAM INITIALIZATION FAILURE

### Problem Summary
The ESP32-S3-WROOM-1 module on the Hackaday Supercon 2025 Badge contains 8MB of APS6404 Octal PSRAM. This PSRAM **cannot be initialized** by the Arduino ESP32 framework, even though the hardware is fully functional.

### Evidence
- **Hardware Confirmed Working**: MicroPython firmware successfully initializes and uses all 8MB of PSRAM
- **32 Firmware Builds Tested**: Every configuration returns identical error: `PSRAM ID read error: 0x00ffffff`
- **eFuse Analysis**: Confirms 8MB PSRAM present, vendor=AP_3v3, correct configuration
- **Display Hardware Works**: Backlight flashing observed, GPIO functional

### Root Cause
The Arduino ESP32 framework's `esp_spiram_init()` function (from ESP-IDF) cannot communicate with the APS6404 PSRAM chip. The function returns `0x00ffffff` when attempting to read the PSRAM ID via SPI, indicating:
- Wrong SPI timing
- Incompatible initialization sequence  
- ESP-IDF version incompatibility

### Configurations Attempted (All Failed)
1. **Memory types**: `opi_opi`, `qio_qspi`, `dio_qspi`, `qio_opi`, `dio_opi`
2. **sdkconfig approaches**:
   - Basic AUTO mode
   - Advanced with all PSRAM features
   - AP vendor-specific settings
   - MicroPython-minimal config (3 lines only)
3. **Flash modes**: DIO, QIO (only DIO boots, QIO causes bootloop)
4. **Removed Arduino memory_type** completely, used pure sdkconfig

### Why Display Requires PSRAM
- **Available Heap**: 214 KB free (without PSRAM)
- **LVGL UI Requirements**: 426+ KB (images + buffers + widgets)
- **Mathematical Impossibility**: Cannot fit UI in available memory

### Current Workaround: Headless Mode
Firmware **Run #8** operates in headless mode:
- ✅ Boots reliably
- ✅ LoRa radio functional (user confirmed)
- ✅ I2C keyboard detected
- ✅ Filesystem working
- ✅ Meshtastic core operational
- ❌ No display (disabled to prevent crashes)

### Solution Paths (Unimplemented)

#### Option 1: ESP-IDF v5.x Upgrade
MicroPython uses ESP-IDF v5.0.4+ which successfully initializes APS6404. Arduino framework uses ESP-IDF v4.4.x.

**Steps**:
1. Upgrade PlatformIO platform to `espressif32@7.x` (ESP-IDF v5.x)
2. Rebuild Meshtastic firmware
3. Test PSRAM initialization

**Risk**: Breaking changes in ESP-IDF v5.x may require code updates

#### Option 2: Custom PSRAM Initialization
Analyze MicroPython's ESP-IDF v5.x `esp_spiram_init()` implementation and backport to ESP-IDF v4.4.x.

**Steps**:
1. Extract `.a` library from MicroPython build
2. Decompile or analyze PSRAM init sequence
3. Create custom `psramInit()` function
4. Hook before Arduino's initialization

**Risk**: Very complex, requires low-level SPI/PSRAM knowledge

#### Option 3: MicroPython Bootloader Extraction
Use MicroPython's bootloader with Meshtastic application.

**Steps**:
1. Extract bootloader from working MicroPython firmware
2. Flash MicroPython bootloader + Meshtastic app
3. Hope they're compatible

**Risk**: Bootloader/app mismatch may brick device

#### Option 4: Port to ESP-IDF Native
Abandon Arduino framework, port Meshtastic to pure ESP-IDF v5.x.

**Risk**: Massive effort, weeks of work

### Technical Details

#### eFuse Configuration
```
PSRAM_CAP: 8M
PSRAM_VENDOR: AP_3v3
PSRAM_TEMP: 85C
FLASH_TYPE: 4 data lines (Quad DIO)
FLASH_FREQ: 80M
```

#### Error Pattern (All 32 Builds)
```
E (684) psram: PSRAM ID read error: 0x00ffffff, PSRAM chip not found or not supported, or wrong PSRAM line mode
[683][W][esp32-hal-psram.c:71] psramInit(): PSRAM init failed!
DEBUG | Total heap: 251792
DEBUG | Free heap: 214396
DEBUG | Total PSRAM: 0
DEBUG | Free PSRAM: 0
```

#### MicroPython Success
```
Filename: lvgl_micropy_ESP32_GENERIC_S3-SPIRAM_OCT-16.bin
ESP-IDF: 67c1de1e (v5.0.4)
Result: 8MB PSRAM functional, display renders perfectly
```

### Files Modified
- `meshtastic_variant/supercon_heltec/platformio.ini` - PSRAM configs attempted
- `meshtastic_variant/supercon_heltec/sdkconfig.supercon_heltec` - ESP-IDF PSRAM settings
- `meshtastic_variant/supercon_2025/variant.h` - Display enable/disable
- `meshtastic_variant/supercon_2025/psram_fix.cpp` - Diagnostic logging

### Recommendation
**Ship headless firmware** (Run #8) as the functional version. Document PSRAM issue clearly. Display functionality requires ESP-IDF v5.x upgrade or custom PSRAM initialization patch - both beyond scope of current debugging session.

### Contact
For questions about this issue, reference:
- GitHub Actions runs #6-31
- This document: `PSRAM_ISSUE.md`
- Serial logs showing `0x00ffffff` error
