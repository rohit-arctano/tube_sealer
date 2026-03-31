#include <gtest/gtest.h>
#include "i2c_manager.h"
#include "mock_i2c_platform.h"
#include "log_handler.h"

#include <cstring>
#include <thread>
#include <vector>

/* ── Test fixture ──────────────────────────────────────────────────── */

class I2cManagerTest : public ::testing::Test {
protected:
    I2cManager mgr;
    I2cPlatform mock_platform;
    I2cConfig cfg{};

    void SetUp() override {
        g_mock_i2c.reset();
        mock_platform = make_mock_i2c_platform();
        cfg.bus_number = 1;
        cfg.device_address = 0x48;

        tsn_log_init(TSN_LOG_DEBUG, TSN_LOG_OUTPUT_STDERR, nullptr);
    }

    void TearDown() override {
        tsn_log_shutdown();
    }
};

/* ── Initialization ────────────────────────────────────────────────── */

TEST_F(I2cManagerTest, InitSucceeds) {
    EXPECT_EQ(mgr.init(cfg, mock_platform), TSN_OK);
    EXPECT_TRUE(g_mock_i2c.open_called);
    EXPECT_EQ(g_mock_i2c.last_open_bus, 1);
    EXPECT_FALSE(mgr.has_fault());
}

TEST_F(I2cManagerTest, InitFailsWhenOpenReturnsNegative) {
    g_mock_i2c.open_return_fd = -1;
    EXPECT_EQ(mgr.init(cfg, mock_platform), TSN_ERR_IO);
    EXPECT_TRUE(mgr.has_fault());
}

TEST_F(I2cManagerTest, DoubleInitReturnsAlreadyInitialized) {
    mgr.init(cfg, mock_platform);
    EXPECT_EQ(mgr.init(cfg, mock_platform), TSN_ERR_ALREADY_INITIALIZED);
}

/* ── read_register ─────────────────────────────────────────────────── */

TEST_F(I2cManagerTest, ReadRegisterSetsAddressAndReadsData) {
    mgr.init(cfg, mock_platform);

    uint8_t buf[4] = {};
    EXPECT_EQ(mgr.read_register(0x10, buf, 4), TSN_OK);

    // Should have set the device address
    EXPECT_TRUE(g_mock_i2c.set_address_called);
    EXPECT_EQ(g_mock_i2c.last_address, 0x48);

    // Should have written the register byte
    EXPECT_TRUE(g_mock_i2c.write_called);

    // Should have read data
    EXPECT_TRUE(g_mock_i2c.read_called);
    EXPECT_EQ(g_mock_i2c.last_read_len, 4u);
}

TEST_F(I2cManagerTest, ReadRegisterFailsWhenNotInitialized) {
    uint8_t buf[4] = {};
    EXPECT_EQ(mgr.read_register(0x10, buf, 4), TSN_ERR_PERIPHERAL_FAULT);
}

TEST_F(I2cManagerTest, ReadRegisterFailsOnSetAddressError) {
    mgr.init(cfg, mock_platform);
    g_mock_i2c.set_address_return = -1;

    uint8_t buf[4] = {};
    EXPECT_EQ(mgr.read_register(0x10, buf, 4), TSN_ERR_NACK);
    EXPECT_TRUE(mgr.has_fault());
}

TEST_F(I2cManagerTest, ReadRegisterFailsOnReadError) {
    mgr.init(cfg, mock_platform);
    g_mock_i2c.read_return = -1;

    uint8_t buf[4] = {};
    EXPECT_EQ(mgr.read_register(0x10, buf, 4), TSN_ERR_BUS);
    EXPECT_TRUE(mgr.has_fault());
}

TEST_F(I2cManagerTest, ReadRegisterNullBufWithNonZeroLenReturnsInvalidParam) {
    mgr.init(cfg, mock_platform);
    EXPECT_EQ(mgr.read_register(0x10, nullptr, 4), TSN_ERR_INVALID_PARAM);
}

/* ── write_register ────────────────────────────────────────────────── */

TEST_F(I2cManagerTest, WriteRegisterSetsAddressAndWritesData) {
    mgr.init(cfg, mock_platform);

    const uint8_t data[] = {0xAA, 0xBB};
    EXPECT_EQ(mgr.write_register(0x20, data, 2), TSN_OK);

    // Should have set the device address
    EXPECT_TRUE(g_mock_i2c.set_address_called);
    EXPECT_EQ(g_mock_i2c.last_address, 0x48);

    // Should have written [register + data]
    EXPECT_TRUE(g_mock_i2c.write_called);
    ASSERT_EQ(g_mock_i2c.last_write_data.size(), 3u);
    EXPECT_EQ(g_mock_i2c.last_write_data[0], 0x20); // register byte
    EXPECT_EQ(g_mock_i2c.last_write_data[1], 0xAA);
    EXPECT_EQ(g_mock_i2c.last_write_data[2], 0xBB);
}

TEST_F(I2cManagerTest, WriteRegisterFailsWhenNotInitialized) {
    const uint8_t data[] = {0x01};
    EXPECT_EQ(mgr.write_register(0x10, data, 1), TSN_ERR_PERIPHERAL_FAULT);
}

TEST_F(I2cManagerTest, WriteRegisterFailsOnSetAddressError) {
    mgr.init(cfg, mock_platform);
    g_mock_i2c.set_address_return = -1;

    const uint8_t data[] = {0x01};
    EXPECT_EQ(mgr.write_register(0x10, data, 1), TSN_ERR_NACK);
    EXPECT_TRUE(mgr.has_fault());
}

TEST_F(I2cManagerTest, WriteRegisterFailsOnWriteError) {
    mgr.init(cfg, mock_platform);
    g_mock_i2c.write_return = -1;

    const uint8_t data[] = {0x01};
    EXPECT_EQ(mgr.write_register(0x10, data, 1), TSN_ERR_BUS);
    EXPECT_TRUE(mgr.has_fault());
}

TEST_F(I2cManagerTest, WriteRegisterNullDataWithNonZeroLenReturnsInvalidParam) {
    mgr.init(cfg, mock_platform);
    EXPECT_EQ(mgr.write_register(0x10, nullptr, 4), TSN_ERR_INVALID_PARAM);
}

TEST_F(I2cManagerTest, WriteRegisterZeroLenSucceeds) {
    mgr.init(cfg, mock_platform);
    // Writing zero data bytes — just the register byte
    EXPECT_EQ(mgr.write_register(0x10, nullptr, 0), TSN_OK);
    ASSERT_EQ(g_mock_i2c.last_write_data.size(), 1u);
    EXPECT_EQ(g_mock_i2c.last_write_data[0], 0x10);
}

/* ── Stop ──────────────────────────────────────────────────────────── */

TEST_F(I2cManagerTest, StopClosesFd) {
    mgr.init(cfg, mock_platform);
    mgr.stop();

    EXPECT_TRUE(g_mock_i2c.close_called);
    EXPECT_EQ(g_mock_i2c.last_close_fd, g_mock_i2c.open_return_fd);
}

TEST_F(I2cManagerTest, StopThenReadReturnsFault) {
    mgr.init(cfg, mock_platform);
    mgr.stop();

    uint8_t buf[4] = {};
    EXPECT_EQ(mgr.read_register(0x10, buf, 4), TSN_ERR_PERIPHERAL_FAULT);
}

TEST_F(I2cManagerTest, DoubleStopDoesNotCrash) {
    mgr.init(cfg, mock_platform);
    mgr.stop();
    mgr.stop(); // should be safe
}

/* ── has_fault ─────────────────────────────────────────────────────── */

TEST_F(I2cManagerTest, HasFaultFalseAfterSuccessfulInit) {
    mgr.init(cfg, mock_platform);
    EXPECT_FALSE(mgr.has_fault());
}

TEST_F(I2cManagerTest, HasFaultTrueAfterFailedInit) {
    g_mock_i2c.open_return_fd = -1;
    mgr.init(cfg, mock_platform);
    EXPECT_TRUE(mgr.has_fault());
}

/* ── Thread safety ─────────────────────────────────────────────────── */

TEST_F(I2cManagerTest, ConcurrentOperationsDoNotCorrupt) {
    mgr.init(cfg, mock_platform);

    constexpr int THREADS = 4;
    constexpr int OPS_PER_THREAD = 20;

    auto worker = [this](int id) {
        for (int i = 0; i < OPS_PER_THREAD; ++i) {
            if (i % 2 == 0) {
                uint8_t buf[2] = {};
                mgr.read_register(static_cast<uint8_t>(id), buf, 2);
            } else {
                uint8_t data[] = {static_cast<uint8_t>(id), static_cast<uint8_t>(i)};
                mgr.write_register(static_cast<uint8_t>(id), data, 2);
            }
        }
    };

    std::vector<std::thread> threads;
    for (int t = 0; t < THREADS; ++t) {
        threads.emplace_back(worker, t);
    }
    for (auto& t : threads) {
        t.join();
    }

    EXPECT_FALSE(mgr.has_fault());
}

/* ── Reinit after stop ─────────────────────────────────────────────── */

TEST_F(I2cManagerTest, ReinitAfterStopWorks) {
    mgr.init(cfg, mock_platform);
    mgr.stop();

    g_mock_i2c.reset();
    g_mock_i2c.open_return_fd = 7;

    EXPECT_EQ(mgr.init(cfg, mock_platform), TSN_OK);
    EXPECT_TRUE(g_mock_i2c.open_called);
    EXPECT_FALSE(mgr.has_fault());

    uint8_t buf[2] = {};
    EXPECT_EQ(mgr.read_register(0x10, buf, 2), TSN_OK);
}
