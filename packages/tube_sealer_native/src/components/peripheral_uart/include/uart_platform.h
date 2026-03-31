#ifndef TSN_UART_PLATFORM_H
#define TSN_UART_PLATFORM_H

#include "uart_types.h"
#include <cstddef>
#include <cstdint>

/**
 * Platform abstraction for UART I/O.
 *
 * A struct of function pointers so the manager can be tested with mocks
 * and swapped between Linux / Windows implementations at init time.
 */
struct UartPlatform {
    int  (*open)(const UartConfig* cfg);
    int  (*read)(int fd, uint8_t* buf, size_t len);
    int  (*write)(int fd, const uint8_t* buf, size_t len);
    void (*close)(int fd);
};

/* Platform-specific factory (implemented in uart_linux.cpp / uart_windows.cpp) */
UartPlatform uart_platform_default();

#endif /* TSN_UART_PLATFORM_H */
