#ifndef TSN_UART_TYPES_H
#define TSN_UART_TYPES_H

#include <cstdint>

/**
 * UART configuration parameters.
 *
 * Matches the layout of TsnUartConfig in tube_sealer_native.h
 * but lives here so the component can be used independently.
 */
struct UartConfig {
    char     device_path[64];
    uint32_t baud_rate;
    uint8_t  data_bits;     /* 5-8 */
    uint8_t  stop_bits;     /* 1-2 */
    uint8_t  parity;        /* 0=none, 1=odd, 2=even */
    uint8_t  flow_control;  /* 0=none, 1=hw, 2=sw */
};

#endif /* TSN_UART_TYPES_H */
