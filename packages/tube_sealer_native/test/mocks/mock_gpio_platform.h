#ifndef MOCK_GPIO_PLATFORM_H
#define MOCK_GPIO_PLATFORM_H

#include <cstdint>
#include <cstring>
#include <map>
#include <vector>

/**
 * Mock GPIO platform layer for testing.
 *
 * Reflects writes on reads (loopback) and provides configurable edge events.
 * Header-only with static state for simplicity in tests.
 */

struct GpioPlatform {
    int  (*open_chip)(const char* chip_path);
    int  (*configure_pin)(int chip_fd, uint16_t pin, uint8_t direction, uint8_t edge);
    int  (*write)(int chip_fd, uint16_t pin, uint8_t value);
    int  (*read)(int chip_fd, uint16_t pin, uint8_t* value);
    int  (*wait_event)(int chip_fd, uint16_t pin, int timeout_ms, uint8_t* edge, uint8_t* value);
    void (*close)(int chip_fd);
};

struct MockGpioEdgeEvent {
    uint8_t edge;   // 1=rising, 2=falling
    uint8_t value;  // pin value after event
};

struct MockGpioState {
    // Configurable return values
    int open_chip_return_fd = 6;
    int configure_pin_return = 0;
    int write_return = 0;
    int read_return = 0;
    int wait_event_return = 0;  // 0 = success, negative = error/timeout

    // Recorded call arguments
    bool open_chip_called = false;
    char last_chip_path[128] = {};

    bool configure_pin_called = false;
    int last_configure_chip_fd = -1;
    uint16_t last_configure_pin = 0;
    uint8_t last_configure_direction = 0;
    uint8_t last_configure_edge = 0;

    bool write_called = false;
    int last_write_chip_fd = -1;
    uint16_t last_write_pin = 0;
    uint8_t last_write_value = 0;

    bool read_called = false;
    int last_read_chip_fd = -1;
    uint16_t last_read_pin = 0;

    bool wait_event_called = false;
    int last_wait_chip_fd = -1;
    uint16_t last_wait_pin = 0;
    int last_wait_timeout_ms = 0;

    bool close_called = false;
    int last_close_fd = -1;

    // Loopback: pin -> value (writes are reflected on reads)
    std::map<uint16_t, uint8_t> pin_values;

    // Configurable edge events returned by wait_event (consumed in order)
    std::vector<MockGpioEdgeEvent> pending_events;
    size_t event_index = 0;

    void reset() {
        open_chip_return_fd = 6;
        configure_pin_return = 0;
        write_return = 0;
        read_return = 0;
        wait_event_return = 0;
        open_chip_called = false;
        std::memset(last_chip_path, 0, sizeof(last_chip_path));
        configure_pin_called = false;
        last_configure_chip_fd = -1;
        last_configure_pin = 0;
        last_configure_direction = 0;
        last_configure_edge = 0;
        write_called = false;
        last_write_chip_fd = -1;
        last_write_pin = 0;
        last_write_value = 0;
        read_called = false;
        last_read_chip_fd = -1;
        last_read_pin = 0;
        wait_event_called = false;
        last_wait_chip_fd = -1;
        last_wait_pin = 0;
        last_wait_timeout_ms = 0;
        close_called = false;
        last_close_fd = -1;
        pin_values.clear();
        pending_events.clear();
        event_index = 0;
    }
};

inline MockGpioState g_mock_gpio;

inline int mock_gpio_open_chip(const char* chip_path) {
    g_mock_gpio.open_chip_called = true;
    if (chip_path) {
        std::strncpy(g_mock_gpio.last_chip_path, chip_path,
                     sizeof(g_mock_gpio.last_chip_path) - 1);
    }
    return g_mock_gpio.open_chip_return_fd;
}

inline int mock_gpio_configure_pin(int chip_fd, uint16_t pin,
                                   uint8_t direction, uint8_t edge) {
    g_mock_gpio.configure_pin_called = true;
    g_mock_gpio.last_configure_chip_fd = chip_fd;
    g_mock_gpio.last_configure_pin = pin;
    g_mock_gpio.last_configure_direction = direction;
    g_mock_gpio.last_configure_edge = edge;
    return g_mock_gpio.configure_pin_return;
}

inline int mock_gpio_write(int chip_fd, uint16_t pin, uint8_t value) {
    g_mock_gpio.write_called = true;
    g_mock_gpio.last_write_chip_fd = chip_fd;
    g_mock_gpio.last_write_pin = pin;
    g_mock_gpio.last_write_value = value;
    if (g_mock_gpio.write_return < 0) return g_mock_gpio.write_return;

    // Loopback: store value so reads reflect it
    g_mock_gpio.pin_values[pin] = value;
    return 0;
}

inline int mock_gpio_read(int chip_fd, uint16_t pin, uint8_t* value) {
    g_mock_gpio.read_called = true;
    g_mock_gpio.last_read_chip_fd = chip_fd;
    g_mock_gpio.last_read_pin = pin;
    if (g_mock_gpio.read_return < 0) return g_mock_gpio.read_return;

    // Loopback: return previously written value (default 0)
    if (value) {
        auto it = g_mock_gpio.pin_values.find(pin);
        *value = (it != g_mock_gpio.pin_values.end()) ? it->second : 0;
    }
    return 0;
}

inline int mock_gpio_wait_event(int chip_fd, uint16_t pin, int timeout_ms,
                                uint8_t* edge, uint8_t* value) {
    g_mock_gpio.wait_event_called = true;
    g_mock_gpio.last_wait_chip_fd = chip_fd;
    g_mock_gpio.last_wait_pin = pin;
    g_mock_gpio.last_wait_timeout_ms = timeout_ms;

    if (g_mock_gpio.wait_event_return < 0) return g_mock_gpio.wait_event_return;

    // Return next pending event if available
    if (g_mock_gpio.event_index < g_mock_gpio.pending_events.size()) {
        const auto& evt = g_mock_gpio.pending_events[g_mock_gpio.event_index++];
        if (edge) *edge = evt.edge;
        if (value) *value = evt.value;
        // Also update loopback state
        g_mock_gpio.pin_values[pin] = evt.value;
        return 0;
    }
    // No more events — simulate timeout
    return -1;
}

inline void mock_gpio_close(int fd) {
    g_mock_gpio.close_called = true;
    g_mock_gpio.last_close_fd = fd;
}

inline GpioPlatform make_mock_gpio_platform() {
    return GpioPlatform{
        mock_gpio_open_chip,
        mock_gpio_configure_pin,
        mock_gpio_write,
        mock_gpio_read,
        mock_gpio_wait_event,
        mock_gpio_close
    };
}

#endif /* MOCK_GPIO_PLATFORM_H */
