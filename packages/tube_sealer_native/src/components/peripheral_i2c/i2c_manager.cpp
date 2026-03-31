#include "i2c_manager.h"
#include "log_handler.h"

#include <cstring>
#include <vector>

/* ── Constructor / Destructor ──────────────────────────────────────── */

I2cManager::I2cManager() {
#ifndef _WIN32
    pthread_mutex_init(&bus_mutex_, nullptr);
#endif
}

I2cManager::~I2cManager() {
    stop();
#ifndef _WIN32
    pthread_mutex_destroy(&bus_mutex_);
#endif
}

/* ── Lock helpers ──────────────────────────────────────────────────── */

void I2cManager::lock() {
#ifdef _WIN32
    bus_mutex_.lock();
#else
    pthread_mutex_lock(&bus_mutex_);
#endif
}

void I2cManager::unlock() {
#ifdef _WIN32
    bus_mutex_.unlock();
#else
    pthread_mutex_unlock(&bus_mutex_);
#endif
}

/* ── Public API ────────────────────────────────────────────────────── */

TsnStatus I2cManager::init(const I2cConfig& cfg, const I2cPlatform& platform) {
    lock();

    if (initialized_) {
        unlock();
        return TSN_ERR_ALREADY_INITIALIZED;
    }

    platform_ = platform;
    config_ = cfg;

    int fd = platform_.open(cfg.bus_number);
    if (fd < 0) {
        fault_flag_.store(true, std::memory_order_relaxed);
        tsn_log(TSN_LOG_ERROR, "i2c", "failed to open bus %u", cfg.bus_number);
        initialized_ = false;
        unlock();
        return TSN_ERR_IO;
    }

    fd_ = fd;
    fault_flag_.store(false, std::memory_order_relaxed);
    initialized_ = true;

    tsn_log(TSN_LOG_INFO, "i2c", "opened bus=%u fd=%d addr=0x%02X",
            cfg.bus_number, fd_, cfg.device_address);

    unlock();
    return TSN_OK;
}

TsnStatus I2cManager::read_register(uint8_t reg, uint8_t* buf, uint32_t len) {
    if (!buf && len > 0) return TSN_ERR_INVALID_PARAM;

    lock();

    if (!initialized_ || fd_ < 0) {
        unlock();
        return TSN_ERR_PERIPHERAL_FAULT;
    }

    if (fault_flag_.load(std::memory_order_relaxed)) {
        unlock();
        return TSN_ERR_PERIPHERAL_FAULT;
    }

    // Set slave address
    int ret = platform_.set_address(fd_, config_.device_address);
    if (ret < 0) {
        fault_flag_.store(true, std::memory_order_relaxed);
        tsn_log(TSN_LOG_ERROR, "i2c", "set_address failed fd=%d addr=0x%02X",
                fd_, config_.device_address);
        unlock();
        return TSN_ERR_NACK;
    }

    // Write register byte
    ret = platform_.write(fd_, &reg, 1);
    if (ret < 0) {
        fault_flag_.store(true, std::memory_order_relaxed);
        tsn_log(TSN_LOG_ERROR, "i2c", "write reg 0x%02X failed fd=%d", reg, fd_);
        unlock();
        return TSN_ERR_BUS;
    }

    // Read data
    ret = platform_.read(fd_, buf, static_cast<size_t>(len));
    if (ret < 0) {
        fault_flag_.store(true, std::memory_order_relaxed);
        tsn_log(TSN_LOG_ERROR, "i2c", "read failed fd=%d reg=0x%02X len=%u",
                fd_, reg, len);
        unlock();
        return TSN_ERR_BUS;
    }

    unlock();
    return TSN_OK;
}

TsnStatus I2cManager::write_register(uint8_t reg, const uint8_t* data, uint32_t len) {
    if (!data && len > 0) return TSN_ERR_INVALID_PARAM;

    lock();

    if (!initialized_ || fd_ < 0) {
        unlock();
        return TSN_ERR_PERIPHERAL_FAULT;
    }

    if (fault_flag_.load(std::memory_order_relaxed)) {
        unlock();
        return TSN_ERR_PERIPHERAL_FAULT;
    }

    // Set slave address
    int ret = platform_.set_address(fd_, config_.device_address);
    if (ret < 0) {
        fault_flag_.store(true, std::memory_order_relaxed);
        tsn_log(TSN_LOG_ERROR, "i2c", "set_address failed fd=%d addr=0x%02X",
                fd_, config_.device_address);
        unlock();
        return TSN_ERR_NACK;
    }

    // Build buffer: [register byte] + [data bytes]
    std::vector<uint8_t> write_buf;
    write_buf.reserve(1 + len);
    write_buf.push_back(reg);
    if (data && len > 0) {
        write_buf.insert(write_buf.end(), data, data + len);
    }

    ret = platform_.write(fd_, write_buf.data(), write_buf.size());
    if (ret < 0) {
        fault_flag_.store(true, std::memory_order_relaxed);
        tsn_log(TSN_LOG_ERROR, "i2c", "write failed fd=%d reg=0x%02X len=%u",
                fd_, reg, len);
        unlock();
        return TSN_ERR_BUS;
    }

    unlock();
    return TSN_OK;
}

void I2cManager::stop() {
    lock();

    if (initialized_ && fd_ >= 0) {
        platform_.close(fd_);
        tsn_log(TSN_LOG_INFO, "i2c", "closed fd=%d", fd_);
        fd_ = -1;
    }
    initialized_ = false;

    unlock();
}

bool I2cManager::has_fault() const {
    return fault_flag_.load(std::memory_order_relaxed);
}
