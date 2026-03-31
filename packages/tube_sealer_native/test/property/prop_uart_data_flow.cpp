/**
 * Property test: UART TX log/report passthrough (Property 5)
 *
 * **Validates: Requirements 4.2, 4.3**
 *
 * For any byte buffer passed to tsn_uart_send(), the mock platform write
 * function should receive the identical byte buffer, and the returned
 * bytes-written count should match the platform's return value. This
 * validates that logs, reports, and machine details are transmitted
 * correctly over serial.
 */

#include <gtest/gtest.h>
#include <rapidcheck.h>
#include <rapidcheck/gtest.h>

#include "uart_manager.h"
#include "mock_uart_platform.h"
#include "log_handler.h"

#include <cstring>
#include <string>
#include <vector>

/// Helper: create an initialized UartManager with mock platform.
static void setup_uart(UartManager& mgr, UartPlatform& platform, UartConfig& cfg) {
    platform = make_mock_uart_platform();
    std::memset(&cfg, 0, sizeof(cfg));
    std::strncpy(cfg.device_path, "/dev/ttyTest", sizeof(cfg.device_path));
    cfg.baud_rate = 115200;
    cfg.data_bits = 8;
    cfg.stop_bits = 1;
}

/**
 * **Validates: Requirements 4.2, 4.3**
 *
 * Property 5 — send() passthrough:
 * For any random byte vector (1-1024 bytes), the mock platform write
 * function receives the identical buffer and the returned bytes-written
 * count matches the platform's return value.
 */
RC_GTEST_PROP(UartTxPassthrough, SendPassesIdenticalBuffer, ()) {
    // Generate size then build a vector of that size
    const auto len = *rc::gen::inRange<size_t>(1, 1025);
    std::vector<uint8_t> data;
    data.reserve(len);
    for (size_t i = 0; i < len; ++i) {
        data.push_back(*rc::gen::arbitrary<uint8_t>());
    }

    g_mock_uart.reset();
    UartManager mgr;
    UartPlatform platform;
    UartConfig cfg;
    setup_uart(mgr, platform, cfg);

    tsn_log_init(TSN_LOG_ERROR, TSN_LOG_OUTPUT_STDERR, nullptr);
    RC_ASSERT(mgr.init(cfg, platform) == TSN_OK);

    uint32_t written = 0;
    TsnStatus status = mgr.send(data.data(),
                                static_cast<uint32_t>(data.size()),
                                &written);

    // 1. send() should succeed
    RC_ASSERT(status == TSN_OK);

    // 2. Mock received the identical byte buffer
    RC_ASSERT(g_mock_uart.write_called);
    RC_ASSERT(g_mock_uart.last_write_data.size() == data.size());
    RC_ASSERT(g_mock_uart.last_write_data == data);

    // 3. bytes_written matches mock return (mock returns len by default)
    RC_ASSERT(written == static_cast<uint32_t>(data.size()));

    mgr.stop();
    tsn_log_shutdown();
}

/**
 * **Validates: Requirements 4.2, 4.3**
 *
 * Property 5 — send() with partial write:
 * When the mock platform returns fewer bytes than requested, the
 * bytes-written out-param matches the mock's return value exactly.
 */
RC_GTEST_PROP(UartTxPassthrough, PartialWriteReturnsCorrectCount, ()) {
    const auto len = *rc::gen::inRange<size_t>(2, 513);
    std::vector<uint8_t> data;
    data.reserve(len);
    for (size_t i = 0; i < len; ++i) {
        data.push_back(*rc::gen::arbitrary<uint8_t>());
    }

    // Generate a partial write count in [1, data.size())
    auto partial = *rc::gen::inRange<int>(1, static_cast<int>(data.size()));

    g_mock_uart.reset();
    g_mock_uart.write_return_bytes = partial;

    UartManager mgr;
    UartPlatform platform;
    UartConfig cfg;
    setup_uart(mgr, platform, cfg);

    tsn_log_init(TSN_LOG_ERROR, TSN_LOG_OUTPUT_STDERR, nullptr);
    RC_ASSERT(mgr.init(cfg, platform) == TSN_OK);

    uint32_t written = 0;
    TsnStatus status = mgr.send(data.data(),
                                static_cast<uint32_t>(data.size()),
                                &written);

    RC_ASSERT(status == TSN_OK);
    RC_ASSERT(written == static_cast<uint32_t>(partial));

    // The mock still received the full buffer (it's the platform that
    // decides how many bytes to actually write)
    RC_ASSERT(g_mock_uart.last_write_data == data);

    mgr.stop();
    tsn_log_shutdown();
}

/**
 * **Validates: Requirements 4.2, 4.3**
 *
 * Property 5 — send_log() passthrough:
 * For any random non-empty string, send_log() passes the string bytes
 * (without null terminator) to the mock platform write function.
 */
RC_GTEST_PROP(UartTxPassthrough, SendLogPassesStringBytes, ()) {
    // Generate a random non-empty printable string
    const auto len = *rc::gen::inRange<size_t>(1, 257);
    std::string str;
    str.reserve(len);
    for (size_t i = 0; i < len; ++i) {
        str.push_back(*rc::gen::inRange<char>(0x20, 0x7F));
    }

    g_mock_uart.reset();
    UartManager mgr;
    UartPlatform platform;
    UartConfig cfg;
    setup_uart(mgr, platform, cfg);

    tsn_log_init(TSN_LOG_ERROR, TSN_LOG_OUTPUT_STDERR, nullptr);
    RC_ASSERT(mgr.init(cfg, platform) == TSN_OK);

    TsnStatus status = mgr.send_log(str.c_str());
    RC_ASSERT(status == TSN_OK);

    // Mock should have received the string bytes (strlen, no null terminator)
    RC_ASSERT(g_mock_uart.write_called);
    std::string received(g_mock_uart.last_write_data.begin(),
                         g_mock_uart.last_write_data.end());
    RC_ASSERT(received == str);

    mgr.stop();
    tsn_log_shutdown();
}
