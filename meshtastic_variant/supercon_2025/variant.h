/*
 * Hackaday Supercon 2025 Communicator Badge
 *
 * Hardware:
 *  - ESP32-S3-WROOM-1 (16MB Flash, 8MB PSRAM Octal)
 *  - Wio-SX1262 LoRa module (915MHz)
 *  - NV3007 TFT Display (428x142)
 *  - TCA8418 I2C Keyboard Controller
 *  - MCP73831 Battery Charger
 *  - SAO v2 Expansion Port
 *
 * Pin Definitions based on firmware/badge/hardware/board.py
 */

// GPIO 0 is boot button (shared with BOOT)
#define BUTTON_PIN 0
#define BUTTON_NEED_PULLUP

// Debug LED (active low)
#define LED_PIN 1
#define LED_INVERTED 1

// Battery monitoring (if available via ADC)
// Note: May need custom implementation depending on charging circuit
// #define BATTERY_PIN ADC_PIN_HERE
// #define ADC_MULTIPLIER 2.0
// #define ADC_CHANNEL ADC1_CHANNEL_HERE

// I2C for Keyboard (TCA8418)
#define I2C_SDA 47  // KBD_SDA
#define I2C_SCL 14  // KBD_SCL
#define KB_INT_PIN 13  // Keyboard interrupt
#define KB_RST_PIN 48  // Keyboard reset

// I2C for SAO expansion
#define I2C_SDA1 4   // SAO_SDA
#define I2C_SCL1 5   // SAO_SCL
#define SAO_GPIO1_PIN 7
#define SAO_GPIO2_PIN 6

// Display SPI (NV3007 TFT - 428×142 landscape)
// NV3007 is similar to ST7789 but with custom initialization
#define HAS_SCREEN 1
#define HAS_TFT 1
#define USE_NV3007

// SPI pins for display
#define TFT_SDA 21      // MOSI
#define TFT_SCL 38      // SCK
#define TFT_MISO -1     // Not connected
#define TFT_CS 41       // Chip Select
#define TFT_DC 39       // Data/Command
#define TFT_RST 40      // Reset
#define TFT_BL 2        // Backlight (PWM)
#define TFT_TE 42       // Tearing Effect (optional)

// Display configuration
#define TFT_WIDTH 142
#define TFT_HEIGHT 428
#define TFT_OFFSET_X 0
#define TFT_OFFSET_Y 12  // From MicroPython firmware
#define TFT_OFFSET_ROTATION 3  // 270 degrees (landscape)
#define TFT_INVERT false
#define TFT_BACKLIGHT_ON HIGH

// LovyanGFX configuration for NV3007
#define ST7789_CS TFT_CS
#define ST7789_RS TFT_DC
#define ST7789_SDA TFT_SDA
#define ST7789_SCK TFT_SCL
#define ST7789_RESET TFT_RST
#define ST7789_MISO TFT_MISO
#define ST7789_BUSY -1
#define ST7789_BL TFT_BL
#define ST7789_SPI_HOST SPI2_HOST
#define SPI_FREQUENCY 80000000   // 80MHz from MicroPython
#define SPI_READ_FREQUENCY 16000000

// Use ST7789 panel as base (NV3007 is compatible)
// Note: ST7789S is defined in platformio.ini

// LoRa Radio (SX1262 via SPI)
// Note: USE_SX1262 is defined in platformio.ini

#define LORA_SCK 8
#define LORA_MISO 9
#define LORA_MOSI 3
#define LORA_CS 17

#define LORA_RESET 18
#define LORA_DIO1 16   // SX1262 IRQ
#define LORA_DIO2 15   // SX1262 BUSY (using RF_BUSY)
#define LORA_RXEN -1   // Not used with DIO2 RF switch
#define LORA_TXEN -1   // Not used with DIO2 RF switch

// SX126X specific pins
#define SX126X_CS LORA_CS
#define SX126X_DIO1 LORA_DIO1
#define SX126X_BUSY LORA_DIO2
#define SX126X_RESET LORA_RESET
#define SX126X_DIO2_AS_RF_SWITCH
// Note: RF_SW (GPIO10) may need to be controlled for antenna switching
// The Wio-SX1262 module typically handles this internally
#define SX126X_DIO3_TCXO_VOLTAGE 1.8

// Antenna switch control (if needed)
#define RF_SW_PIN 10  // Set high for proper antenna switching

// GPS - Not present on this hardware
#define GPS_DEFAULT_NOT_PRESENT 1

// Enable BLE and WiFi
#define HAS_BLUETOOTH 1
#define HAS_WIFI 1

// Optional: Enable power saving features
#define USE_POWERSAVE
#define SLEEP_TIME 300

// Board identification
#define HW_VENDOR meshtastic_HardwareModel_PRIVATE_HW

// Keyboard support (Phase 3 - future)
// #define INPUTDRIVER_I2C_KBD_TYPE=0x55  // TCA8418 address
