#ifdef _WIN32

#include "i2c_platform.h"

#include <cstring>
#include <vector>

/**
 * Windows stub/mock I2C platform.
 *
 * Returns a fake fd and stores written data internally.
 * Used for development and testing on Windows without real hardware.
 */

static constexpr int FAKE_FD = 98;
static uint8_t s_current_address = 0;
static std::vector<uint8_t> s_write_buf;

static int win_i2c_open(uint8_t bus) {
    (void)bus;
    s_write_buf.clear();
    s_current_address = 0;
    return FAKE_FD;
}

static int win_i2c_set_address(int fd, uint8_t addr) {
    (void)fd;
    s_current_address = addr;
    return 0;
}

static int win_i2c_read(int fd, uint8_t* buf, size_t len) {
    (void)fd;
    /* Return zeros — no real hardware */
    if (buf && len > 0) {
        std::memset(buf, 0, len);
    }
    return static_cast<int>(len);
}

static int win_i2c_write(int fd, const uint8_t* buf, size_t len) {
    (void)fd;
    if (buf && len > 0) {
        s_write_buf.assign(buf, buf + len);
    }
    return static_cast<int>(len);
}

static void win_i2c_close(int fd) {
    (void)fd;
    s_write_buf.clear();
    s_current_address = 0;
}

I2cPlatform i2c_platform_default() {
    return I2cPlatform{
        win_i2c_open,
        win_i2c_set_address,
        win_i2c_read,
        win_i2c_write,
        win_i2c_close
    };
}

#endif /* _WIN32 */
