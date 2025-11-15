/**
 * @file LGFX_SUPERCON_2025.h
 * @brief LovyanGFX driver configuration for Hackaday Supercon 2025 Communicator Badge
 * @date 2025-11-15
 *
 * Hardware: ESP32-S3-WROOM-1 with NV3007 TFT Display (428×142)
 * Display Controller: NV3007 (ST7789-compatible)
 * Resolution: 428×142 pixels (landscape orientation)
 * Interface: SPI @ 80MHz
 * Backlight: PWM controlled
 */

#pragma once

#define LGFX_USE_V1
#include <LovyanGFX.hpp>

#ifndef SPI_FREQUENCY
#define SPI_FREQUENCY 80000000
#endif

class LGFX_SUPERCON_2025 : public lgfx::LGFX_Device
{
    lgfx::Panel_ST7789 _panel_instance;
    lgfx::Bus_SPI _bus_instance;
    lgfx::Light_PWM _light_instance;

  public:
    // Supercon 2025 has a wide 428×142 landscape display
    const uint32_t screenWidth = 428;
    const uint32_t screenHeight = 142;

    bool hasButton(void) { return true; }

    void setBrightness(uint8_t brightness)
    {
        _light_instance.setBrightness(brightness);
    }

    uint8_t getBrightness(void) const
    {
        return _light_instance.getBrightness();
    }

    LGFX_SUPERCON_2025(void)
    {
        {
            auto cfg = _bus_instance.config();

            // SPI Configuration
            cfg.spi_host = SPI2_HOST;
            cfg.spi_mode = 0;
            cfg.freq_write = SPI_FREQUENCY; // 80MHz for fast rendering
            cfg.freq_read = 16000000;       // 16MHz for reading
            cfg.spi_3wire = false;
            cfg.use_lock = true;               // Use transaction locking
            cfg.dma_channel = SPI_DMA_CH_AUTO; // Auto-select DMA channel

            // SPI Pin Configuration (from variant.h)
            cfg.pin_sclk = 38;  // TFT_SCL - SPI Clock
            cfg.pin_mosi = 21;  // TFT_SDA - SPI MOSI
            cfg.pin_miso = -1;  // Not used for display
            cfg.pin_dc = 39;    // TFT_DC - Data/Command

            _bus_instance.config(cfg);
            _panel_instance.setBus(&_bus_instance);
        }

        {
            // Display Panel Configuration
            auto cfg = _panel_instance.config();

            cfg.pin_cs = 41;   // TFT_CS - Chip Select
            cfg.pin_rst = 40;  // TFT_RST - Reset
            cfg.pin_busy = -1; // Not used

            // NV3007 is 428×142 in landscape mode
            cfg.panel_width = screenWidth;
            cfg.panel_height = screenHeight;
            cfg.offset_x = 0;
            cfg.offset_y = 0;
            cfg.offset_rotation = 0; // No rotation offset needed (already landscape)
            cfg.dummy_read_pixel = 8;
            cfg.dummy_read_bits = 1;
            cfg.readable = false;       // Display is write-only
            cfg.invert = false;         // No color inversion needed
            cfg.rgb_order = false;      // RGB order correct
            cfg.dlen_16bit = false;
            cfg.bus_shared = false;     // Dedicated SPI bus for display

            _panel_instance.config(cfg);
        }

        {
            // Backlight Configuration (PWM)
            auto cfg = _light_instance.config();

            cfg.pin_bl = 2;         // TFT_BL - Backlight PWM pin
            cfg.invert = false;     // Normal PWM polarity
            cfg.freq = 44100;       // 44.1kHz PWM frequency
            cfg.pwm_channel = 7;    // Use PWM channel 7

            _light_instance.config(cfg);
            _panel_instance.setLight(&_light_instance);
        }

        setPanel(&_panel_instance);
    }
};
