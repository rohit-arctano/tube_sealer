cmake_minimum_required(VERSION 3.14)

project(tube_sealer_native_library VERSION 0.0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ── Option: build tests ────────────────────────────────────────────────
option(TSN_BUILD_TESTS "Build unit and property-based tests" OFF)

# ── Platform detection ─────────────────────────────────────────────────
if(WIN32)
    set(TSN_PLATFORM "windows")
    set(TSN_PLATFORM_SUFFIX "_windows.cpp")
else()
    set(TSN_PLATFORM "linux")
    set(TSN_PLATFORM_SUFFIX "_linux.cpp")
endif()

# ── Top-level sources (the public API surface) ─────────────────────────
set(TSN_TOP_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/tube_sealer_native.cpp"
)

# ── Auto-discover component subdirectories ─────────────────────────────
# Each component under src/components/ that has a CMakeLists.txt is included
# automatically. Components build as STATIC libraries linked into the final
# shared library.
set(TSN_COMPONENT_LIBS "")

file(GLOB component_dirs "${CMAKE_CURRENT_SOURCE_DIR}/components/*")
foreach(comp_dir ${component_dirs})
    if(IS_DIRECTORY "${comp_dir}" AND EXISTS "${comp_dir}/CMakeLists.txt")
        get_filename_component(comp_name "${comp_dir}" NAME)
        add_subdirectory("${comp_dir}")
        list(APPEND TSN_COMPONENT_LIBS "tsn_${comp_name}")
    endif()
endforeach()

# ── Shared library target ──────────────────────────────────────────────
add_library(tube_sealer_native SHARED ${TSN_TOP_SOURCES})

target_include_directories(tube_sealer_native
    PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}"
)

# Link all component static libraries
if(TSN_COMPONENT_LIBS)
    target_link_libraries(tube_sealer_native PRIVATE ${TSN_COMPONENT_LIBS})
endif()

# Platform-specific threading
if(WIN32)
    # Windows uses std::thread (C++17) — no extra link flags needed
else()
    target_link_libraries(tube_sealer_native PRIVATE pthread)
endif()

set_target_properties(tube_sealer_native PROPERTIES
    PUBLIC_HEADER "tube_sealer_native.h"
    OUTPUT_NAME "tube_sealer_native"
    CXX_VISIBILITY_PRESET hidden
    POSITION_INDEPENDENT_CODE ON
)

target_compile_definitions(tube_sealer_native PUBLIC DART_SHARED_LIB)

# ── Test infrastructure ────────────────────────────────────────────────
if(TSN_BUILD_TESTS)
    enable_testing()
    add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../test" "${CMAKE_CURRENT_BINARY_DIR}/test")
endif()
