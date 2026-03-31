/**
 * Property test: Ring buffer overflow invariant (Property 13)
 *
 * Validates: Requirements 10.4, 10.5
 *
 * For any sequence of N pushes to a ring buffer of capacity C where N > C,
 * the dropped count should equal N − C, the buffer should contain the most
 * recent C entries, and all entries should have strictly monotonically
 * increasing sequence numbers.
 */

#include <gtest/gtest.h>
#include <rapidcheck.h>
#include <rapidcheck/gtest.h>
#include "ring_buffer.h"
#include "tube_sealer_native.h"

#include <algorithm>
#include <vector>

static constexpr size_t TEST_CAPACITY = 64;
using TestRing = tsn::RingBuffer<TsnEvent, TEST_CAPACITY>;

/// Helper: create a TsnEvent with a distinguishing temp value.
static TsnEvent make_event(float tag_value) {
    TsnEvent e{};
    e.type = TSN_EVENT_TEMP_READING;
    e.payload.temp.temp_c = tag_value;
    return e;
}

/**
 * **Validates: Requirements 10.4, 10.5**
 *
 * Property 13: Ring buffer overflow invariant
 */
RC_GTEST_PROP(RingBufferOverflow, Invariant, ()) {
    // Generate N in [1, 512] — covers both N <= C and N > C cases
    const auto n = *rc::gen::inRange<size_t>(1, 513);

    TestRing rb;

    // Build a vector of events with unique tag values so we can verify ordering
    std::vector<TsnEvent> pushed;
    pushed.reserve(n);
    for (size_t i = 0; i < n; ++i) {
        TsnEvent e = make_event(static_cast<float>(i));
        rb.push(e);
        pushed.push_back(e);
    }

    const size_t expected_count = std::min(n, TEST_CAPACITY);
    const uint64_t expected_dropped = (n > TEST_CAPACITY) ? (n - TEST_CAPACITY) : 0;

    // 1. dropped_count matches expectation
    RC_ASSERT(rb.dropped_count() == expected_dropped);

    // 2. count matches expectation
    RC_ASSERT(rb.count() == expected_count);

    // 3. Drain all entries and verify content
    std::vector<TsnEvent> drained(expected_count);
    size_t drained_count = rb.drain(drained.data(), expected_count);
    RC_ASSERT(drained_count == expected_count);

    // 4. Drained entries should correspond to the most recent min(N, C) pushed events
    size_t start_idx = n - expected_count;
    for (size_t i = 0; i < expected_count; ++i) {
        RC_ASSERT(drained[i].payload.temp.temp_c == pushed[start_idx + i].payload.temp.temp_c);
    }

    // 5. All drained entries have strictly monotonically increasing sequence numbers
    for (size_t i = 1; i < drained_count; ++i) {
        RC_ASSERT(drained[i].sequence > drained[i - 1].sequence);
    }
}

/**
 * Property test: Ring buffer concurrent access integrity (Property 14)
 *
 * Validates: Requirements 10.2
 *
 * For any interleaving of push and drain operations from multiple threads
 * on the same ring buffer, no entry should be corrupted (all fields should
 * match what was pushed), and the total of drained entries plus remaining
 * entries plus dropped count should equal the total pushed count.
 */

#include <atomic>
#include <thread>
#include <mutex>

static constexpr size_t CONCURRENT_CAPACITY = 256;
using ConcurrentRing = tsn::RingBuffer<TsnEvent, CONCURRENT_CAPACITY>;

/// Helper: create a TsnEvent tagged with a thread id and sequence index.
/// We encode the thread id in sensor_id and the per-thread index in temp_c
/// so corruption can be detected.
static TsnEvent make_tagged_event(uint8_t thread_id, float index) {
    TsnEvent e{};
    e.type = TSN_EVENT_TEMP_READING;
    e.payload.temp.sensor_id = thread_id;
    e.payload.temp.temp_c = index;
    return e;
}

/**
 * **Validates: Requirements 10.2**
 *
 * Property 14: Ring buffer concurrent access integrity
 */
RC_GTEST_PROP(RingBufferConcurrent, AccessIntegrity, ()) {
    // Generate reasonable thread/event counts to avoid flakiness
    const auto num_producers = *rc::gen::inRange<size_t>(2, 5);    // 2-4 producers
    const auto events_per_producer = *rc::gen::inRange<size_t>(10, 65); // 10-64 events each
    const auto num_consumers = *rc::gen::inRange<size_t>(1, 3);    // 1-2 consumers

    ConcurrentRing rb;

    // Track total events pushed (atomic for thread safety)
    std::atomic<size_t> total_pushed{0};

    // Collect all drained events across consumers
    std::mutex drained_mutex;
    std::vector<TsnEvent> all_drained;

    // ── Producer threads ──────────────────────────────────────────────
    std::vector<std::thread> producers;
    producers.reserve(num_producers);
    for (size_t t = 0; t < num_producers; ++t) {
        producers.emplace_back([&rb, &total_pushed, t, events_per_producer]() {
            for (size_t i = 0; i < events_per_producer; ++i) {
                TsnEvent e = make_tagged_event(
                    static_cast<uint8_t>(t),
                    static_cast<float>(i));
                rb.push(e);
                total_pushed.fetch_add(1, std::memory_order_relaxed);
            }
        });
    }

    // ── Consumer threads ──────────────────────────────────────────────
    // Consumers drain while producers are still running.
    std::atomic<bool> producers_done{false};
    std::vector<std::thread> consumers;
    consumers.reserve(num_consumers);
    for (size_t c = 0; c < num_consumers; ++c) {
        consumers.emplace_back([&rb, &producers_done, &drained_mutex, &all_drained]() {
            std::vector<TsnEvent> local_batch(64);
            while (!producers_done.load(std::memory_order_acquire)) {
                size_t n = rb.drain(local_batch.data(), local_batch.size());
                if (n > 0) {
                    std::lock_guard<std::mutex> lk(drained_mutex);
                    all_drained.insert(all_drained.end(),
                                       local_batch.begin(),
                                       local_batch.begin() + n);
                }
            }
            // Final drain after producers are done
            size_t n;
            do {
                n = rb.drain(local_batch.data(), local_batch.size());
                if (n > 0) {
                    std::lock_guard<std::mutex> lk(drained_mutex);
                    all_drained.insert(all_drained.end(),
                                       local_batch.begin(),
                                       local_batch.begin() + n);
                }
            } while (n > 0);
        });
    }

    // Wait for producers to finish
    for (auto& t : producers) {
        t.join();
    }
    producers_done.store(true, std::memory_order_release);

    // Wait for consumers to finish
    for (auto& t : consumers) {
        t.join();
    }

    // ── Final drain of anything remaining ─────────────────────────────
    {
        std::vector<TsnEvent> remaining(CONCURRENT_CAPACITY);
        size_t n = rb.drain(remaining.data(), remaining.size());
        if (n > 0) {
            all_drained.insert(all_drained.end(),
                               remaining.begin(),
                               remaining.begin() + n);
        }
    }

    const size_t pushed = total_pushed.load();
    const size_t remaining_count = rb.count();
    const uint64_t dropped = rb.dropped_count();

    // ── Invariant 1: Conservation ─────────────────────────────────────
    // drained + remaining + dropped == total pushed
    RC_ASSERT(all_drained.size() + remaining_count + dropped == pushed);

    // ── Invariant 2: No corruption ────────────────────────────────────
    // Every drained event must have a valid type and its sensor_id must
    // be a valid producer thread index, and temp_c must be a valid
    // per-thread event index.
    for (const auto& ev : all_drained) {
        RC_ASSERT(ev.type == TSN_EVENT_TEMP_READING);
        RC_ASSERT(ev.payload.temp.sensor_id < static_cast<uint8_t>(num_producers));

        float idx = ev.payload.temp.temp_c;
        RC_ASSERT(idx >= 0.0f);
        RC_ASSERT(idx < static_cast<float>(events_per_producer));
        // Verify it's an integer value (no corruption of the float bits)
        RC_ASSERT(idx == static_cast<float>(static_cast<int>(idx)));
    }

    // ── Invariant 3: Test completed (no deadlock) ─────────────────────
    // If we reach here, no deadlock occurred. This is implicitly verified.
}
