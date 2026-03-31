#ifndef _WIN32

#include "uart_platform.h"

#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#include <cstring>

/* ── Helpers ───────────────────────────────────────────────────────── */

static speed_t to_speed(uint32_t baud) {
    switch (baud) {
        case 9600:   return B9600;
        case 19200:  return B19200;
        case 38400:  return B38400;
        case 57600:  return B57600;
        case 115200: return B115200;
        case 230400: return B230400;
        case 460800: return B460800;
        case 921600: return B921600;
        default:     return B9600;
    }
}

/* ── Platform functions ────────────────────────────────────────────── */

static int linux_uart_open(const UartConfig* cfg) {
    if (!cfg || cfg->device_path[0] == '\0') return -1;

    int fd = ::open(cfg->device_path, O_RDWR | O_NOCTTY | O_NONBLOCK);
    if (fd < 0) return -1;

    struct termios tty{};
    if (tcgetattr(fd, &tty) != 0) {
        ::close(fd);
        return -1;
    }

    /* Baud rate */
    speed_t spd = to_speed(cfg->baud_rate);
    cfsetispeed(&tty, spd);
    cfsetospeed(&tty, spd);

    /* Data bits */
    tty.c_cflag &= ~CSIZE;
    switch (cfg->data_bits) {
        case 5: tty.c_cflag |= CS5; break;
        case 6: tty.c_cflag |= CS6; break;
        case 7: tty.c_cflag |= CS7; break;
        default: tty.c_cflag |= CS8; break;
    }

    /* Stop bits */
    if (cfg->stop_bits == 2)
        tty.c_cflag |= CSTOPB;
    else
        tty.c_cflag &= ~CSTOPB;

    /* Parity */
    switch (cfg->parity) {
        case 1: /* odd */
            tty.c_cflag |= PARENB | PARODD;
            break;
        case 2: /* even */
            tty.c_cflag |= PARENB;
            tty.c_cflag &= ~PARODD;
            break;
        default: /* none */
            tty.c_cflag &= ~PARENB;
            break;
    }

    /* Flow control */
    switch (cfg->flow_control) {
        case 1: /* hardware */
            tty.c_cflag |= CRTSCTS;
            break;
        case 2: /* software */
            tty.c_iflag |= (IXON | IXOFF | IXANY);
            break;
        default: /* none */
            tty.c_cflag &= ~CRTSCTS;
            tty.c_iflag &= ~(IXON | IXOFF | IXANY);
            break;
    }

    /* Raw mode — no canonical processing, no echo */
    tty.c_cflag |= (CLOCAL | CREAD);
    tty.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);
    tty.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL);
    tty.c_oflag &= ~OPOST;

    /* Non-blocking read: return immediately */
    tty.c_cc[VMIN]  = 0;
    tty.c_cc[VTIME] = 0;

    if (tcsetattr(fd, TCSANOW, &tty) != 0) {
        ::close(fd);
        return -1;
    }

    return fd;
}

static int linux_uart_read(int fd, uint8_t* buf, size_t len) {
    ssize_t n = ::read(fd, buf, len);
    return static_cast<int>(n);
}

static int linux_uart_write(int fd, const uint8_t* buf, size_t len) {
    ssize_t n = ::write(fd, buf, len);
    return static_cast<int>(n);
}

static void linux_uart_close(int fd) {
    ::close(fd);
}

/* ── Factory ───────────────────────────────────────────────────────── */

UartPlatform uart_platform_default() {
    return UartPlatform{
        linux_uart_open,
        linux_uart_read,
        linux_uart_write,
        linux_uart_close
    };
}

#endif /* !_WIN32 */
