#include "tube_sealer_native.h"

// Stub implementations — will be replaced by hw_manager integration in Task 8.2.
// These exist so the shared library compiles and links during incremental development.

static TsnContext* g_context = nullptr;

FFI_PLUGIN_EXPORT TsnInitResult tsn_init(const TsnConfig* config) {
    TsnInitResult result = {};
    result.status = TSN_ERR_INIT_FAILED;
    result.peripheral_bitmask = 0;
    return result;
}

FFI_PLUGIN_EXPORT TsnStatus tsn_shutdown(TsnContext* ctx) {
    return TSN_ERR_INVALID_HANDLE;
}

FFI_PLUGIN_EXPORT TsnContext* tsn_get_context(void) {
    return g_context;
}

FFI_PLUGIN_EXPORT TsnStatus tsn_poll_events(TsnContext* ctx, TsnEventBatch* out_batch) {
    return TSN_ERR_INVALID_HANDLE;
}

FFI_PLUGIN_EXPORT TsnStatus tsn_uart_send(TsnContext* ctx, const uint8_t* data, uint32_t len, uint32_t* bytes_written) {
    return TSN_ERR_INVALID_HANDLE;
}

FFI_PLUGIN_EXPORT TsnStatus tsn_i2c_read(TsnContext* ctx, uint8_t addr, uint8_t reg, uint8_t* buf, uint32_t len) {
    return TSN_ERR_INVALID_HANDLE;
}

FFI_PLUGIN_EXPORT TsnStatus tsn_i2c_write(TsnContext* ctx, uint8_t addr, uint8_t reg, const uint8_t* data, uint32_t len) {
    return TSN_ERR_INVALID_HANDLE;
}

FFI_PLUGIN_EXPORT TsnStatus tsn_spi_transfer(TsnContext* ctx, const uint8_t* tx, uint8_t* rx, uint32_t len) {
    return TSN_ERR_INVALID_HANDLE;
}

FFI_PLUGIN_EXPORT TsnStatus tsn_adc_read(TsnContext* ctx, uint8_t channel, TsnAdcReading* out) {
    return TSN_ERR_INVALID_HANDLE;
}

FFI_PLUGIN_EXPORT TsnStatus tsn_gpio_write(TsnContext* ctx, uint16_t pin, uint8_t value) {
    return TSN_ERR_INVALID_HANDLE;
}

FFI_PLUGIN_EXPORT TsnStatus tsn_gpio_read(TsnContext* ctx, uint16_t pin, uint8_t* out_value) {
    return TSN_ERR_INVALID_HANDLE;
}

FFI_PLUGIN_EXPORT TsnStatus tsn_pwm_set_duty(TsnContext* ctx, uint8_t channel, float duty_cycle) {
    return TSN_ERR_INVALID_HANDLE;
}

FFI_PLUGIN_EXPORT TsnStatus tsn_pwm_set_freq(TsnContext* ctx, uint8_t channel, uint32_t freq_hz) {
    return TSN_ERR_INVALID_HANDLE;
}

FFI_PLUGIN_EXPORT TsnStatus tsn_pwm_disable(TsnContext* ctx, uint8_t channel) {
    return TSN_ERR_INVALID_HANDLE;
}

FFI_PLUGIN_EXPORT TsnStatus tsn_mc_transition(TsnContext* ctx, TsnMachineState target_state) {
    return TSN_ERR_INVALID_HANDLE;
}

FFI_PLUGIN_EXPORT TsnStatus tsn_mc_get_state(TsnContext* ctx, TsnMachineState* out_state) {
    return TSN_ERR_INVALID_HANDLE;
}

FFI_PLUGIN_EXPORT TsnStatus tsn_safety_refresh_watchdog(TsnContext* ctx) {
    return TSN_ERR_INVALID_HANDLE;
}

FFI_PLUGIN_EXPORT TsnStatus tsn_safety_get_status(TsnContext* ctx, TsnSafetyStatus* out) {
    return TSN_ERR_INVALID_HANDLE;
}

FFI_PLUGIN_EXPORT TsnStatus tsn_set_log_level(TsnContext* ctx, TsnLogLevel level) {
    return TSN_ERR_INVALID_HANDLE;
}
