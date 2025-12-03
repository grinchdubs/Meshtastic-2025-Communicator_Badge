/**
 * Custom PSRAM initialization for Supercon 2025 Badge
 * 
 * The APS6404 PSRAM chip requires specific initialization sequence
 * that the standard Arduino ESP-IDF doesn't handle correctly.
 * 
 * Root cause: ESP-IDF Arduino framework returns 0x00ffffff when reading
 * PSRAM ID, suggesting SPI timing or mode incompatibility with APS6404.
 * 
 * MicroPython successfully initializes the same hardware, proving the
 * chip is functional. The difference is likely in ESP-IDF version:
 * - Arduino framework: ESP-IDF v4.4.x
 * - MicroPython: ESP-IDF v5.0.x
 * 
 * Workaround attempts:
 * 1. Try forcing PSRAM init with relaxed error checking
 * 2. Add diagnostic logging to understand failure mode
 * 3. Eventually: upgrade to ESP-IDF v5.x or patch spiram library
 */

#include "esp_psram.h"
#include "esp_log.h"
#include "esp_system.h"
#include "soc/soc.h"

#ifdef CONFIG_IDF_TARGET_ESP32S3
#include "esp32s3/spiram.h"
#endif

static const char* TAG = "PSRAM_SUPERCON";

// Hook called VERY early in boot process, before Arduino core
extern "C" void bootloader_hook(void) __attribute__((weak));

extern "C" void bootloader_hook(void) {
    // This runs during bootloader phase
    // PSRAM should be initialized by bootloader based on sdkconfig
    ESP_LOGI(TAG, "Bootloader hook - PSRAM should init via sdkconfig");
}

// Hook called after Arduino core initialization
extern "C" void initVariant(void) __attribute__((weak));

extern "C" void initVariant(void) {
    ESP_LOGI(TAG, "=== Supercon 2025 Badge PSRAM Diagnostic ===");
    
    if (esp_psram_is_initialized()) {
        size_t psram_size = esp_psram_get_size();
        ESP_LOGI(TAG, "✓ PSRAM initialized successfully!");
        ESP_LOGI(TAG, "✓ PSRAM size: %d bytes (%d MB)", psram_size, psram_size / (1024*1024));
    } else {
        ESP_LOGW(TAG, "✗ PSRAM initialization FAILED");
        ESP_LOGW(TAG, "✗ Error: 0x00ffffff (PSRAM ID read error)");
        ESP_LOGW(TAG, "✗ APS6404 chip not responding to ESP-IDF");
        ESP_LOGW(TAG, "");
        ESP_LOGW(TAG, "Known Issue: Arduino ESP32 framework cannot");
        ESP_LOGW(TAG, "initialize APS6404 PSRAM on this hardware.");
        ESP_LOGW(TAG, "");
        ESP_LOGW(TAG, "MicroPython works fine = hardware is good");
        ESP_LOGW(TAG, "Problem is ESP-IDF version or configuration");
        ESP_LOGW(TAG, "");
        ESP_LOGW(TAG, "Consequence: Display will crash (needs 426KB,");
        ESP_LOGW(TAG, "only 214KB heap available without PSRAM)");
    }
    
    ESP_LOGI(TAG, "===========================================");
}
