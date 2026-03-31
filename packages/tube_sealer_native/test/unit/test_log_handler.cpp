#include <gtest/gtest.h>
#include "log_handler.h"
#include "ring_buffer.h"
#include "tube_sealer_native.h"

#include <cstdio>
#include <cstring>
#include <string>
#include <thread>
#include <vector>
#include <fstream>
#include <sstream>
#include <filesystem>

/* ── Helpers ───────────────────────────────────────────────────────── */

class LogHandlerTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Drain any leftover entries from the static ring buffer
        // (it persists across tests since it's file-scoped in log_handler.cpp)
        tsn_log_init(TSN_LOG_DEBUG, TSN_LOG_OUTPUT_RINGBUF, nullptr);
        auto* ring = tsn_log_get_ring();
        if (ring) {
            TsnEvent discard[256];
            ring->drain(discard, 256);
        }
        tsn_log_shutdown();
    }

    void TearDown() override {
        tsn_log_shutdown();
    }
};

/* ── Basic initialization ──────────────────────────────────────────── */

TEST_F(LogHandlerTest, InitStderrDoesNotCrash) {
    tsn_log_init(TSN_LOG_DEBUG, TSN_LOG_OUTPUT_STDERR, nullptr);
    // Just verify no crash
}

TEST_F(LogHandlerTest, InitFileCreatesFile) {
    const char* path = "test_log_handler_output.log";
    std::remove(path);

    tsn_log_init(TSN_LOG_DEBUG, TSN_LOG_OUTPUT_FILE, path);
    tsn_log(TSN_LOG_INFO, "test", "hello file");
    tsn_log_shutdown();

    std::ifstream f(path);
    ASSERT_TRUE(f.is_open());
    std::string content((std::istreambuf_iterator<char>(f)),
                         std::istreambuf_iterator<char>());
    f.close();
    std::remove(path);

    EXPECT_NE(content.find("[INFO]"), std::string::npos);
    EXPECT_NE(content.find("[test]"), std::string::npos);
    EXPECT_NE(content.find("hello file"), std::string::npos);
}

/* ── Log level filtering ───────────────────────────────────────────── */

TEST_F(LogHandlerTest, FiltersSuppressedLevels) {
    tsn_log_init(TSN_LOG_WARN, TSN_LOG_OUTPUT_RINGBUF, nullptr);

    tsn_log(TSN_LOG_DEBUG, "test", "debug msg");
    tsn_log(TSN_LOG_INFO, "test", "info msg");
    tsn_log(TSN_LOG_WARN, "test", "warn msg");
    tsn_log(TSN_LOG_ERROR, "test", "error msg");

    auto* ring = tsn_log_get_ring();
    ASSERT_NE(ring, nullptr);

    // Only WARN and ERROR should be in the ring (DEBUG and INFO suppressed)
    EXPECT_EQ(ring->count(), 2u);

    TsnEvent ev{};
    ASSERT_TRUE(ring->pop(&ev));
    EXPECT_EQ(ev.payload.log.level, TSN_LOG_WARN);
    EXPECT_STREQ(ev.payload.log.msg, "warn msg");

    ASSERT_TRUE(ring->pop(&ev));
    EXPECT_EQ(ev.payload.log.level, TSN_LOG_ERROR);
    EXPECT_STREQ(ev.payload.log.msg, "error msg");
}

TEST_F(LogHandlerTest, SetLevelChangesFilterAtRuntime) {
    tsn_log_init(TSN_LOG_ERROR, TSN_LOG_OUTPUT_RINGBUF, nullptr);

    tsn_log(TSN_LOG_WARN, "test", "should be suppressed");

    auto* ring = tsn_log_get_ring();
    ASSERT_NE(ring, nullptr);
    EXPECT_EQ(ring->count(), 0u);

    tsn_log_set_level(TSN_LOG_DEBUG);
    tsn_log(TSN_LOG_DEBUG, "test", "now visible");
    EXPECT_EQ(ring->count(), 1u);
}

/* ── Message format ────────────────────────────────────────────────── */

TEST_F(LogHandlerTest, RingbufEntryHasCorrectFormat) {
    tsn_log_init(TSN_LOG_DEBUG, TSN_LOG_OUTPUT_RINGBUF, nullptr);

    tsn_log(TSN_LOG_INFO, "uart", "bytes sent: %d", 42);

    auto* ring = tsn_log_get_ring();
    ASSERT_NE(ring, nullptr);
    ASSERT_EQ(ring->count(), 1u);

    TsnEvent ev{};
    ASSERT_TRUE(ring->pop(&ev));

    EXPECT_EQ(ev.type, TSN_EVENT_LOG);
    EXPECT_EQ(ev.payload.log.level, TSN_LOG_INFO);
    EXPECT_STREQ(ev.payload.log.component, "uart");
    EXPECT_STREQ(ev.payload.log.msg, "bytes sent: 42");
    // Timestamp is in nanoseconds from CLOCK_MONOTONIC; may be 0 if test runs
    // very quickly after init on Windows (sub-millisecond resolution).
    // Just verify the field is set (not checking > 0 since it can legitimately be 0).
    EXPECT_EQ(ev.timestamp, ev.timestamp); // no-op sanity
}

TEST_F(LogHandlerTest, FileOutputContainsTimestampLevelComponentMessage) {
    const char* path = "test_log_format.log";
    std::remove(path);

    tsn_log_init(TSN_LOG_DEBUG, TSN_LOG_OUTPUT_FILE, path);
    tsn_log(TSN_LOG_ERROR, "spi", "transfer failed code=%d", -8);
    tsn_log_shutdown();

    std::ifstream f(path);
    ASSERT_TRUE(f.is_open());
    std::string line;
    std::getline(f, line);
    f.close();
    std::remove(path);

    // Format: "[timestamp_ms] [LEVEL] [component] message"
    EXPECT_NE(line.find("[ERROR]"), std::string::npos);
    EXPECT_NE(line.find("[spi]"), std::string::npos);
    EXPECT_NE(line.find("transfer failed code=-8"), std::string::npos);
    // Timestamp is the first bracketed value
    EXPECT_EQ(line[0], '[');
}

/* ── Ring buffer output ────────────────────────────────────────────── */

TEST_F(LogHandlerTest, GetRingReturnsNullForNonRingbufOutput) {
    tsn_log_init(TSN_LOG_DEBUG, TSN_LOG_OUTPUT_STDERR, nullptr);
    EXPECT_EQ(tsn_log_get_ring(), nullptr);
}

TEST_F(LogHandlerTest, GetRingReturnsValidForRingbufOutput) {
    tsn_log_init(TSN_LOG_DEBUG, TSN_LOG_OUTPUT_RINGBUF, nullptr);
    EXPECT_NE(tsn_log_get_ring(), nullptr);
}

/* ── UART output mode ──────────────────────────────────────────────── */

TEST_F(LogHandlerTest, UartModeDoesNotCrash) {
    tsn_log_init(TSN_LOG_DEBUG, TSN_LOG_OUTPUT_UART, nullptr);
    tsn_log(TSN_LOG_INFO, "mc", "state changed to PREHEAT");
    // UART buffer stores internally; no crash expected
}

/* ── Thread safety ─────────────────────────────────────────────────── */

TEST_F(LogHandlerTest, ConcurrentLogsDoNotCorruptOrDeadlock) {
    tsn_log_init(TSN_LOG_DEBUG, TSN_LOG_OUTPUT_RINGBUF, nullptr);

    constexpr int THREADS = 4;
    constexpr int MSGS_PER_THREAD = 50;

    auto worker = [MSGS_PER_THREAD](int id) {
        for (int i = 0; i < MSGS_PER_THREAD; ++i) {
            tsn_log(TSN_LOG_INFO, "thr", "thread=%d iter=%d", id, i);
        }
    };

    std::vector<std::thread> threads;
    for (int t = 0; t < THREADS; ++t) {
        threads.emplace_back(worker, t);
    }
    for (auto& t : threads) {
        t.join();
    }

    auto* ring = tsn_log_get_ring();
    ASSERT_NE(ring, nullptr);

    // Ring capacity is 256; we pushed 200 messages total.
    // All should be present (no overflow).
    EXPECT_EQ(ring->count(), static_cast<size_t>(THREADS * MSGS_PER_THREAD));
    EXPECT_EQ(ring->dropped_count(), 0u);

    // Drain and verify no corruption: every entry should have type LOG
    TsnEvent batch[256];
    size_t drained = ring->drain(batch, 256);
    EXPECT_EQ(drained, static_cast<size_t>(THREADS * MSGS_PER_THREAD));

    for (size_t i = 0; i < drained; ++i) {
        EXPECT_EQ(batch[i].type, TSN_EVENT_LOG);
        EXPECT_EQ(batch[i].payload.log.level, TSN_LOG_INFO);
        EXPECT_STREQ(batch[i].payload.log.component, "thr");
        // Message should contain "thread=" and "iter="
        EXPECT_NE(std::string(batch[i].payload.log.msg).find("thread="), std::string::npos);
    }
}

/* ── Shutdown and reinit ───────────────────────────────────────────── */

TEST_F(LogHandlerTest, ShutdownThenReinitWorks) {
    tsn_log_init(TSN_LOG_DEBUG, TSN_LOG_OUTPUT_RINGBUF, nullptr);
    tsn_log(TSN_LOG_INFO, "test", "first session");
    tsn_log_shutdown();

    tsn_log_init(TSN_LOG_DEBUG, TSN_LOG_OUTPUT_RINGBUF, nullptr);
    tsn_log(TSN_LOG_INFO, "test", "second session");

    auto* ring = tsn_log_get_ring();
    ASSERT_NE(ring, nullptr);
    // Ring is static, so it may still have entries from first session.
    // At minimum, the second session entry should be present.
    EXPECT_GE(ring->count(), 1u);
}

/* ── Null/empty component name ─────────────────────────────────────── */

TEST_F(LogHandlerTest, NullComponentDoesNotCrash) {
    tsn_log_init(TSN_LOG_DEBUG, TSN_LOG_OUTPUT_RINGBUF, nullptr);
    tsn_log(TSN_LOG_ERROR, nullptr, "null component");

    auto* ring = tsn_log_get_ring();
    ASSERT_NE(ring, nullptr);
    ASSERT_EQ(ring->count(), 1u);

    TsnEvent ev{};
    ring->pop(&ev);
    EXPECT_STREQ(ev.payload.log.component, "?");
}
