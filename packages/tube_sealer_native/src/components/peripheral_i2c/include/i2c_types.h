#ifndef TSN_I2C_TYPES_H
#define TSN_I2C_TYPES_H

#include <cstdint>

/**
 * I2C configuration parameters.
 *
 * Matches the layout of TsnI2cConfig in tube_sealer_native.h
 * but lives here so the component can be used independently.
 */
struct I2cConfig {
    uint8_t bus_number;
    uint8_t device_address;
};

#endif /* TSN_I2C_TYPES_H */
