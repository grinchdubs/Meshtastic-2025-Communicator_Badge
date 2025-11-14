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

// Display I2C/SPI (NV3007)
// Currently unused in Phase 1 (headless mode)
#define LCD_SDA 21
#define LCD_SCL 38
#define LCD_RST 40
#define LCD_CS 41
#define LCD_TE 42
#define LCD_BACKLIGHT 2  // PWM
#define LCD_DC 39        // Data/Command

// LoRa Radio (SX1262 via SPI)
#define USE_SX1262

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

// Phase 1: Headless configuration
// Display and keyboard support will be added in later phases
// For now, use BLE/WiFi for configuration and messaging

// Optional: Enable power saving features
#define USE_POWERSAVE
#define SLEEP_TIME 300

// Enable BLE for initial configuration
#define HAS_BLUETOOTH 1
#define HAS_WIFI 1

// Board identification
#define HW_VENDOR meshtastic_HardwareModel_PRIVATE_HW
