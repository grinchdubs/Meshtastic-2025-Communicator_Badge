# Supercon 2025 Badge Firmware Setup Guide

This guide will help you flash and run the custom MicroPython firmware on your Hackaday Supercon 2025 Communicator Badge.

## Important Note

This badge runs **custom MicroPython firmware**, not native Meshtastic. However, it uses LoRa radio and is compatible with Meshtastic frequency slots for good neighbor operation.

## Hardware Specs

- **MCU**: ESP32-S3
- **Flash**: 16MB Quad SPI
- **PSRAM**: 8MB Octal SPI
- **Radio**: LoRa (915MHz ISM band in US)
- **Display**: NV3007 controller
- **Firmware**: MicroPython with LVGL and ucryptography

## Prerequisites

- Python 3.9 or newer
- USB cable to connect badge to computer
- Badge in bootloader mode (instructions below)

## Step 1: Environment Setup (COMPLETED ✓)

The Python virtual environment has been created and dependencies installed:
- `esptool` - For flashing firmware
- `mpremote` - For copying files to badge

## Step 2: Flash Base MicroPython Firmware

The pre-compiled MicroPython firmware is located at:
```
firmware/micropython/lvgl_micropy_ESP32_GENERIC_S3-SPIRAM_OCT-16.bin
```

### Put Badge in Bootloader Mode

1. **If badge is already running MicroPython:**
   ```bash
   source venv/bin/activate
   mpremote bootloader
   sleep 2
   ```

2. **If badge is not running MicroPython:**
   - Bridge the BOOT pin to GND
   - Press RESET button
   - Release BOOT pin

### Flash the Firmware

```bash
# Activate virtual environment
source venv/bin/activate

# Erase existing flash (OPTIONAL but recommended for clean install)
esptool --port /dev/ttyACM0 erase_flash

# Flash the MicroPython firmware
esptool --port /dev/ttyACM0 --baud 1500000 write_flash 0 micropython/lvgl_micropy_ESP32_GENERIC_S3-SPIRAM_OCT-16.bin
```

**Note**: Replace `/dev/ttyACM0` with your badge's serial port:
- Linux: Usually `/dev/ttyACM0` or `/dev/ttyUSB0`
- macOS: Usually `/dev/cu.usbmodem*`
- Windows: Usually `COM3` or similar

To find your port:
```bash
# Linux/macOS
ls /dev/tty*

# Or use mpremote
mpremote connect list
```

## Step 3: Copy Badge Application Code

After flashing the base firmware, you need to copy the Python application code:

### Method 1: Using mpremote (Recommended)

```bash
source venv/bin/activate
cd firmware
mpremote cp -r badge/* :
```

This copies all files from `firmware/badge/` to the badge's filesystem.

### Method 2: Using the Update Script

The update script provides more control and can delete old files:

```bash
source venv/bin/activate
cd firmware

# Copy files and automatically reset badge
python scripts/update.py --reset push

# Backup files from badge to computer
python scripts/update.py pull
```

## Step 4: Verify Installation

After flashing and copying files:

1. Press the RESET button on the badge
2. The badge should boot and display the app menu
3. You can navigate using the function keys (F1-F5)

## Development Workflow

### Editing Code on Badge

For quick edits, you can use **Thonny IDE** to directly edit files on the badge via serial connection.

### Syncing Changes

After modifying code in the repository:

```bash
source venv/bin/activate
cd firmware
python scripts/update.py --reset push
```

### Accessing REPL

Connect via serial terminal to see debug output:

```bash
source venv/bin/activate
mpremote repl
```

Press `Ctrl+C` to interrupt and get a Python prompt, or `Ctrl+D` to soft reset.

## Troubleshooting

### Badge Not Detected

- Check USB cable (must support data, not just charging)
- Try different USB port
- Install/update USB serial drivers
- Check `dmesg` (Linux) or Device Manager (Windows)

### Flash Error

- Ensure badge is in bootloader mode
- Try lower baud rate: `--baud 115200`
- Try `esptool erase_flash` first

### Files Not Copying

- Ensure base MicroPython firmware is flashed first
- Check available space: `mpremote df`
- Reset badge and try again

### Display Issues

- Base firmware includes LVGL - don't flash regular MicroPython
- Use the provided `lvgl_micropy_*.bin` file

## Next Steps

### Creating Custom Apps

1. Copy `firmware/badge/apps/template_app.py`
2. Implement your app logic
3. Add to `firmware/badge/main.py`:
   ```python
   from apps import my_app
   user_apps = [
       my_app.MyApp("My App", badge),
       # other apps...
   ]
   ```

### Network/LoRa Communication

See `firmware/README.md` for details on:
- Defining protocols
- Sending/receiving messages
- Frequency slot selection (default: 9 for Supercon 9)

## Advanced: Rebuilding MicroPython from Source

Only needed if you want to modify the base firmware or add frozen modules.

See `firmware/micropython/LVGL_MICROPYTHON_COMPILE_NOTES` for detailed build instructions.

Quick overview:
```bash
git clone https://github.com/lvgl-micropython/lvgl_micropython
cd lvgl_micropython
# Apply patches and configure
python3 make.py esp32 BOARD=ESP32_GENERIC_S3 BOARD_VARIANT=SPIRAM_OCT \
  --flash-size=16 DISPLAY=nv3007 --enable-uart-repl=y --enable-cdc-repl=n \
  USER_C_MODULE="$(pwd)/../ucryptography/micropython.cmake"
```

## Resources

- Main README: `firmware/README.md`
- Build notes: `firmware/micropython/LVGL_MICROPYTHON_COMPILE_NOTES`
- App examples: `firmware/badge/apps/`
- User apps: `user_apps/`

## Summary

1. ✓ Virtual environment created
2. ✓ Dependencies installed (esptool, mpremote)
3. Flash MicroPython firmware (one-time)
4. Copy badge application code
5. Start developing!
