#ifndef TUBE_SEALER_NATIVE_H
#define TUBE_SEALER_NATIVE_H

#include <stdint.h>
#include <stdbool.h>

#ifdef _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* ── Opaque context handle ─────────────────────────────────────────── */
typedef struct TsnContext TsnContext;

/* ── Status codes ──────────────────────────────────────────────────── */
typedef enum {
    TSN_OK                          =  0,
    TSN_ERR_INVALID_HANDLE          = -1,
    TSN_ERR_ALREADY_INITIALIZED     = -2,
    TSN_ERR_INIT_FAILED             = -3,
    TSN_ERR_PERIPHERAL_FAULT        = -4,
    TSN_ERR_SYSTEM_HALTED           = -5,
    TSN_ERR_INVALID_STATE_TRANSITION = -6,
    TSN_ERR_INVALID_PARAM           = -7,
    TSN_ERR_IO                      = -8,
    TSN_ERR_BUS                     = -9,
    TSN_ERR_NACK                    = -10,
    TSN_ERR_TIMEOUT                 = -11,
    TSN_ERR_PWM_UNAVAILABLE         = -12,
    TSN_ERR_ADC_OUT_OF_RANGE        = -13,
} TsnStatus;

/* ── Event types ───────────────────────────────────────────────────── */
typedef enum {
    TSN_EVENT_TEMP_READING     = 1,
    TSN_EVENT_TEMP_ALERT       = 2,
    TSN_EVENT_GPIO_CHANGE      = 3,
    TSN_EVENT_SENSOR_FAULT     = 4,
    TSN_EVENT_SAFETY_EMERGENCY = 5,
    TSN_EVENT_LOG              = 6,
} TsnEventType;

/* ── Log levels and outputs ────────────────────────────────────────── */
typedef enum {
    TSN_LOG_ERROR = 0,
    TSN_LOG_WARN  = 1,
    TSN_LOG_INFO  = 2,
    TSN_LOG_DEBUG = 3,
} TsnLogLevel;

typedef enum {
    TSN_LOG_OUTPUT_STDERR  = 0,
    TSN_LOG_OUTPUT_FILE    = 1,
    TSN_LOG_OUTPUT_RINGBUF = 2,
    TSN_LOG_OUTPUT_UART    = 3,
} TsnLogOutput;

/* ── Machine states ────────────────────────────────────────────────── */
typedef enum {
    TSN_STATE_IDLE      = 0,
    TSN_STATE_PREHEAT   = 1,
    TSN_STATE_SEAL      = 2,
    TSN_STATE_COOL_DOWN = 3,
    TSN_STATE_COMPLETE  = 4,
    TSN_STATE_FAULT     = 5,
} TsnMachineState;

/* ── Event struct ──────────────────────────────────────────────────── */
typedef struct {
    uint8_t  type;       /* TsnEventType */
    uint64_t sequence;   /* monotonic sequence number */
    uint64_t timestamp;  /* nanoseconds from CLOCK_MONOTONIC */
    union {
        struct { uint8_t sensor_id; float temp_c; float threshold; } temp;
        struct { uint16_t pin; uint8_t value; uint8_t edge; }        gpio;
        struct { uint8_t sensor_id; uint8_t fault_code; }            sensor_fault;
        struct { uint8_t reason; }                                   safety;
        struct { uint8_t level; char component[16]; char msg[128]; } log;
    } payload;
} TsnEvent;

#define TSN_MAX_BATCH_EVENTS 128

typedef struct {
    uint32_t total_count;
    uint32_t temp_count;
    uint32_t gpio_count;
    uint32_t other_count;
    uint64_t dropped_total;
    TsnEvent events[TSN_MAX_BATCH_EVENTS];
} TsnEventBatch;

/* ── Configuration structs ─────────────────────────────────────────── */
typedef struct {
    char     device_path[64];
    uint32_t baud_rate;
    uint8_t  data_bits;     /* 5-8 */
    uint8_t  stop_bits;     /* 1-2 */
    uint8_t  parity;        /* 0=none, 1=odd, 2=even */
    uint8_t  flow_control;  /* 0=none, 1=hw, 2=sw */
} TsnUartConfig;

typedef struct {
    uint8_t bus_number;
    uint8_t device_address;
} TsnI2cConfig;

typedef struct {
    uint8_t  bus_number;
    uint8_t  chip_select;
    uint32_t clock_hz;
    uint8_t  mode;  /* 0-3 */
} TsnSpiConfig;

typedef struct {
    uint8_t  chip_type;      /* 0=ADS1115 (I2C), 1=MCP3008 (SPI) */
    uint8_t  channel;
    /* I2C config (used when chip_type=0) */
    uint8_t  i2c_bus;
    uint8_t  i2c_address;
    /* SPI config (used when chip_type=1) */
    uint8_t  spi_bus;
    uint8_t  spi_cs;
    uint32_t spi_clock_hz;
} TsnAdcConfig;

typedef struct {
    uint16_t pin;
    uint8_t  direction;  /* 0=input, 1=output */
    uint8_t  edge;       /* 0=none, 1=rising, 2=falling, 3=both */
} TsnGpioPin;

typedef struct {
    uint8_t  chip;
    uint8_t  channel;
    uint32_t frequency_hz;
    float    duty_cycle;  /* 0.0 - 1.0 */
} TsnPwmConfig;

typedef struct {
    float    high_threshold_c;
    float    low_threshold_c;
    uint32_t sample_interval_ms;
    uint32_t overtemp_timeout_ms;
} TsnTempConfig;

typedef struct {
    uint16_t estop_pin;
    uint32_t watchdog_timeout_ms;
} TsnSafetyConfig;

typedef struct {
    TsnUartConfig   uart;
    TsnI2cConfig    i2c;
    TsnSpiConfig    spi;
    TsnAdcConfig    adc;
    TsnGpioPin      gpio_pins[32];
    uint8_t         gpio_pin_count;
    TsnPwmConfig    pwm[8];
    uint8_t         pwm_count;
    TsnTempConfig   temp;
    TsnSafetyConfig safety;
    TsnLogLevel     log_level;
    TsnLogOutput    log_output;
    char            log_file_path[128];
} TsnConfig;

/* ── Result / reading structs ──────────────────────────────────────── */
typedef struct {
    TsnStatus status;
    uint32_t  peripheral_bitmask;  /* bit per peripheral: 1=ok, 0=failed */
} TsnInitResult;

typedef struct {
    float   temp_c;
    int32_t raw_value;
    float   scale_factor;
} TsnAdcReading;

typedef struct {
    bool    halted;
    bool    overtemp;
    bool    estop_active;
    bool    watchdog_expired;
    uint8_t fault_count;
} TsnSafetyStatus;

/* ── Lifecycle ─────────────────────────────────────────────────────── */
FFI_PLUGIN_EXPORT TsnInitResult tsn_init(const TsnConfig* config);
FFI_PLUGIN_EXPORT TsnStatus     tsn_shutdown(TsnContext* ctx);
FFI_PLUGIN_EXPORT TsnContext*    tsn_get_context(void);

/* ── Event polling ─────────────────────────────────────────────────── */
FFI_PLUGIN_EXPORT TsnStatus     tsn_poll_events(TsnContext* ctx, TsnEventBatch* out_batch);

/* ── UART ──────────────────────────────────────────────────────────── */
FFI_PLUGIN_EXPORT TsnStatus     tsn_uart_send(TsnContext* ctx, const uint8_t* data, uint32_t len, uint32_t* bytes_written);

/* ── I2C ───────────────────────────────────────────────────────────── */
FFI_PLUGIN_EXPORT TsnStatus     tsn_i2c_read(TsnContext* ctx, uint8_t addr, uint8_t reg, uint8_t* buf, uint32_t len);
FFI_PLUGIN_EXPORT TsnStatus     tsn_i2c_write(TsnContext* ctx, uint8_t addr, uint8_t reg, const uint8_t* data, uint32_t len);

/* ── SPI ───────────────────────────────────────────────────────────── */
FFI_PLUGIN_EXPORT TsnStatus     tsn_spi_transfer(TsnContext* ctx, const uint8_t* tx, uint8_t* rx, uint32_t len);

/* ── ADC ───────────────────────────────────────────────────────────── */
FFI_PLUGIN_EXPORT TsnStatus     tsn_adc_read(TsnContext* ctx, uint8_t channel, TsnAdcReading* out);

/* ── GPIO ──────────────────────────────────────────────────────────── */
FFI_PLUGIN_EXPORT TsnStatus     tsn_gpio_write(TsnContext* ctx, uint16_t pin, uint8_t value);
FFI_PLUGIN_EXPORT TsnStatus     tsn_gpio_read(TsnContext* ctx, uint16_t pin, uint8_t* out_value);

/* ── PWM ───────────────────────────────────────────────────────────── */
FFI_PLUGIN_EXPORT TsnStatus     tsn_pwm_set_duty(TsnContext* ctx, uint8_t channel, float duty_cycle);
FFI_PLUGIN_EXPORT TsnStatus     tsn_pwm_set_freq(TsnContext* ctx, uint8_t channel, uint32_t freq_hz);
FFI_PLUGIN_EXPORT TsnStatus     tsn_pwm_disable(TsnContext* ctx, uint8_t channel);

/* ── Machine controller ────────────────────────────────────────────── */
FFI_PLUGIN_EXPORT TsnStatus     tsn_mc_transition(TsnContext* ctx, TsnMachineState target_state);
FFI_PLUGIN_EXPORT TsnStatus     tsn_mc_get_state(TsnContext* ctx, TsnMachineState* out_state);

/* ── Safety ────────────────────────────────────────────────────────── */
FFI_PLUGIN_EXPORT TsnStatus     tsn_safety_refresh_watchdog(TsnContext* ctx);
FFI_PLUGIN_EXPORT TsnStatus     tsn_safety_get_status(TsnContext* ctx, TsnSafetyStatus* out);

/* ── Logging ───────────────────────────────────────────────────────── */
FFI_PLUGIN_EXPORT TsnStatus     tsn_set_log_level(TsnContext* ctx, TsnLogLevel level);

#ifdef __cplusplus
}  /* extern "C" */
#endif

#endif /* TUBE_SEALER_NATIVE_H */
