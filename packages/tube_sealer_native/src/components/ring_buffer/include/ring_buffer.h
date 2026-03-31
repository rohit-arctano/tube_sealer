#ifndef TSN_RING_BUFFER_H
#define TSN_RING_BUFFER_H

#include <cstddef>
#include <cstdint>
#include <cstring>

#ifdef _WIN32
#include <mutex>
#else
#include <pthread.h>
#endif

namespace tsn {

/// A fixed-capacity, mutex-protected circular buffer.
///
/// When full, push() overwrites the oldest entry and increments the
/// dropped-event counter.  Every pushed entry receives a monotonically
/// increasing sequence number written into `entry.sequence`.
///
/// Template parameters:
///   T        – element type; must have a `uint64_t sequence` member.
///   Capacity – maximum number of elements the buffer can hold.
template <typename T, size_t Capacity>
class RingBuffer {
public:
    RingBuffer() {
#ifdef _WIN32
        // std::mutex is default-constructed
#else
        pthread_mutex_init(&mutex_, nullptr);
#endif
    }

    ~RingBuffer() {
#ifndef _WIN32
        pthread_mutex_destroy(&mutex_);
#endif
    }

    // Non-copyable, non-movable
    RingBuffer(const RingBuffer&) = delete;
    RingBuffer& operator=(const RingBuffer&) = delete;
    RingBuffer(RingBuffer&&) = delete;
    RingBuffer& operator=(RingBuffer&&) = delete;

    /// Push an entry into the buffer.
    /// Assigns a monotonic sequence number to entry.sequence before storing.
    /// Returns true if there was room; returns false if the buffer was full
    /// (oldest entry was overwritten and dropped_ was incremented).
    bool push(const T& entry) {
        ScopedLock lock(this);

        T stamped = entry;
        stamped.sequence = seq_++;

        bool was_full = (size_ == Capacity);

        if (was_full) {
            // Overwrite oldest entry at head_, advance head_
            buffer_[head_] = stamped;
            head_ = next(head_);
            tail_ = next(tail_);
            ++dropped_;
        } else {
            buffer_[tail_] = stamped;
            tail_ = next(tail_);
            ++size_;
        }

        return !was_full;
    }

    /// Pop the oldest entry from the buffer.
    /// Returns true on success, false if the buffer is empty.
    bool pop(T* out) {
        ScopedLock lock(this);

        if (size_ == 0) {
            return false;
        }

        if (out) {
            *out = buffer_[head_];
        }
        head_ = next(head_);
        --size_;
        return true;
    }

    /// Drain up to `max` entries from the buffer into `out`.
    /// Returns the number of entries actually copied.
    size_t drain(T* out, size_t max) {
        ScopedLock lock(this);

        size_t to_drain = (max < size_) ? max : size_;
        for (size_t i = 0; i < to_drain; ++i) {
            out[i] = buffer_[head_];
            head_ = next(head_);
        }
        size_ -= to_drain;
        return to_drain;
    }

    /// Number of entries currently in the buffer.
    size_t count() const {
        ScopedLock lock(this);
        return size_;
    }

    /// Total number of entries that were dropped (overwritten) since creation.
    uint64_t dropped_count() const {
        ScopedLock lock(this);
        return dropped_;
    }

    /// The sequence number that will be assigned to the next pushed entry.
    uint64_t next_sequence() const {
        ScopedLock lock(this);
        return seq_;
    }

private:
    T buffer_[Capacity];
    size_t head_ = 0;
    size_t tail_ = 0;
    size_t size_ = 0;
    uint64_t seq_ = 0;
    uint64_t dropped_ = 0;

#ifdef _WIN32
    mutable std::mutex mutex_;
#else
    mutable pthread_mutex_t mutex_;
#endif

    static size_t next(size_t idx) {
        return (idx + 1) % Capacity;
    }

    /// RAII lock guard that works with both pthread_mutex_t and std::mutex.
    struct ScopedLock {
#ifdef _WIN32
        explicit ScopedLock(const RingBuffer* rb) : rb_(rb) {
            rb_->mutex_.lock();
        }
        ~ScopedLock() {
            rb_->mutex_.unlock();
        }
        const RingBuffer* rb_;
#else
        explicit ScopedLock(const RingBuffer* rb) : mtx_(&rb->mutex_) {
            pthread_mutex_lock(mtx_);
        }
        ~ScopedLock() {
            pthread_mutex_unlock(mtx_);
        }
        pthread_mutex_t* mtx_;
#endif
    };
};

} // namespace tsn

#endif // TSN_RING_BUFFER_H
