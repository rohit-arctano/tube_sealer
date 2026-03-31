cmake_minimum_required(VERSION 3.14)

# Platform-conditional source selection
if(WIN32)
    set(I2C_PLATFORM_SRC i2c_windows.cpp)
else()
    set(I2C_PLATFORM_SRC i2c_linux.cpp)
endif()

add_library(tsn_peripheral_i2c STATIC
    i2c_manager.cpp
    ${I2C_PLATFORM_SRC}
)

target_include_directories(tsn_peripheral_i2c
    PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

# Depends on log_handler (which transitively brings ring_buffer and tube_sealer_native.h)
target_link_libraries(tsn_peripheral_i2c
    PUBLIC tsn_log_handler
)

# tube_sealer_native.h lives in src/
target_include_directories(tsn_peripheral_i2c
    PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/../../"
)

if(NOT WIN32)
    target_link_libraries(tsn_peripheral_i2c PUBLIC pthread)
endif()
