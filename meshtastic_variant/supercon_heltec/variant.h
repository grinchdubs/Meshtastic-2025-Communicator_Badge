// Hackaday Supercon 2025 Badge - Simplified build based on Heltec V3
// Uses Supercon hardware pin mappings without TFT display support

#define LED_PIN 1
#define LED_INVERTED 1 // Active low

#define BUTTON_PIN 0
#define BUTTON_NEED_PULLUP

// LoRa Radio (SX1262) - Supercon pin mappings
#define USE_SX1262

#define LORA_SCK 8
#define LORA_MISO 9
#define LORA_MOSI 3
#define LORA_CS 17

#define LORA_RESET 18
#define LORA_DIO1 16   // SX1262 IRQ
#define LORA_DIO2 15   // SX1262 BUSY
#define LORA_DIO0 -1   // Not used

#define SX126X_CS LORA_CS
#define SX126X_DIO1 LORA_DIO1
#define SX126X_BUSY LORA_DIO2
#define SX126X_RESET LORA_RESET
#define SX126X_DIO2_AS_RF_SWITCH
#define SX126X_DIO3_TCXO_VOLTAGE 1.8

// Antenna switch control
#define RF_SW_PIN 10

// I2C for Keyboard (TCA8418)
#define I2C_SDA 47
#define I2C_SCL 14

// I2C for SAO expansion (secondary bus)
#define I2C_SDA1 4
#define I2C_SCL1 5

// NV3007 TFT Display (428×142)
// NV3007 is ST7789-compatible - using LovyanGFX driver
#define HAS_SCREEN 1
#define HAS_TFT 1

// Display SPI pins
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
#define TFT_OFFSET_Y 12
#define TFT_OFFSET_ROTATION 3  // 270 degrees (landscape)
#define TFT_INVERT false
#define TFT_BACKLIGHT_ON HIGH

// ST7789 configuration for LovyanGFX
#define ST7789_CS TFT_CS
#define ST7789_RS TFT_DC
#define ST7789_SDA TFT_SDA
#define ST7789_SCK TFT_SCL
#define ST7789_RESET TFT_RST
#define ST7789_MISO TFT_MISO
#define ST7789_BUSY -1
#define ST7789_BL TFT_BL
#define ST7789_SPI_HOST SPI2_HOST
#define SPI_FREQUENCY 80000000   // 80MHz
#define SPI_READ_FREQUENCY 16000000
