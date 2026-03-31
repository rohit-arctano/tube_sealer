#ifndef TSN_UART_MANAGER_H
#define TSN_UART_MANAGER_H

#include "uart_platform.h"
#include "uart_types.h"
#include "tube_sealer_native.h"

#include <atomic>
#include <cstdint>

#ifdef _WIN32
#include <mutex>
#else
#include <pthread.h>
#endif

/**
 * UART manager — TX-only serial output for logs, reports, and machine details.
 *
 * All public methods are thread-safe. TX writes are serialized with a mutex
 * so multiple callers (log handler, report sender, etc.) don't interleave.
 */
class UartManager {
public:
    UartManager();
    ~UartManager();

    // Non-copyable, non-movable
    UartManager(const UartManager&) = delete;
    UartManager& operator=(const UartManager&) = delete;
    UartManager(UartManager&&) = delete;
    UartManager& operator=(UartManager&&) = delete;

    /**
     * Open the serial device and store the platform vtable.
     * Sets fault flag on failure.
     */
    TsnStatus init(const UartConfig& cfg, const UartPlatform& platform);

    /**
     * Write raw bytes to the serial device.
     * @param data   Pointer to byte buffer.
     * @param len    Number of bytes to write.
     * @param written  Out-param: number of bytes actually written.
     * @return TSN_OK on success, TSN_ERR_IO on write failure,
     *         TSN_ERR_PERIPHERAL_FAULT if not initialized or faulted.
     */
    TsnStatus send(const uint8_t* data, uint32_t len, uint32_t* written);

    /**
     * Convenience: send a null-terminated log string (including the '\0').
     */
    TsnStatus send_log(const char* log_entry);

    /**
     * Send binary report data.
     */
    TsnStatus send_report(const uint8_t* data, uint32_t len);

    /**
     * Close the serial device.
     */
    void stop();

    /**
     * Returns true if the peripheral has encountered a fault.
     */
    bool has_fault() const;

private:
    UartPlatform platform_{};
    int fd_ = -1;
    std::atomic<bool> fault_flag_{false};
    bool initialized_ = false;

#ifdef _WIN32
    std::mutex tx_mutex_;
#else
    pthread_mutex_t tx_mutex_;
#endif

    void lock();
    void unlock();
};

#endif /* TSN_UART_MANAGER_H */
