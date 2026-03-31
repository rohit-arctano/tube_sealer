#ifdef _WIN32

#include "uart_platform.h"

#include <cstring>
#include <vector>

/**
 * Windows stub/mock UART platform.
 *
 * Returns a fake fd and stores written data internally.
 * Used for development and testing on Windows without real hardware.
 */

static constexpr int FAKE_FD = 99;
static std::vector<uint8_t> s_write_buf;

static int win_uart_open(const UartConfig* cfg) {
    (void)cfg;
    s_write_buf.clear();
    return FAKE_FD;
}

static int win_uart_read(int fd, uint8_t* buf, size_t len) {
    (void)fd;
    (void)buf;
    (void)len;
    return 0; /* no data available in stub */
}

static int win_uart_write(int fd, const uint8_t* buf, size_t len) {
    (void)fd;
    if (buf && len > 0) {
        s_write_buf.insert(s_write_buf.end(), buf, buf + len);
    }
    return static_cast<int>(len);
}

static void win_uart_close(int fd) {
    (void)fd;
    s_write_buf.clear();
}

UartPlatform uart_platform_default() {
    return UartPlatform{
        win_uart_open,
        win_uart_read,
        win_uart_write,
        win_uart_close
    };
}

#endif /* _WIN32 */
