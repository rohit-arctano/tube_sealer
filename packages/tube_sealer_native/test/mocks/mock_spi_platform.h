#ifndef MOCK_SPI_PLATFORM_H
#define MOCK_SPI_PLATFORM_H

#include <cstdint>
#include <cstring>
#include <vector>

/**
 * Mock SPI platform layer for testing.
 *
 * Stores TX data and returns configurable RX data on transfer.
 * Header-only with static state for simplicity in tests.
 */

struct SpiPlatform {
    int  (*open)(uint8_t bus, uint8_t cs);
    int  (*configure)(int fd, uint32_t speed, uint8_t mode);
    int  (*transfer)(int fd, const uint8_t* tx, uint8_t* rx, size_t len);
    void (*close)(int fd);
};

struct MockSpiState {
    // Configurable return values
    int open_return_fd = 5;
    int configure_return = 0;
    int transfer_return = 0;  // 0 = return len, negative = error

    // Configurable RX data returned by transfer
    std::vector<uint8_t> rx_data;

    // Recorded call arguments
    bool open_called = false;
    uint8_t last_open_bus = 0;
    uint8_t last_open_cs = 0;

    bool configure_called = false;
    int last_configure_fd = -1;
    uint32_t last_configure_speed = 0;
    uint8_t last_configure_mode = 0;

    bool transfer_called = false;
    int last_transfer_fd = -1;
    std::vector<uint8_t> last_tx_data;
    size_t last_transfer_len = 0;

    bool close_called = false;
    int last_close_fd = -1;

    void reset() {
        open_return_fd = 5;
        configure_return = 0;
        transfer_return = 0;
        rx_data.clear();
        open_called = false;
        last_open_bus = 0;
        last_open_cs = 0;
        configure_called = false;
        last_configure_fd = -1;
        last_configure_speed = 0;
        last_configure_mode = 0;
        transfer_called = false;
        last_transfer_fd = -1;
        last_tx_data.clear();
        last_transfer_len = 0;
        close_called = false;
        last_close_fd = -1;
    }
};

inline MockSpiState g_mock_spi;

inline int mock_spi_open(uint8_t bus, uint8_t cs) {
    g_mock_spi.open_called = true;
    g_mock_spi.last_open_bus = bus;
    g_mock_spi.last_open_cs = cs;
    return g_mock_spi.open_return_fd;
}

inline int mock_spi_configure(int fd, uint32_t speed, uint8_t mode) {
    g_mock_spi.configure_called = true;
    g_mock_spi.last_configure_fd = fd;
    g_mock_spi.last_configure_speed = speed;
    g_mock_spi.last_configure_mode = mode;
    return g_mock_spi.configure_return;
}

inline int mock_spi_transfer(int fd, const uint8_t* tx, uint8_t* rx, size_t len) {
    g_mock_spi.transfer_called = true;
    g_mock_spi.last_transfer_fd = fd;
    g_mock_spi.last_transfer_len = len;
    if (tx) {
        g_mock_spi.last_tx_data.assign(tx, tx + len);
    }
    if (g_mock_spi.transfer_return < 0) return g_mock_spi.transfer_return;

    // Copy configurable RX data into output buffer
    if (rx) {
        size_t to_copy = std::min(len, g_mock_spi.rx_data.size());
        if (to_copy > 0) {
            std::memcpy(rx, g_mock_spi.rx_data.data(), to_copy);
        }
        // Zero-fill remainder if rx_data is shorter than len
        if (to_copy < len) {
            std::memset(rx + to_copy, 0, len - to_copy);
        }
    }
    return static_cast<int>(len);
}

inline void mock_spi_close(int fd) {
    g_mock_spi.close_called = true;
    g_mock_spi.last_close_fd = fd;
}

inline SpiPlatform make_mock_spi_platform() {
    return SpiPlatform{
        mock_spi_open,
        mock_spi_configure,
        mock_spi_transfer,
        mock_spi_close
    };
}

#endif /* MOCK_SPI_PLATFORM_H */
