#include <gtest/gtest.h>
#include "uart_manager.h"
#include "mock_uart_platform.h"
#include "log_handler.h"

#include <cstring>
#include <string>
#include <thread>
#include <vector>

/* ── Test fixture ──────────────────────────────────────────────────── */

class UartManagerTest : public ::testing::Test {
protected:
    UartManager mgr;
    UartPlatform mock_platform;
    UartConfig cfg{};

    void SetUp() override {
        g_mock_uart.reset();
        mock_platform = make_mock_uart_platform();
        std::strncpy(cfg.device_path, "/dev/ttyS0", sizeof(cfg.device_path));
        cfg.baud_rate = 115200;
        cfg.data_bits = 8;
        cfg.stop_bits = 1;
        cfg.parity = 0;
        cfg.flow_control = 0;

        tsn_log_init(TSN_LOG_DEBUG, TSN_LOG_OUTPUT_STDERR, nullptr);
    }

    void TearDown() override {
        tsn_log_shutdown();
    }
};

/* ── Initialization ────────────────────────────────────────────────── */

TEST_F(UartManagerTest, InitSucceeds) {
    EXPECT_EQ(mgr.init(cfg, mock_platform), TSN_OK);
    EXPECT_TRUE(g_mock_uart.open_called);
    EXPECT_FALSE(mgr.has_fault());
}

TEST_F(UartManagerTest, InitPassesConfigToOpen) {
    mgr.init(cfg, mock_platform);
    EXPECT_STREQ(g_mock_uart.last_open_config.device_path, "/dev/ttyS0");
    EXPECT_EQ(g_mock_uart.last_open_config.baud_rate, 115200u);
    EXPECT_EQ(g_mock_uart.last_open_config.data_bits, 8);
}

TEST_F(UartManagerTest, InitFailsWhenOpenReturnsNegative) {
    g_mock_uart.open_return_fd = -1;
    EXPECT_EQ(mgr.init(cfg, mock_platform), TSN_ERR_IO);
    EXPECT_TRUE(mgr.has_fault());
}

TEST_F(UartManagerTest, DoubleInitReturnsAlreadyInitialized) {
    mgr.init(cfg, mock_platform);
    EXPECT_EQ(mgr.init(cfg, mock_platform), TSN_ERR_ALREADY_INITIALIZED);
}

/* ── Send ──────────────────────────────────────────────────────────── */

TEST_F(UartManagerTest, SendWritesDataViaPlatform) {
    mgr.init(cfg, mock_platform);

    const uint8_t data[] = {0xDE, 0xAD, 0xBE, 0xEF};
    uint32_t written = 0;
    EXPECT_EQ(mgr.send(data, 4, &written), TSN_OK);
    EXPECT_EQ(written, 4u);

    EXPECT_TRUE(g_mock_uart.write_called);
    ASSERT_EQ(g_mock_uart.last_write_data.size(), 4u);
    EXPECT_EQ(g_mock_uart.last_write_data[0], 0xDE);
    EXPECT_EQ(g_mock_uart.last_write_data[3], 0xEF);
}

TEST_F(UartManagerTest, SendReturnsExactBytesWritten) {
    mgr.init(cfg, mock_platform);

    g_mock_uart.write_return_bytes = 2; // simulate partial write
    const uint8_t data[] = {1, 2, 3, 4};
    uint32_t written = 0;
    EXPECT_EQ(mgr.send(data, 4, &written), TSN_OK);
    EXPECT_EQ(written, 2u);
}

TEST_F(UartManagerTest, SendFailsWhenNotInitialized) {
    const uint8_t data[] = {1};
    uint32_t written = 0;
    EXPECT_EQ(mgr.send(data, 1, &written), TSN_ERR_PERIPHERAL_FAULT);
    EXPECT_EQ(written, 0u);
}

TEST_F(UartManagerTest, SendFailsWhenFaulted) {
    g_mock_uart.open_return_fd = -1;
    mgr.init(cfg, mock_platform); // will fault

    const uint8_t data[] = {1};
    uint32_t written = 0;
    EXPECT_EQ(mgr.send(data, 1, &written), TSN_ERR_PERIPHERAL_FAULT);
}

TEST_F(UartManagerTest, SendSetsFaultOnWriteFailure) {
    mgr.init(cfg, mock_platform);
    EXPECT_FALSE(mgr.has_fault());

    g_mock_uart.write_return_bytes = -1; // simulate write error
    const uint8_t data[] = {1};
    uint32_t written = 0;
    EXPECT_EQ(mgr.send(data, 1, &written), TSN_ERR_IO);
    EXPECT_TRUE(mgr.has_fault());
}

TEST_F(UartManagerTest, SendNullDataWithZeroLenSucceeds) {
    mgr.init(cfg, mock_platform);
    uint32_t written = 0;
    EXPECT_EQ(mgr.send(nullptr, 0, &written), TSN_OK);
}

TEST_F(UartManagerTest, SendNullDataWithNonZeroLenReturnsInvalidParam) {
    mgr.init(cfg, mock_platform);
    uint32_t written = 0;
    EXPECT_EQ(mgr.send(nullptr, 5, &written), TSN_ERR_INVALID_PARAM);
}

/* ── send_log ──────────────────────────────────────────────────────── */

TEST_F(UartManagerTest, SendLogTransmitsString) {
    mgr.init(cfg, mock_platform);

    EXPECT_EQ(mgr.send_log("hello uart"), TSN_OK);
    EXPECT_TRUE(g_mock_uart.write_called);

    std::string sent(g_mock_uart.last_write_data.begin(),
                     g_mock_uart.last_write_data.end());
    EXPECT_EQ(sent, "hello uart");
}

TEST_F(UartManagerTest, SendLogNullReturnsInvalidParam) {
    mgr.init(cfg, mock_platform);
    EXPECT_EQ(mgr.send_log(nullptr), TSN_ERR_INVALID_PARAM);
}

/* ── send_report ───────────────────────────────────────────────────── */

TEST_F(UartManagerTest, SendReportTransmitsBinaryData) {
    mgr.init(cfg, mock_platform);

    const uint8_t report[] = {0x01, 0x02, 0x03};
    EXPECT_EQ(mgr.send_report(report, 3), TSN_OK);
    EXPECT_TRUE(g_mock_uart.write_called);
    ASSERT_EQ(g_mock_uart.last_write_data.size(), 3u);
    EXPECT_EQ(g_mock_uart.last_write_data[0], 0x01);
}

/* ── Stop ──────────────────────────────────────────────────────────── */

TEST_F(UartManagerTest, StopClosesFd) {
    mgr.init(cfg, mock_platform);
    mgr.stop();

    EXPECT_TRUE(g_mock_uart.close_called);
    EXPECT_EQ(g_mock_uart.last_close_fd, g_mock_uart.open_return_fd);
}

TEST_F(UartManagerTest, StopThenSendReturnsFault) {
    mgr.init(cfg, mock_platform);
    mgr.stop();

    const uint8_t data[] = {1};
    uint32_t written = 0;
    EXPECT_EQ(mgr.send(data, 1, &written), TSN_ERR_PERIPHERAL_FAULT);
}

TEST_F(UartManagerTest, DoubleStopDoesNotCrash) {
    mgr.init(cfg, mock_platform);
    mgr.stop();
    mgr.stop(); // should be safe
}

/* ── has_fault ─────────────────────────────────────────────────────── */

TEST_F(UartManagerTest, HasFaultFalseAfterSuccessfulInit) {
    mgr.init(cfg, mock_platform);
    EXPECT_FALSE(mgr.has_fault());
}

TEST_F(UartManagerTest, HasFaultTrueAfterFailedInit) {
    g_mock_uart.open_return_fd = -1;
    mgr.init(cfg, mock_platform);
    EXPECT_TRUE(mgr.has_fault());
}

/* ── Thread safety ─────────────────────────────────────────────────── */

TEST_F(UartManagerTest, ConcurrentSendsDoNotCorrupt) {
    mgr.init(cfg, mock_platform);

    constexpr int THREADS = 4;
    constexpr int SENDS_PER_THREAD = 20;

    auto worker = [this](int id) {
        for (int i = 0; i < SENDS_PER_THREAD; ++i) {
            uint8_t buf[4];
            buf[0] = static_cast<uint8_t>(id);
            buf[1] = static_cast<uint8_t>(i);
            buf[2] = 0xAA;
            buf[3] = 0xBB;
            uint32_t written = 0;
            mgr.send(buf, 4, &written);
        }
    };

    std::vector<std::thread> threads;
    for (int t = 0; t < THREADS; ++t) {
        threads.emplace_back(worker, t);
    }
    for (auto& t : threads) {
        t.join();
    }

    // All sends should have completed without fault
    EXPECT_FALSE(mgr.has_fault());
}

/* ── Reinit after stop ─────────────────────────────────────────────── */

TEST_F(UartManagerTest, ReinitAfterStopWorks) {
    mgr.init(cfg, mock_platform);
    mgr.stop();

    g_mock_uart.reset();
    g_mock_uart.open_return_fd = 5;

    EXPECT_EQ(mgr.init(cfg, mock_platform), TSN_OK);
    EXPECT_TRUE(g_mock_uart.open_called);
    EXPECT_FALSE(mgr.has_fault());

    const uint8_t data[] = {0xFF};
    uint32_t written = 0;
    EXPECT_EQ(mgr.send(data, 1, &written), TSN_OK);
    EXPECT_EQ(written, 1u);
}
