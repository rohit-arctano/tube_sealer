#ifndef MOCK_I2C_PLATFORM_H
#define MOCK_I2C_PLATFORM_H

#include "i2c_types.h"
#include "i2c_platform.h"

#include <cstdint>
#include <cstring>
#include <map>
#include <vector>

/**
 * Mock I2C platform layer for testing.
 *
 * Stores written data so read-after-write returns it (loopback per address+register).
 * Header-only with static state for simplicity in tests.
 */

struct MockI2cState {
    // Configurable return values
    int open_return_fd = 4;
    int set_address_return = 0;
    int write_return = 0;  // 0 = return len, negative = error
    int read_return = 0;   // 0 = return len, negative = error

    // Recorded call arguments
    bool open_called = false;
    uint8_t last_open_bus = 0;

    bool set_address_called = false;
    uint8_t last_address = 0;
    int last_set_address_fd = -1;

    bool write_called = false;
    int last_write_fd = -1;
    std::vector<uint8_t> last_write_data;

    bool read_called = false;
    int last_read_fd = -1;
    size_t last_read_len = 0;

    bool close_called = false;
    int last_close_fd = -1;

    // Loopback storage: key = (address << 8 | register), value = data bytes
    // The current address is tracked via set_address calls
    uint8_t current_address = 0;
    std::map<uint16_t, std::vector<uint8_t>> data_store;

    void reset() {
        open_return_fd = 4;
        set_address_return = 0;
        write_return = 0;
        read_return = 0;
        open_called = false;
        last_open_bus = 0;
        set_address_called = false;
        last_address = 0;
        last_set_address_fd = -1;
        write_called = false;
        last_write_fd = -1;
        last_write_data.clear();
        read_called = false;
        last_read_fd = -1;
        last_read_len = 0;
        close_called = false;
        last_close_fd = -1;
        current_address = 0;
        data_store.clear();
    }
};

inline MockI2cState g_mock_i2c;

inline int mock_i2c_open(uint8_t bus) {
    g_mock_i2c.open_called = true;
    g_mock_i2c.last_open_bus = bus;
    return g_mock_i2c.open_return_fd;
}

inline int mock_i2c_set_address(int fd, uint8_t addr) {
    g_mock_i2c.set_address_called = true;
    g_mock_i2c.last_set_address_fd = fd;
    g_mock_i2c.last_address = addr;
    g_mock_i2c.current_address = addr;
    return g_mock_i2c.set_address_return;
}

inline int mock_i2c_read(int fd, uint8_t* buf, size_t len) {
    g_mock_i2c.read_called = true;
    g_mock_i2c.last_read_fd = fd;
    g_mock_i2c.last_read_len = len;
    if (g_mock_i2c.read_return < 0) return g_mock_i2c.read_return;

    // Look up stored data for current address
    // First byte of a write is typically the register, so we use address as key
    uint16_t key = static_cast<uint16_t>(g_mock_i2c.current_address);
    auto it = g_mock_i2c.data_store.find(key);
    if (it != g_mock_i2c.data_store.end() && buf) {
        size_t to_copy = std::min(len, it->second.size());
        std::memcpy(buf, it->second.data(), to_copy);
        return static_cast<int>(to_copy);
    }
    return static_cast<int>(len);
}

inline int mock_i2c_write(int fd, const uint8_t* buf, size_t len) {
    g_mock_i2c.write_called = true;
    g_mock_i2c.last_write_fd = fd;
    g_mock_i2c.last_write_data.assign(buf, buf + len);
    if (g_mock_i2c.write_return < 0) return g_mock_i2c.write_return;

    // Store written data keyed by current address for read-after-write
    uint16_t key = static_cast<uint16_t>(g_mock_i2c.current_address);
    g_mock_i2c.data_store[key] = std::vector<uint8_t>(buf, buf + len);
    return static_cast<int>(len);
}

inline void mock_i2c_close(int fd) {
    g_mock_i2c.close_called = true;
    g_mock_i2c.last_close_fd = fd;
}

inline I2cPlatform make_mock_i2c_platform() {
    return I2cPlatform{
        mock_i2c_open,
        mock_i2c_set_address,
        mock_i2c_read,
        mock_i2c_write,
        mock_i2c_close
    };
}

#endif /* MOCK_I2C_PLATFORM_H */
