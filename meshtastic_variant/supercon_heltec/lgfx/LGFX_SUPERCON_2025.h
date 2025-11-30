#pragma once

#define LGFX_USE_V1
#include <LovyanGFX.hpp>

#ifndef SPI_FREQUENCY
#define SPI_FREQUENCY 80000000
#endif
#ifndef SPI2_HOST
#define SPI2_HOST 1
#endif

class LGFX_SUPERCON_2025 : public lgfx::LGFX_Device
{
    lgfx::Panel_ST7789 _panel_instance;  // NV3007 is ST7789-compatible
    lgfx::Bus_SPI _bus_instance;
    lgfx::Light_PWM _light_instance;

  public:
    const uint32_t screenWidth = 428;   // Physical width (landscape)
    const uint32_t screenHeight = 142;  // Physical height (landscape)

    bool hasButton(void) { return true; }

    void setBrightness(uint8_t brightness)
    {
        _light_instance.setBrightness(brightness);
    }

    LGFX_SUPERCON_2025(void)
    {
        {
            auto cfg = _bus_instance.config();

            // SPI bus configuration
            cfg.spi_host = (spi_host_device_t)SPI2_HOST;
            cfg.spi_mode = 0;
            cfg.freq_write = SPI_FREQUENCY;  // 80MHz for NV3007
            cfg.freq_read = 16000000;
            cfg.spi_3wire = false;
            cfg.use_lock = true;
            cfg.dma_channel = SPI_DMA_CH_AUTO;
            cfg.pin_sclk = 38;  // TFT_SCL
            cfg.pin_mosi = 21;  // TFT_SDA
            cfg.pin_miso = -1;  // Not connected
            cfg.pin_dc = 39;    // TFT_DC

            _bus_instance.config(cfg);
            _panel_instance.setBus(&_bus_instance);
        }

        {
            // Display panel configuration
            auto cfg = _panel_instance.config();

            cfg.pin_cs = 41;   // TFT_CS
            cfg.pin_rst = 40;  // TFT_RST
            cfg.pin_busy = -1;

            cfg.panel_width = 428;    // NV3007 landscape width
            cfg.panel_height = 142;   // NV3007 landscape height
            cfg.offset_x = 0;
            cfg.offset_y = 0;         // No Y offset needed
            cfg.offset_rotation = 0;  // Already landscape orientation
            cfg.dummy_read_pixel = 8;
            cfg.dummy_read_bits = 1;
            cfg.readable = false;
            cfg.invert = false;
            cfg.rgb_order = false;
            cfg.dlen_16bit = false;
            cfg.bus_shared = false;

            _panel_instance.config(cfg);
        }

        {
            // Backlight configuration
            auto cfg = _light_instance.config();

            cfg.pin_bl = 2;      // TFT_BL
            cfg.invert = false;  // HIGH = backlight ON
            cfg.freq = 44100;
            cfg.pwm_channel = 7;

            _light_instance.config(cfg);
            _panel_instance.setLight(&_light_instance);
        }

        setPanel(&_panel_instance);
    }
};
