#ifndef _WIN32

#include "i2c_platform.h"

#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/i2c-dev.h>
#include <cstdio>

/* ── Platform functions ────────────────────────────────────────────── */

static int linux_i2c_open(uint8_t bus) {
    char path[32];
    std::snprintf(path, sizeof(path), "/dev/i2c-%u", bus);

    int fd = ::open(path, O_RDWR);
    if (fd < 0) return -1;

    return fd;
}

static int linux_i2c_set_address(int fd, uint8_t addr) {
    if (ioctl(fd, I2C_SLAVE, static_cast<unsigned long>(addr)) < 0) {
        return -1;
    }
    return 0;
}

static int linux_i2c_read(int fd, uint8_t* buf, size_t len) {
    ssize_t n = ::read(fd, buf, len);
    return static_cast<int>(n);
}

static int linux_i2c_write(int fd, const uint8_t* buf, size_t len) {
    ssize_t n = ::write(fd, buf, len);
    return static_cast<int>(n);
}

static void linux_i2c_close(int fd) {
    ::close(fd);
}

/* ── Factory ───────────────────────────────────────────────────────── */

I2cPlatform i2c_platform_default() {
    return I2cPlatform{
        linux_i2c_open,
        linux_i2c_set_address,
        linux_i2c_read,
        linux_i2c_write,
        linux_i2c_close
    };
}

#endif /* !_WIN32 */
