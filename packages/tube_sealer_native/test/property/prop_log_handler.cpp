/**
 * Property tests for the log_handler component.
 *
 * Property 24: Log message format invariant
 * Property 25: Log level filtering
 * Property 26: Log handler thread safety
 */

#include <gtest/gtest.h>
#include <rapidcheck.h>
#include <rapidcheck/gtest.h>
#include "log_handler.h"
#include "ring_buffer.h"
#include "tube_sealer_native.h"

#include <algorithm>
#include <atomic>
#include <cstring>
#include <string>
#include <thread>
#include <vector>

/* ── Helpers ───────────────────────────────────────────────────────── */

/// Drain the static log ring buffer to clear stale data between tests.
static void drain_log_ring() {
    auto* ring = tsn_log_get_ring();
    if (ring) {
        TsnEvent discard[256];
        ring->drain(discard, 256);
    }
}

/// RapidCheck generator for TsnLogLevel values.
static rc::Gen<TsnLogLevel> genLogLevel() {
    return rc::gen::element(TSN_LOG_ERROR, TSN_LOG_WARN, TSN_LOG_INFO, TSN_LOG_DEBUG);
}

/// Generate an alphanumeric component name (1-15 chars).
static rc::Gen<std::string> genComponentName() {
    return rc::gen::container<std::string>(
        rc::gen::inRange<size_t>(1, 16),
        rc::gen::oneOf(
            rc::gen::inRange<char>('a', 'z' + 1),
            rc::gen::inRange<char>('A', 'Z' + 1),
            rc::gen::inRange<char>('0', '9' + 1)
        )
    );
}

/// Generate a printable message string (1-80 chars, no newlines).
static rc::Gen<std::string> genMessage() {
    return rc::gen::container<std::string>(
        rc::gen::inRange<size_t>(1, 81),
        rc::gen::suchThat(
            rc::gen::inRange<char>(32, 127),
            [](char c) { return c != '\n' && c != '\r'; }
        )
    );
}

/* ── Property 24: Log message format invariant ─────────────────────── */

/**
 * **Validates: Requirements 15.2**
 *
 * Property 24: Log message format invariant
 *
 * For any log level, component name, and message string, the formatted log
 * output should contain a timestamp, the log level string, the component
 * name, and the message string.
 */
RC_GTEST_PROP(LogHandlerFormat, MessageFormatInvariant, ()) {
    const auto level = *genLogLevel();
    const auto component = *genComponentName();
    const auto message = *genMessage();

    // Init with RINGBUF output at DEBUG level (accept everything)
    tsn_log_init(TSN_LOG_DEBUG, TSN_LOG_OUTPUT_RINGBUF, nullptr);
    drain_log_ring();

    tsn_log(level, component.c_str(), "%s", message.c_str());

    auto* ring = tsn_log_get_ring();
    RC_ASSERT(ring != nullptr);
    RC_ASSERT(ring->count() == 1u);

    TsnEvent ev{};
    RC_ASSERT(ring->pop(&ev));

    // 1. Event type is LOG
    RC_ASSERT(ev.type == TSN_EVENT_LOG);

    // 2. Timestamp is present (non-negative nanosecond value)
    RC_ASSERT(ev.timestamp >= 0);

    // 3. Log level matches
    RC_ASSERT(ev.payload.log.level == static_cast<uint8_t>(level));

    // 4. Component name matches (truncated to 15 chars max by the struct field)
    std::string stored_component(ev.payload.log.component);
    std::string expected_component = component.substr(0, sizeof(ev.payload.log.component) - 1);
    RC_ASSERT(stored_component == expected_component);

    // 5. Message matches (truncated to 127 chars max by the struct field)
    std::string stored_msg(ev.payload.log.msg);
    std::string expected_msg = message.substr(0, sizeof(ev.payload.log.msg) - 1);
    RC_ASSERT(stored_msg == expected_msg);

    tsn_log_shutdown();
}

/* ── Property 25: Log level filtering ──────────────────────────────── */

/**
 * **Validates: Requirements 15.4**
 *
 * Property 25: Log level filtering
 *
 * For any configured minimum log level and any log message with a given
 * severity, the message should appear in the output if and only if its
 * severity is greater than or equal to the configured minimum level.
 *
 * Log level ordering (lower numeric value = higher severity):
 *   TSN_LOG_ERROR=0, TSN_LOG_WARN=1, TSN_LOG_INFO=2, TSN_LOG_DEBUG=3
 *
 * A message appears iff message_level <= min_level.
 */
RC_GTEST_PROP(LogHandlerFilter, LogLevelFiltering, ()) {
    const auto min_level = *genLogLevel();
    const auto msg_level = *genLogLevel();

    tsn_log_init(min_level, TSN_LOG_OUTPUT_RINGBUF, nullptr);
    drain_log_ring();

    tsn_log(msg_level, "test", "filter check");

    auto* ring = tsn_log_get_ring();
    RC_ASSERT(ring != nullptr);

    // Message should appear iff msg_level <= min_level (lower = more severe)
    bool should_appear = (static_cast<int>(msg_level) <= static_cast<int>(min_level));

    if (should_appear) {
        RC_ASSERT(ring->count() == 1u);
        TsnEvent ev{};
        RC_ASSERT(ring->pop(&ev));
        RC_ASSERT(ev.payload.log.level == static_cast<uint8_t>(msg_level));
    } else {
        RC_ASSERT(ring->count() == 0u);
    }

    tsn_log_shutdown();
}

/* ── Property 26: Log handler thread safety ────────────────────────── */

/**
 * **Validates: Requirements 15.5**
 *
 * Property 26: Log handler thread safety
 *
 * For any interleaving of log calls from multiple threads, no log entry
 * should be corrupted or interleaved with another entry, and no deadlock
 * should occur.
 */
RC_GTEST_PROP(LogHandlerThreadSafety, ConcurrentLogIntegrity, ()) {
    const auto num_threads = *rc::gen::inRange<size_t>(2, 7);       // 2-6 threads
    const auto msgs_per_thread = *rc::gen::inRange<size_t>(5, 31);  // 5-30 msgs each

    tsn_log_init(TSN_LOG_DEBUG, TSN_LOG_OUTPUT_RINGBUF, nullptr);
    drain_log_ring();

    auto* ring = tsn_log_get_ring();
    RC_ASSERT(ring != nullptr);

    // Each thread logs with a unique component name so we can verify integrity
    std::vector<std::thread> threads;
    threads.reserve(num_threads);
    for (size_t t = 0; t < num_threads; ++t) {
        threads.emplace_back([t, msgs_per_thread]() {
            // Component name encodes thread id: "t0", "t1", etc.
            char comp[16];
            snprintf(comp, sizeof(comp), "t%zu", t);
            for (size_t i = 0; i < msgs_per_thread; ++i) {
                tsn_log(TSN_LOG_INFO, comp, "i=%zu", i);
            }
        });
    }

    for (auto& t : threads) {
        t.join();
    }

    // Drain all entries
    const size_t total_pushed = num_threads * msgs_per_thread;
    const size_t ring_capacity = 256;
    const size_t expected_in_ring = std::min(total_pushed, ring_capacity);
    const uint64_t expected_dropped = (total_pushed > ring_capacity)
                                        ? (total_pushed - ring_capacity) : 0;

    // Verify conservation: count + dropped == total pushed
    RC_ASSERT(ring->count() + ring->dropped_count() == total_pushed);

    std::vector<TsnEvent> events(expected_in_ring);
    size_t drained = ring->drain(events.data(), expected_in_ring);
    RC_ASSERT(drained == expected_in_ring);

    // Verify no corruption in any entry
    for (size_t i = 0; i < drained; ++i) {
        const auto& ev = events[i];

        // Type must be LOG
        RC_ASSERT(ev.type == TSN_EVENT_LOG);

        // Level must be INFO (what we logged)
        RC_ASSERT(ev.payload.log.level == static_cast<uint8_t>(TSN_LOG_INFO));

        // Component must be "tN" where N is a valid thread index
        std::string comp(ev.payload.log.component);
        RC_ASSERT(comp.size() >= 2);
        RC_ASSERT(comp[0] == 't');
        int thread_id = std::atoi(comp.c_str() + 1);
        RC_ASSERT(thread_id >= 0);
        RC_ASSERT(static_cast<size_t>(thread_id) < num_threads);

        // Message must be "i=N" where N is a valid per-thread index
        std::string msg(ev.payload.log.msg);
        RC_ASSERT(msg.substr(0, 2) == "i=");
        int iter = std::atoi(msg.c_str() + 2);
        RC_ASSERT(iter >= 0);
        RC_ASSERT(static_cast<size_t>(iter) < msgs_per_thread);
    }

    // Sequence numbers should be strictly monotonically increasing
    for (size_t i = 1; i < drained; ++i) {
        RC_ASSERT(events[i].sequence > events[i - 1].sequence);
    }

    // If we reached here, no deadlock occurred.

    tsn_log_shutdown();
}
