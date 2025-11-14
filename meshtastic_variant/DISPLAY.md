# Supercon 2025 Badge - Display Support

## Overview

The Supercon 2025 badge features a **NV3007 TFT display** with an unusual but awesome **428×142 pixel** resolution in landscape mode. This gives you a wide, cinematic aspect ratio perfect for messaging and status displays.

## Display Specifications

- **Controller**: NV3007 (ST7789-compatible)
- **Resolution**: 428×142 pixels (landscape)
- **Interface**: SPI
- **Colors**: RGB565 (65K colors)
- **Backlight**: PWM controlled (GPIO2)
- **Rotation**: 270° (landscape)

## Pin Configuration

```
GPIO 38 - SCK (SPI Clock)
GPIO 21 - SDA (MOSI)
GPIO 41 - CS (Chip Select)
GPIO 39 - DC (Data/Command)
GPIO 40 - RST (Reset)
GPIO 2  - BL (Backlight PWM)
GPIO 42 - TE (Tearing Effect - optional)
```

## Building with Display Support

The default `supercon_2025` environment now includes display support:

```bash
# Build with display enabled (default)
./build_meshtastic.sh

# Or explicitly:
cd meshtastic-firmware
pio run -e supercon_2025
```

For a headless build (no display):

```bash
cd meshtastic-firmware
pio run -e supercon_2025_headless
```

## Display Features

### What Works

✅ **Full Meshtastic UI** - All standard Meshtastic screens
✅ **Message Display** - View incoming/outgoing messages
✅ **Node List** - See nearby mesh nodes
✅ **Signal Strength** - RSSI, SNR indicators
✅ **Battery Status** - Power level display
✅ **Settings** - Configure via on-screen menus

### Display Characteristics

The 428×142 resolution provides:
- **Wide format** - Perfect for message lists and node info
- **High DPI** - Sharp text and icons
- **Landscape orientation** - Natural reading experience
- **Custom layouts** - Meshtastic UI adapted for this aspect ratio

## Technical Details

### Driver Implementation

The NV3007 display is driven using LovyanGFX with the ST7789S base driver:

- **Driver**: LovyanGFX Panel_ST7789S
- **Color Mode**: RGB565 with byte swap
- **SPI Speed**: 80 MHz (write), 16 MHz (read)
- **Buffering**: Single buffer
- **Offset**: X=0, Y=12 (from hardware testing)

### Display Initialization

The display initializes in the following sequence:
1. SPI bus configuration (SPI2_HOST)
2. Panel reset via GPIO40
3. ST7789S initialization commands
4. Rotation to 270° (landscape)
5. Backlight PWM activation

### Memory Usage

- **Frame Buffer**: ~122KB (428×142×2 bytes)
- **LVGL Graphics**: ~200-300KB
- **Total RAM**: ~400-500KB for display subsystem
- **PSRAM**: Utilized for frame buffering

## Troubleshooting

### Display Not Working

**Blank Screen:**
- Check backlight PWM (GPIO2)
- Verify SPI connections
- Confirm power supply to display

**Garbled Output:**
- Check rotation setting (should be 270°)
- Verify RGB565 byte swap enabled
- Check Y offset (should be 12)

**Colors Wrong:**
- Verify RGB565 format
- Check inversion setting (should be false)
- Confirm byte swap is enabled

### Performance Issues

**Slow Refresh:**
- Reduce SPI frequency from 80MHz to 40MHz
- Check CPU load
- Disable debug logging

**Flickering:**
- Enable tearing effect (TE pin on GPIO42)
- Adjust frame rate (currently 5 FPS for transitions)
- Check power supply stability

## Comparison to MicroPython Firmware

| Feature | MicroPython | Meshtastic |
|---------|-------------|------------|
| Graphics Library | LVGL | LovyanGFX + LVGL |
| Resolution | 428×142 | 428×142 |
| Color Depth | RGB565 | RGB565 |
| Rotation | 270° | 270° |
| Backlight Control | PWM (0-1023) | PWM (0-255) |
| Refresh Rate | ~30 FPS | ~5-15 FPS |
| Custom Apps | Python | C++ |

## Future Enhancements

### Planned Features
- [ ] Touch screen support (if hardware added)
- [ ] Screen rotation options
- [ ] Custom splash screen
- [ ] Screen timeout/power saving
- [ ] Brightness auto-adjustment
- [ ] Screenshot feature via BLE

### Keyboard Integration (Phase 3)
Once keyboard support is added:
- Text input for messages
- Menu navigation
- Settings adjustment
- Quick replies

## Example Screens

The Meshtastic UI on 428×142:

```
┌────────────────────────────────────────────┐
│ Meshtastic  ║  12:34 PM  ║  ■■■■■□ 80%   │
├────────────────────────────────────────────┤
│                                            │
│  📡 5 Nodes    🔋 80%    📶 -85dBm        │
│                                            │
│  ┌────────────────────────────────────┐   │
│  │ Alice: Hey, great talk!           │   │
│  │ 12:30 PM                ✓✓        │   │
│  └────────────────────────────────────┘   │
│                                            │
│  ┌────────────────────────────────────┐   │
│  │ You: Thanks! Loving these badges  │   │
│  │ 12:32 PM                          │   │
│  └────────────────────────────────────┘   │
│                                            │
├────────────────────────────────────────────┤
│  MSG  │  NODES  │  MAP  │  STATS  │  SET │
└────────────────────────────────────────────┘
```

## Resources

- [LovyanGFX Documentation](https://github.com/lovyan03/LovyanGFX)
- [NV3007 Controller Info](https://github.com/lvgl/lv_port_esp32/issues/158)
- [Meshtastic Display Guide](https://meshtastic.org/docs/hardware/devices/display/)
- [Original MicroPython Display Code](../firmware/badge/hardware/lvgl_setup.py)

## Display Configuration Reference

From `variant.h`:
```cpp
#define HAS_SCREEN 1
#define HAS_TFT 1
#define ST7789S              // Use ST7789 driver
#define TFT_WIDTH 142
#define TFT_HEIGHT 428
#define TFT_OFFSET_X 0
#define TFT_OFFSET_Y 12
#define TFT_OFFSET_ROTATION 3  // 270 degrees
#define SPI_FREQUENCY 80000000
```

From `platformio.ini`:
```ini
-D HAS_SCREEN=1
-D HAS_TFT=1
-D ST7789S
-D TFT_HEIGHT=428
-D TFT_WIDTH=142
-D SCREEN_ROTATE
-D BRIGHTNESS_DEFAULT=130
```

## Tips for Display Development

1. **Test rotation settings** - The 270° rotation is critical
2. **Adjust Y offset** - May need tuning (currently 12)
3. **Monitor SPI bus** - Check for conflicts with LoRa radio
4. **Power budget** - Display adds ~50-100mA current draw
5. **Backlight control** - Start at medium brightness (130/255)

Enjoy your wide-screen Meshtastic experience! 📟✨
