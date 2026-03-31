#ifndef TSN_I2C_MANAGER_H
#define TSN_I2C_MANAGER_H

#include "i2c_platform.h"
#include "i2c_types.h"
#include "tube_sealer_native.h"

#include <atomic>
#include <cstdint>

#ifdef _WIN32
#include <mutex>
#else
#include <pthread.h>
#endif

/**
 * I2C manager — register-level read/write over I2C bus.
 *
 * All public methods are thread-safe. Bus operations are serialized
 * with a mutex so multiple callers don't interleave transactions.
 */
class I2cManager {
public:
    I2cManager();
    ~I2cManager();

    // Non-copyable, non-movable
    I2cManager(const I2cManager&) = delete;
    I2cManager& operator=(const I2cManager&) = delete;
    I2cManager(I2cManager&&) = delete;
    I2cManager& operator=(I2cManager&&) = delete;

    /**
     * Open the I2C bus device and store the platform vtable.
     * Sets fault flag on failure.
     */
    TsnStatus init(const I2cConfig& cfg, const I2cPlatform& platform);

    /**
     * Read data from a specific register on the configured device.
     * Performs: set_address → write register byte → read data.
     * @param reg  Register address to read from.
     * @param buf  Output buffer for read data.
     * @param len  Number of bytes to read.
     * @return TSN_OK on success, TSN_ERR_BUS/TSN_ERR_NACK on I2C errors.
     */
    TsnStatus read_register(uint8_t reg, uint8_t* buf, uint32_t len);

    /**
     * Write data to a specific register on the configured device.
     * Performs: set_address → write [register byte + data].
     * @param reg   Register address to write to.
     * @param data  Data bytes to write.
     * @param len   Number of data bytes.
     * @return TSN_OK on success, TSN_ERR_BUS/TSN_ERR_NACK on I2C errors.
     */
    TsnStatus write_register(uint8_t reg, const uint8_t* data, uint32_t len);

    /**
     * Close the I2C bus device.
     */
    void stop();

    /**
     * Returns true if the peripheral has encountered a fault.
     */
    bool has_fault() const;

private:
    I2cPlatform platform_{};
    I2cConfig config_{};
    int fd_ = -1;
    std::atomic<bool> fault_flag_{false};
    bool initialized_ = false;

#ifdef _WIN32
    std::mutex bus_mutex_;
#else
    pthread_mutex_t bus_mutex_;
#endif

    void lock();
    void unlock();
};

#endif /* TSN_I2C_MANAGER_H */
