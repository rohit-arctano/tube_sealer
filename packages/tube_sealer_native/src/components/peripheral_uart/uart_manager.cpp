#include "uart_manager.h"
#include "log_handler.h"

#include <cstring>

/* ── Constructor / Destructor ──────────────────────────────────────── */

UartManager::UartManager() {
#ifndef _WIN32
    pthread_mutex_init(&tx_mutex_, nullptr);
#endif
}

UartManager::~UartManager() {
    stop();
#ifndef _WIN32
    pthread_mutex_destroy(&tx_mutex_);
#endif
}

/* ── Lock helpers ──────────────────────────────────────────────────── */

void UartManager::lock() {
#ifdef _WIN32
    tx_mutex_.lock();
#else
    pthread_mutex_lock(&tx_mutex_);
#endif
}

void UartManager::unlock() {
#ifdef _WIN32
    tx_mutex_.unlock();
#else
    pthread_mutex_unlock(&tx_mutex_);
#endif
}

/* ── Public API ────────────────────────────────────────────────────── */

TsnStatus UartManager::init(const UartConfig& cfg, const UartPlatform& platform) {
    lock();

    if (initialized_) {
        unlock();
        return TSN_ERR_ALREADY_INITIALIZED;
    }

    platform_ = platform;

    int fd = platform_.open(&cfg);
    if (fd < 0) {
        fault_flag_.store(true, std::memory_order_relaxed);
        tsn_log(TSN_LOG_ERROR, "uart", "failed to open %s", cfg.device_path);
        initialized_ = false;
        unlock();
        return TSN_ERR_IO;
    }

    fd_ = fd;
    fault_flag_.store(false, std::memory_order_relaxed);
    initialized_ = true;

    tsn_log(TSN_LOG_INFO, "uart", "opened %s fd=%d baud=%u",
            cfg.device_path, fd_, cfg.baud_rate);

    unlock();
    return TSN_OK;
}

TsnStatus UartManager::send(const uint8_t* data, uint32_t len, uint32_t* written) {
    if (written) *written = 0;

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

    int ret = platform_.write(fd_, data, static_cast<size_t>(len));
    if (ret < 0) {
        fault_flag_.store(true, std::memory_order_relaxed);
        tsn_log(TSN_LOG_ERROR, "uart", "write failed fd=%d len=%u", fd_, len);
        unlock();
        return TSN_ERR_IO;
    }

    if (written) *written = static_cast<uint32_t>(ret);

    unlock();
    return TSN_OK;
}

TsnStatus UartManager::send_log(const char* log_entry) {
    if (!log_entry) return TSN_ERR_INVALID_PARAM;

    size_t slen = strlen(log_entry);
    return send(reinterpret_cast<const uint8_t*>(log_entry),
                static_cast<uint32_t>(slen), nullptr);
}

TsnStatus UartManager::send_report(const uint8_t* data, uint32_t len) {
    return send(data, len, nullptr);
}

void UartManager::stop() {
    lock();

    if (initialized_ && fd_ >= 0) {
        platform_.close(fd_);
        tsn_log(TSN_LOG_INFO, "uart", "closed fd=%d", fd_);
        fd_ = -1;
    }
    initialized_ = false;

    unlock();
}

bool UartManager::has_fault() const {
    return fault_flag_.load(std::memory_order_relaxed);
}
