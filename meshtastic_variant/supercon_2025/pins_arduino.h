#ifndef Pins_Arduino_h
#define Pins_Arduino_h

#include <stdint.h>

// UART0
#define TX 43
#define RX 44

// SPI for LoRa
static const uint8_t SS = 17;    // LORA_CS
static const uint8_t MOSI = 3;   // LORA_MOSI
static const uint8_t MISO = 9;   // LORA_MISO
static const uint8_t SCK = 8;    // LORA_SCK

// I2C for Keyboard
static const uint8_t SDA = 47;   // KBD_SDA
static const uint8_t SCL = 14;   // KBD_SCL

// I2C1 for SAO expansion
static const uint8_t SDA1 = 4;   // SAO_SDA
static const uint8_t SCL1 = 5;   // SAO_SCL

#endif /* Pins_Arduino_h */
