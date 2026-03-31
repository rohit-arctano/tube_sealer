#include "log_handler.h"
#include "ring_buffer.h"

#include <cstdarg>
#include <cstdio>
#include <cstring>
#include <atomic>

#ifdef _WIN32
#include <windows.h>
#include <mutex>
#else
#include <pthread.h>
#include <time.h>
#endif

/* ── Internal state (file-scoped) ──────────────────────────────────── */

static std::atomic<TsnLogLevel> s_min_level{TSN_LOG_ERROR};
static TsnLogOutput             s_output = TSN_LOG_OUTPUT_STDERR;
static FILE*                    s_file   = nullptr;
static bool                     s_initialized = false;

static tsn::RingBuffer<TsnEvent, 256> s_log_ring;

/* UART buffer: formatted log lines stored here for later UART transmission */
static constexpr size_t UART_BUF_SIZE = 4096;
static char    s_uart_buf[UART_BUF_SIZE];
static size_t  s_uart_buf_len = 0;

#ifdef _WIN32
static std::mutex s_mutex;
static LARGE_INTEGER s_qpc_freq;
static LARGE_INTEGER s_qpc_start;
#else
static pthread_mutex_t s_mutex = PTHREAD_MUTEX_INITIALIZER;
#endif

/* ── Helpers ───────────────────────────────────────────────────────── */

static const char* level_str(TsnLogLevel level) {
    switch (level) {
        case TSN_LOG_ERROR: return "ERROR";
        case TSN_LOG_WARN:  return "WARN";
        case TSN_LOG_INFO:  return "INFO";
        case TSN_LOG_DEBUG: return "DEBUG";
        default:            return "???";
    }
}

static uint64_t timestamp_ms() {
#ifdef _WIN32
    LARGE_INTEGER now;
    QueryPerformanceCounter(&now);
    return static_cast<uint64_t>(
        (now.QuadPart - s_qpc_start.QuadPart) * 1000 / s_qpc_freq.QuadPart);
#else
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return static_cast<uint64_t>(ts.tv_sec) * 1000 +
           static_cast<uint64_t>(ts.tv_nsec) / 1000000;
#endif
}

static void lock() {
#ifdef _WIN32
    s_mutex.lock();
#else
    pthread_mutex_lock(&s_mutex);
#endif
}

static void unlock() {
#ifdef _WIN32
    s_mutex.unlock();
#else
    pthread_mutex_unlock(&s_mutex);
#endif
}

/* ── Public API ────────────────────────────────────────────────────── */

extern "C" void tsn_log_init(TsnLogLevel min_level, TsnLogOutput output, const char* file_path) {
    lock();

    s_min_level.store(min_level, std::memory_order_relaxed);
    s_output = output;

    /* Close any previously opened file */
    if (s_file) {
        fclose(s_file);
        s_file = nullptr;
    }

    if (output == TSN_LOG_OUTPUT_FILE && file_path && file_path[0] != '\0') {
        s_file = fopen(file_path, "a");
    }

#ifdef _WIN32
    QueryPerformanceFrequency(&s_qpc_freq);
    QueryPerformanceCounter(&s_qpc_start);
#endif

    s_uart_buf_len = 0;
    s_initialized = true;

    unlock();
}

extern "C" void tsn_log(TsnLogLevel level, const char* component, const char* fmt, ...) {
    /* Fast path: check level without locking */
    if (level > s_min_level.load(std::memory_order_relaxed)) {
        return;
    }

    /* Format the user message */
    char msg[512];
    va_list args;
    va_start(args, fmt);
    vsnprintf(msg, sizeof(msg), fmt, args);
    va_end(args);

    uint64_t ts = timestamp_ms();

    /* Build the full log line */
    char line[640];
    int len = snprintf(line, sizeof(line), "[%llu] [%s] [%s] %s\n",
                       (unsigned long long)ts, level_str(level),
                       component ? component : "?", msg);
    if (len < 0) len = 0;
    if (static_cast<size_t>(len) >= sizeof(line)) len = sizeof(line) - 1;

    lock();

    switch (s_output) {
        case TSN_LOG_OUTPUT_STDERR:
            fputs(line, stderr);
            break;

        case TSN_LOG_OUTPUT_FILE:
            if (s_file) {
                fputs(line, s_file);
                fflush(s_file);
            }
            break;

        case TSN_LOG_OUTPUT_RINGBUF: {
            TsnEvent ev{};
            ev.type = TSN_EVENT_LOG;
            ev.timestamp = ts * 1000000ULL; /* convert ms → ns */
            ev.payload.log.level = static_cast<uint8_t>(level);
            strncpy(ev.payload.log.component, component ? component : "?",
                    sizeof(ev.payload.log.component) - 1);
            ev.payload.log.component[sizeof(ev.payload.log.component) - 1] = '\0';
            strncpy(ev.payload.log.msg, msg, sizeof(ev.payload.log.msg) - 1);
            ev.payload.log.msg[sizeof(ev.payload.log.msg) - 1] = '\0';
            s_log_ring.push(ev);
            break;
        }

        case TSN_LOG_OUTPUT_UART: {
            /* Store formatted line in UART buffer for later transmission */
            size_t line_len = static_cast<size_t>(len);
            if (s_uart_buf_len + line_len < UART_BUF_SIZE) {
                memcpy(s_uart_buf + s_uart_buf_len, line, line_len);
                s_uart_buf_len += line_len;
            }
            /* If buffer is full, silently drop (UART send will drain it) */
            break;
        }
    }

    unlock();
}

extern "C" void tsn_log_set_level(TsnLogLevel level) {
    s_min_level.store(level, std::memory_order_relaxed);
}

tsn::RingBuffer<TsnEvent, 256>* tsn_log_get_ring(void) {
    if (s_output == TSN_LOG_OUTPUT_RINGBUF) {
        return &s_log_ring;
    }
    return nullptr;
}

extern "C" void tsn_log_shutdown(void) {
    lock();

    if (s_file) {
        fflush(s_file);
        fclose(s_file);
        s_file = nullptr;
    }

    s_uart_buf_len = 0;
    s_initialized = false;

    unlock();
}
