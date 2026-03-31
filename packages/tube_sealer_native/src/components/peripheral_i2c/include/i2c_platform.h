#ifndef TSN_I2C_PLATFORM_H
#define TSN_I2C_PLATFORM_H

#include "i2c_types.h"
#include <cstddef>
#include <cstdint>

/**
 * Platform abstraction for I2C I/O.
 *
 * A struct of function pointers so the manager can be tested with mocks
 * and swapped between Linux / Windows implementations at init time.
 */
struct I2cPlatform {
    int  (*open)(uint8_t bus);
    int  (*set_address)(int fd, uint8_t addr);
    int  (*read)(int fd, uint8_t* buf, size_t len);
    int  (*write)(int fd, const uint8_t* buf, size_t len);
    void (*close)(int fd);
};

/* Platform-specific factory (implemented in i2c_linux.cpp / i2c_windows.cpp) */
I2cPlatform i2c_platform_default();

#endif /* TSN_I2C_PLATFORM_H */
