#include <gtest/gtest.h>
#include "ring_buffer.h"
#include "tube_sealer_native.h"

using EventRing = tsn::RingBuffer<TsnEvent, 4>;

static TsnEvent make_event(uint8_t type, float temp = 0.0f) {
    TsnEvent e{};
    e.type = type;
    e.payload.temp.temp_c = temp;
    return e;
}

TEST(RingBuffer, PushPopBasic) {
    EventRing rb;
    EXPECT_EQ(rb.count(), 0u);

    TsnEvent e = make_event(TSN_EVENT_TEMP_READING, 25.0f);
    EXPECT_TRUE(rb.push(e));
    EXPECT_EQ(rb.count(), 1u);

    TsnEvent out{};
    EXPECT_TRUE(rb.pop(&out));
    EXPECT_EQ(out.type, TSN_EVENT_TEMP_READING);
    EXPECT_FLOAT_EQ(out.payload.temp.temp_c, 25.0f);
    EXPECT_EQ(out.sequence, 0u);
    EXPECT_EQ(rb.count(), 0u);
}

TEST(RingBuffer, PopEmptyReturnsFalse) {
    EventRing rb;
    TsnEvent out{};
    EXPECT_FALSE(rb.pop(&out));
}

TEST(RingBuffer, SequenceMonotonicallyIncreases) {
    EventRing rb;
    for (int i = 0; i < 4; ++i) {
        rb.push(make_event(TSN_EVENT_TEMP_READING, static_cast<float>(i)));
    }

    for (uint64_t i = 0; i < 4; ++i) {
        TsnEvent out{};
        EXPECT_TRUE(rb.pop(&out));
        EXPECT_EQ(out.sequence, i);
    }
}

TEST(RingBuffer, OverflowOverwritesOldestAndIncrDropped) {
    EventRing rb; // capacity 4
    // Push 6 entries — first 2 should be overwritten
    for (int i = 0; i < 6; ++i) {
        rb.push(make_event(TSN_EVENT_TEMP_READING, static_cast<float>(i)));
    }

    EXPECT_EQ(rb.count(), 4u);
    EXPECT_EQ(rb.dropped_count(), 2u);

    // The remaining entries should be the last 4 pushed (indices 2..5)
    for (int i = 2; i < 6; ++i) {
        TsnEvent out{};
        EXPECT_TRUE(rb.pop(&out));
        EXPECT_FLOAT_EQ(out.payload.temp.temp_c, static_cast<float>(i));
    }
}

TEST(RingBuffer, DrainReturnsCorrectCount) {
    EventRing rb;
    rb.push(make_event(TSN_EVENT_TEMP_READING, 1.0f));
    rb.push(make_event(TSN_EVENT_GPIO_CHANGE));
    rb.push(make_event(TSN_EVENT_TEMP_ALERT, 99.0f));

    TsnEvent batch[8]{};
    size_t drained = rb.drain(batch, 8);
    EXPECT_EQ(drained, 3u);
    EXPECT_EQ(rb.count(), 0u);

    EXPECT_EQ(batch[0].type, TSN_EVENT_TEMP_READING);
    EXPECT_EQ(batch[1].type, TSN_EVENT_GPIO_CHANGE);
    EXPECT_EQ(batch[2].type, TSN_EVENT_TEMP_ALERT);
}

TEST(RingBuffer, DrainPartial) {
    EventRing rb;
    for (int i = 0; i < 4; ++i) {
        rb.push(make_event(TSN_EVENT_TEMP_READING, static_cast<float>(i)));
    }

    TsnEvent batch[2]{};
    size_t drained = rb.drain(batch, 2);
    EXPECT_EQ(drained, 2u);
    EXPECT_EQ(rb.count(), 2u);
}

TEST(RingBuffer, NextSequenceReflectsTotalPushes) {
    EventRing rb;
    EXPECT_EQ(rb.next_sequence(), 0u);
    rb.push(make_event(TSN_EVENT_TEMP_READING));
    EXPECT_EQ(rb.next_sequence(), 1u);
    rb.push(make_event(TSN_EVENT_TEMP_READING));
    rb.push(make_event(TSN_EVENT_TEMP_READING));
    EXPECT_EQ(rb.next_sequence(), 3u);
}

TEST(RingBuffer, OverflowSequenceStillMonotonic) {
    EventRing rb; // capacity 4
    // Push 10 entries — 6 overwritten
    for (int i = 0; i < 10; ++i) {
        rb.push(make_event(TSN_EVENT_TEMP_READING, static_cast<float>(i)));
    }

    EXPECT_EQ(rb.dropped_count(), 6u);
    EXPECT_EQ(rb.next_sequence(), 10u);

    uint64_t prev_seq = 0;
    bool first = true;
    TsnEvent out{};
    while (rb.pop(&out)) {
        if (!first) {
            EXPECT_GT(out.sequence, prev_seq);
        }
        prev_seq = out.sequence;
        first = false;
    }
}
