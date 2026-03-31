cmake_minimum_required(VERSION 3.14)

# Header-only (INTERFACE) library — no .cpp files to compile
add_library(tsn_ring_buffer INTERFACE)

target_include_directories(tsn_ring_buffer
    INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

# On Linux, consumers need pthread for the mutex
if(NOT WIN32)
    target_link_libraries(tsn_ring_buffer INTERFACE pthread)
endif()
