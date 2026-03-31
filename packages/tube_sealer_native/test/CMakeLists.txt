cmake_minimum_required(VERSION 3.14)

include(FetchContent)

# ── Google Test ────────────────────────────────────────────────────────
FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG        v1.14.0
)
# Prevent overriding the parent project's compiler/linker settings on Windows
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# ── RapidCheck ─────────────────────────────────────────────────────────
FetchContent_Declare(
    rapidcheck
    GIT_REPOSITORY https://github.com/emil-e/rapidcheck.git
    GIT_TAG        master
)
set(RC_ENABLE_GTEST ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(rapidcheck)

# ── Mock headers ───────────────────────────────────────────────────────
set(TSN_MOCK_DIR "${CMAKE_CURRENT_SOURCE_DIR}/mocks")

# ── Helper: add a test executable ──────────────────────────────────────
function(tsn_add_test TEST_NAME)
    cmake_parse_arguments(ARG "" "" "SOURCES;LIBS" ${ARGN})
    add_executable(${TEST_NAME} ${ARG_SOURCES})
    target_include_directories(${TEST_NAME} PRIVATE
        "${CMAKE_CURRENT_SOURCE_DIR}/../src"
        "${TSN_MOCK_DIR}"
    )
    # Include component headers
    file(GLOB comp_include_dirs "${CMAKE_CURRENT_SOURCE_DIR}/../src/components/*/include")
    foreach(inc_dir ${comp_include_dirs})
        target_include_directories(${TEST_NAME} PRIVATE "${inc_dir}")
    endforeach()

    target_link_libraries(${TEST_NAME} PRIVATE
        GTest::gtest_main
        rapidcheck
        rapidcheck_gtest
        ${ARG_LIBS}
    )
    target_compile_features(${TEST_NAME} PRIVATE cxx_std_17)
    add_test(NAME ${TEST_NAME} COMMAND ${TEST_NAME})
endfunction()

# ── Test targets ───────────────────────────────────────────────────────
tsn_add_test(test_ring_buffer
    SOURCES unit/test_ring_buffer.cpp
    LIBS tsn_ring_buffer
)

tsn_add_test(prop_ring_buffer
    SOURCES property/prop_ring_buffer.cpp
    LIBS tsn_ring_buffer
)

tsn_add_test(test_log_handler
    SOURCES unit/test_log_handler.cpp
    LIBS tsn_log_handler
)

tsn_add_test(prop_log_handler
    SOURCES property/prop_log_handler.cpp
    LIBS tsn_log_handler
)

tsn_add_test(test_uart_manager
    SOURCES unit/test_uart_manager.cpp
    LIBS tsn_peripheral_uart
)

tsn_add_test(prop_uart_data_flow
    SOURCES property/prop_uart_data_flow.cpp
    LIBS tsn_peripheral_uart
)

tsn_add_test(test_i2c_manager
    SOURCES unit/test_i2c_manager.cpp
    LIBS tsn_peripheral_i2c
)
