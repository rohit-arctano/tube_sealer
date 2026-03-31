cmake_minimum_required(VERSION 3.14)

add_library(tsn_log_handler STATIC
    log_handler.cpp
)

target_include_directories(tsn_log_handler
    PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

# Depends on ring_buffer (header-only) and the top-level header
target_link_libraries(tsn_log_handler
    PUBLIC tsn_ring_buffer
)

target_include_directories(tsn_log_handler
    PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/../../"   # for tube_sealer_native.h
)

if(NOT WIN32)
    target_link_libraries(tsn_log_handler PUBLIC pthread)
endif()
