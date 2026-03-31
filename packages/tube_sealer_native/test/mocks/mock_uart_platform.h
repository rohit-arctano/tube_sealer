#ifndef MOCK_UART_PLATFORM_H
#define MOCK_UART_PLATFORM_H

#include "uart_types.h"
#include "uart_platform.h"

#include <cstdint>
#include <cstring>
#include <vector>

/**
 * Mock UART platform layer for testing.
 *
 * Stores call arguments for verification and returns configurable values.
 * Header-only with static state for simplicity in tests.
 */

struct MockUartState {
    // Configurable return values
    int open_return_fd = 3;
    int write_return_bytes = 0;
    int read_return_bytes = 0;

    // Recorded call arguments
    bool open_called = false;
    UartConfig last_open_config{};

    bool write_called = false;
    std::vector<uint8_t> last_write_data;
    int last_write_fd = -1;

    bool read_called = false;
    int last_read_fd = -1;
    size_t last_read_len = 0;
    std::vector<uint8_t> read_buffer;  // data returned by read

    bool close_called = false;
    int last_close_fd = -1;

    void reset() {
        open_return_fd = 3;
        write_return_bytes = 0;
        read_return_bytes = 0;
        open_called = false;
        last_open_config = {};
        write_called = false;
        last_write_data.clear();
        last_write_fd = -1;
        read_called = false;
        last_read_fd = -1;
        last_read_len = 0;
        read_buffer.clear();
        close_called = false;
        last_close_fd = -1;
    }
};

inline MockUartState g_mock_uart;

inline int mock_uart_open(const UartConfig* cfg) {
    g_mock_uart.open_called = true;
    if (cfg) {
        g_mock_uart.last_open_config = *cfg;
    }
    return g_mock_uart.open_return_fd;
}

inline int mock_uart_read(int fd, uint8_t* buf, size_t len) {
    g_mock_uart.read_called = true;
    g_mock_uart.last_read_fd = fd;
    g_mock_uart.last_read_len = len;
    size_t to_copy = std::min(len, g_mock_uart.read_buffer.size());
    if (to_copy > 0 && buf) {
        std::memcpy(buf, g_mock_uart.read_buffer.data(), to_copy);
    }
    return (g_mock_uart.read_return_bytes > 0)
        ? g_mock_uart.read_return_bytes
        : static_cast<int>(to_copy);
}

inline int mock_uart_write(int fd, const uint8_t* buf, size_t len) {
    g_mock_uart.write_called = true;
    g_mock_uart.last_write_fd = fd;
    g_mock_uart.last_write_data.assign(buf, buf + len);
    return (g_mock_uart.write_return_bytes > 0)
        ? g_mock_uart.write_return_bytes
        : static_cast<int>(len);
}

inline void mock_uart_close(int fd) {
    g_mock_uart.close_called = true;
    g_mock_uart.last_close_fd = fd;
}

inline UartPlatform make_mock_uart_platform() {
    return UartPlatform{
        mock_uart_open,
        mock_uart_read,
        mock_uart_write,
        mock_uart_close
    };
}

#endif /* MOCK_UART_PLATFORM_H */
