#ifndef MOCK_PWM_PLATFORM_H
#define MOCK_PWM_PLATFORM_H

#include <cstdint>
#include <cstdbool>

/**
 * Mock PWM platform layer for testing.
 *
 * Stores last set period, duty, and enable state.
 * Header-only with static state for simplicity in tests.
 */

struct PwmPlatform {
    int  (*open)(uint8_t chip, uint8_t channel);
    int  (*set_period)(int fd, uint32_t period_ns);
    int  (*set_duty)(int fd, uint32_t duty_ns);
    int  (*enable)(int fd, bool on);
    void (*close)(int fd);
};

struct MockPwmState {
    // Configurable return values
    int open_return_fd = 7;
    int set_period_return = 0;
    int set_duty_return = 0;
    int enable_return = 0;

    // Recorded call arguments
    bool open_called = false;
    uint8_t last_open_chip = 0;
    uint8_t last_open_channel = 0;

    bool set_period_called = false;
    int last_set_period_fd = -1;
    uint32_t last_period_ns = 0;

    bool set_duty_called = false;
    int last_set_duty_fd = -1;
    uint32_t last_duty_ns = 0;

    bool enable_called = false;
    int last_enable_fd = -1;
    bool last_enable_on = false;

    bool close_called = false;
    int last_close_fd = -1;

    void reset() {
        open_return_fd = 7;
        set_period_return = 0;
        set_duty_return = 0;
        enable_return = 0;
        open_called = false;
        last_open_chip = 0;
        last_open_channel = 0;
        set_period_called = false;
        last_set_period_fd = -1;
        last_period_ns = 0;
        set_duty_called = false;
        last_set_duty_fd = -1;
        last_duty_ns = 0;
        enable_called = false;
        last_enable_fd = -1;
        last_enable_on = false;
        close_called = false;
        last_close_fd = -1;
    }
};

inline MockPwmState g_mock_pwm;

inline int mock_pwm_open(uint8_t chip, uint8_t channel) {
    g_mock_pwm.open_called = true;
    g_mock_pwm.last_open_chip = chip;
    g_mock_pwm.last_open_channel = channel;
    return g_mock_pwm.open_return_fd;
}

inline int mock_pwm_set_period(int fd, uint32_t period_ns) {
    g_mock_pwm.set_period_called = true;
    g_mock_pwm.last_set_period_fd = fd;
    g_mock_pwm.last_period_ns = period_ns;
    return g_mock_pwm.set_period_return;
}

inline int mock_pwm_set_duty(int fd, uint32_t duty_ns) {
    g_mock_pwm.set_duty_called = true;
    g_mock_pwm.last_set_duty_fd = fd;
    g_mock_pwm.last_duty_ns = duty_ns;
    return g_mock_pwm.set_duty_return;
}

inline int mock_pwm_enable(int fd, bool on) {
    g_mock_pwm.enable_called = true;
    g_mock_pwm.last_enable_fd = fd;
    g_mock_pwm.last_enable_on = on;
    return g_mock_pwm.enable_return;
}

inline void mock_pwm_close(int fd) {
    g_mock_pwm.close_called = true;
    g_mock_pwm.last_close_fd = fd;
}

inline PwmPlatform make_mock_pwm_platform() {
    return PwmPlatform{
        mock_pwm_open,
        mock_pwm_set_period,
        mock_pwm_set_duty,
        mock_pwm_enable,
        mock_pwm_close
    };
}

#endif /* MOCK_PWM_PLATFORM_H */
