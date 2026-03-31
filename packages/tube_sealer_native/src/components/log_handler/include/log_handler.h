#ifndef TSN_LOG_HANDLER_H
#define TSN_LOG_HANDLER_H

#include "tube_sealer_native.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Initialize the log handler.
 *
 * @param min_level  Minimum severity level; messages below this are suppressed.
 * @param output     Output destination (stderr, file, ring buffer, UART).
 * @param file_path  Path to log file (used only when output == TSN_LOG_OUTPUT_FILE; may be NULL otherwise).
 */
void tsn_log_init(TsnLogLevel min_level, TsnLogOutput output, const char* file_path);

/**
 * Log a formatted message.
 *
 * Thread-safe. Format: "[timestamp_ms] [LEVEL] [component] message\n"
 *
 * @param level      Severity of this message.
 * @param component  Short component name (e.g. "uart", "gpio").
 * @param fmt        printf-style format string.
 */
void tsn_log(TsnLogLevel level, const char* component, const char* fmt, ...);

/**
 * Change the minimum log level at runtime.
 */
void tsn_log_set_level(TsnLogLevel level);

/**
 * Shut down the log handler, flushing and closing any open file.
 */
void tsn_log_shutdown(void);

#ifdef __cplusplus
}  /* extern "C" */

/* C++-only API — not exposed across FFI boundary */
#include "ring_buffer.h"

/**
 * Get a pointer to the internal log ring buffer.
 * Returns nullptr if the output mode is not TSN_LOG_OUTPUT_RINGBUF.
 */
tsn::RingBuffer<TsnEvent, 256>* tsn_log_get_ring(void);

#endif /* __cplusplus */

#endif /* TSN_LOG_HANDLER_H */
