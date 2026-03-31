#ifndef MOCK_ADC_PLATFORM_H
#define MOCK_ADC_PLATFORM_H

#include <cstdint>
#include <map>

/**
 * Mock ADC platform layer for testing.
 *
 * The ADC doesn't have its own hardware platform layer (it communicates
 * through I2C/SPI), but this mock provides configurable raw readings
 * and scale factors for testing the ADC manager directly.
 *
 * Header-only with static state for simplicity in tests.
 */

struct MockAdcChannelConfig {
    int32_t  raw_value = 0;
    float    scale_factor = 1.0f;
    bool     should_fail = false;
    int      error_code = 0;
    int32_t  last_valid_raw = 0;
    float    last_valid_scale = 1.0f;
};

struct MockAdcState {
    // Per-channel configurable readings: key = channel number
    std::map<uint8_t, MockAdcChannelConfig> channels;

    // Recorded call arguments
    bool read_called = false;
    uint8_t last_read_channel = 0;
    uint8_t last_chip_type = 0;

    bool init_called = false;
    uint8_t last_init_chip_type = 0;
    uint8_t last_init_channel = 0;

    // Configure a channel's mock reading
    void set_channel(uint8_t channel, int32_t raw, float scale) {
        channels[channel].raw_value = raw;
        channels[channel].scale_factor = scale;
        channels[channel].last_valid_raw = raw;
        channels[channel].last_valid_scale = scale;
    }

    // Configure a channel to fail on next read
    void set_channel_fail(uint8_t channel, int error) {
        channels[channel].should_fail = true;
        channels[channel].error_code = error;
    }

    // Read a channel (returns raw + scale, or error + last valid)
    struct ReadResult {
        int     status;       // 0 = ok, negative = error
        int32_t raw_value;
        float   scale_factor;
    };

    ReadResult read_channel(uint8_t channel) {
        read_called = true;
        last_read_channel = channel;

        auto it = channels.find(channel);
        if (it == channels.end()) {
            // Unconfigured channel — return zero
            return {0, 0, 1.0f};
        }

        auto& ch = it->second;
        if (ch.should_fail) {
            // Return error with last valid reading
            return {ch.error_code, ch.last_valid_raw, ch.last_valid_scale};
        }

        // Update last valid and return current
        ch.last_valid_raw = ch.raw_value;
        ch.last_valid_scale = ch.scale_factor;
        return {0, ch.raw_value, ch.scale_factor};
    }

    void reset() {
        channels.clear();
        read_called = false;
        last_read_channel = 0;
        last_chip_type = 0;
        init_called = false;
        last_init_chip_type = 0;
        last_init_channel = 0;
    }
};

inline MockAdcState g_mock_adc;

#endif /* MOCK_ADC_PLATFORM_H */
