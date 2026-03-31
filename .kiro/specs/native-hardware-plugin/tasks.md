# Implementation Plan: Native Hardware Plugin

## Overview

Build the `tube_sealer_native` FFI plugin from the ground up, starting with the plugin scaffold and foundation components (ring buffer, log handler), then peripheral components following the three-layer pattern, then orchestration (safety manager, machine controller, hw_manager), and finally the public C API surface and Dart FFI bindings. Each task builds on the previous, with no orphaned code.

## Tasks

- [x] 1. Scaffold the FFI plugin and set up the CMake build system
  - [x] 1.1 Create the plugin via `flutter create --template=plugin_ffi --platforms=linux,windows tube_sealer_native` inside `packages/`
    - Verify `pubspec.yaml` declares both `linux` and `windows` under `plugin.platforms`
    - Add the plugin as a path dependency in the main app's `pubspec.yaml`
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [x] 1.2 Set up the top-level `src/CMakeLists.txt` and component build structure
    - Create `src/CMakeLists.txt` that discovers and builds all component subdirectories under `src/components/`
    - Ensure `linux/CMakeLists.txt` and `windows/CMakeLists.txt` include the shared `src/CMakeLists.txt`
    - Add platform detection (Linux vs Windows) via CMake conditionals for selecting `*_linux.cpp` vs `*_windows.cpp` sources
    - Add `TSN_BUILD_TESTS` option and test CMake infrastructure with Google Test + RapidCheck via FetchContent
    - Create `src/tube_sealer_native.h` with the full public C API declarations (all `extern "C"` functions, enums, structs, opaque handle)
    - _Requirements: 16.1, 16.2, 16.3, 16.5, 16.6, 16.7_

  - [x] 1.3 Create mock platform headers under `test/mocks/`
    - Create `mock_uart_platform.h`, `mock_i2c_platform.h`, `mock_spi_platform.h`, `mock_adc_platform.h`, `mock_gpio_platform.h`, `mock_pwm_platform.h`
    - Each mock stores call arguments and returns configurable values
    - _Requirements: 16.1_

- [x] 2. Implement foundation components: ring_buffer and log_handler
  - [x] 2.1 Implement `ring_buffer` component
    - Create `src/components/ring_buffer/include/ring_buffer.h` with the templated `RingBuffer<T, Capacity>` class
    - Implement `push()`, `pop()`, `drain()`, `count()`, `dropped_count()`, `next_sequence()` with pthread mutex protection
    - `push()` on full buffer overwrites oldest and increments `dropped_`; every entry gets a monotonic sequence number
    - _Requirements: 10.2, 10.4, 10.5_

  - [x] 2.2 Write property test: ring buffer overflow invariant
    - **Property 13: Ring buffer overflow invariant**
    - **Validates: Requirements 10.4, 10.5**

  - [x] 2.3 Write property test: ring buffer concurrent access integrity
    - **Property 14: Ring buffer concurrent access integrity**
    - **Validates: Requirements 10.2**

  - [x] 2.4 Implement `log_handler` component
    - Create `src/components/log_handler/include/log_handler.h` and `src/components/log_handler/log_handler.cpp`
    - Implement `tsn_log_init()`, `tsn_log()`, `tsn_log_shutdown()` with thread-safe mutex
    - Support output to stderr, file, ring buffer, and UART destinations
    - Use `clock_gettime(CLOCK_MONOTONIC)` for timestamps
    - Implement log level filtering (ERROR, WARN, INFO, DEBUG)
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5_

  - [x] 2.5 Write property test: log message format invariant
    - **Property 24: Log message format invariant**
    - **Validates: Requirements 15.2**

  - [x] 2.6 Write property test: log level filtering
    - **Property 25: Log level filtering**
    - **Validates: Requirements 15.4**

  - [x] 2.7 Write property test: log handler thread safety
    - **Property 26: Log handler thread safety**
    - **Validates: Requirements 15.5**

- [x] 3. Checkpoint - Foundation components
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 4. Implement peripheral components (three-layer pattern)
  - [x] 4.1 Implement `peripheral_uart` component
    - Create `src/components/peripheral_uart/` with `include/uart_platform.h`, `include/uart_manager.h`, `include/uart_types.h`, `uart_linux.cpp`, `uart_windows.cpp`, `uart_manager.cpp`, `CMakeLists.txt`
    - `UartPlatform` is a struct of function pointers (open, read, write, close)
    - `UartManager` handles init, send, send_log, send_report, stop, fault detection
    - TX-only: serialize TX writes with `pthread_mutex_t`; no RX worker thread
    - Linux impl opens serial device, configures termios; Windows impl is a stub/mock
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6_

  - [-] 4.2 Write property test: UART TX passthrough
    - **Property 5: UART TX log/report passthrough**
    - **Validates: Requirements 4.2, 4.3**

  - [-] 4.3 Implement `peripheral_i2c` component
    - Create `src/components/peripheral_i2c/` with platform interface, manager, types, linux impl, windows stub, CMakeLists.txt
    - `I2cManager` handles init, read (register read), write (register write), stop, fault detection
    - Linux impl opens `/dev/i2c-N`, sets slave address via ioctl; Windows impl is a stub
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

  - [ ] 4.4 Write property test: I2C write-then-read round trip
    - **Property 7: I2C write-then-read round trip**
    - **Validates: Requirements 5.2, 5.3**

  - [ ] 4.5 Implement `peripheral_spi` component
    - Create `src/components/peripheral_spi/` with platform interface, manager, types, linux impl, windows stub, CMakeLists.txt
    - `SpiManager` handles init, full-duplex transfer, stop, fault detection
    - Linux impl opens `/dev/spidev*`, configures mode/speed via ioctl; Windows impl is a stub
    - _Requirements: 6.1, 6.2, 6.3_

  - [ ] 4.6 Write property test: SPI full-duplex transfer integrity
    - **Property 8: SPI full-duplex transfer integrity**
    - **Validates: Requirements 6.2**

  - [ ] 4.7 Implement `peripheral_adc` component
    - Create `src/components/peripheral_adc/` with `include/adc_manager.h`, `include/adc_types.h`, `adc_ads1115.cpp`, `adc_mcp3008.cpp`, `adc_manager.cpp`, `CMakeLists.txt`
    - ADC communicates through I2C or SPI managers (no direct platform layer)
    - Support ADS1115 (16-bit, I2C) and MCP3008 (10-bit, SPI) chip types
    - Return raw value + voltage scale factor; on error return last valid reading
    - _Requirements: 7.1, 7.2, 7.3, 7.4_

  - [ ] 4.8 Write property test: ADC read returns raw value and scale
    - **Property 9: ADC read returns raw value and scale via external chip**
    - **Validates: Requirements 7.2**

  - [ ] 4.9 Implement `peripheral_gpio` component
    - Create `src/components/peripheral_gpio/` with platform interface, manager, types, linux impl, windows stub, CMakeLists.txt
    - `GpioManager` handles init (pin + direction), write, read, start interrupt thread, stop
    - GPIO worker thread monitors edge events via `poll()`/`epoll()` on gpiod fds, pushes to GPIO ring buffer
    - Support configurable edge detection (rising, falling, both)
    - Linux impl uses libgpiod; Windows impl is a stub
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

  - [ ] 4.10 Write property test: GPIO write-then-read round trip
    - **Property 10: GPIO write-then-read round trip**
    - **Validates: Requirements 8.2, 8.3**

  - [ ] 4.11 Write property test: GPIO edge events flow to ring buffer
    - **Property 11: GPIO edge events flow to ring buffer with correct edge type**
    - **Validates: Requirements 8.4, 8.5**

  - [ ] 4.12 Implement `peripheral_pwm` component
    - Create `src/components/peripheral_pwm/` with platform interface, manager, types, linux impl, windows stub, CMakeLists.txt
    - `PwmManager` handles init, set_duty, set_freq, disable, fault detection
    - Linux impl writes to sysfs PWM interface; Windows impl is a stub
    - Disable sets duty to zero and disables output
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

  - [ ] 4.13 Write property test: PWM parameter updates are applied
    - **Property 12: PWM parameter updates are applied**
    - **Validates: Requirements 9.2, 9.3**

- [ ] 5. Checkpoint - Peripheral components
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Implement sensor and higher-level components
  - [ ] 6.1 Implement `sensor_temperature` component
    - Create `src/components/sensor_temperature/` with `include/temp_monitor.h`, `include/temp_types.h`, `temp_monitor.cpp`, `CMakeLists.txt`
    - `TempMonitor` reads sensors via SPI/I2C managers at configurable interval on a dedicated pthread
    - Push readings to temperature ring buffer; push alert events when thresholds exceeded
    - Push sensor-fault events on invalid/unresponsive readings; continue monitoring
    - Store last valid reading per sensor
    - _Requirements: 12.1, 12.2, 12.3, 12.4_

  - [ ] 6.2 Write property test: temperature threshold alerts
    - **Property 17: Temperature threshold alerts**
    - **Validates: Requirements 12.1, 12.2, 12.3**

  - [ ] 6.3 Implement `safety_manager` component
    - Create `src/components/safety_manager/` with `include/safety_manager.h`, `safety_manager.cpp`, `CMakeLists.txt`
    - `SafetyManager` takes references to GpioManager, PwmManager, and a ring buffer
    - Implement `check_overtemp()` with configurable timeout — disable PWM and push emergency event if persisted
    - Implement `check_estop()` — disable all actuator outputs and set `halted_` flag
    - Implement `refresh_watchdog()` and watchdog expiry detection — trigger safe shutdown on expiry
    - Implement `get_status()` returning `TsnSafetyStatus`
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 13.6_

  - [ ] 6.4 Write property test: over-temperature timeout shutdown
    - **Property 18: Safety manager over-temperature timeout shutdown**
    - **Validates: Requirements 13.2**

  - [ ] 6.5 Write property test: emergency stop halts all outputs
    - **Property 19: Emergency stop halts all outputs**
    - **Validates: Requirements 13.3**

  - [ ] 6.6 Write property test: halted system rejects actuator commands
    - **Property 20: Halted system rejects actuator commands**
    - **Validates: Requirements 13.4**

  - [ ] 6.7 Write property test: watchdog expiry triggers safe shutdown
    - **Property 21: Watchdog expiry triggers safe shutdown**
    - **Validates: Requirements 13.5**

  - [ ] 6.8 Implement `machine_controller` component
    - Create `src/components/machine_controller/` with `include/machine_controller.h`, `machine_controller.cpp`, `CMakeLists.txt`
    - Implement state machine: IDLE, PREHEAT, SEAL, COOL_DOWN, COMPLETE, FAULT
    - Validate transitions against the allowed transitions table; return `TSN_ERR_INVALID_STATE_TRANSITION` for invalid ones
    - On fault during active states, transition to FAULT and command safety manager to disable outputs
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_

  - [ ] 6.9 Write property test: state machine transition validity
    - **Property 22: State machine transition validity**
    - **Validates: Requirements 14.2, 14.3**

  - [ ] 6.10 Write property test: fault during active state transitions to FAULT
    - **Property 23: Fault during active state transitions to FAULT**
    - **Validates: Requirements 14.5**

- [ ] 7. Checkpoint - Sensor and orchestration components
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 8. Implement hw_manager and public C API
  - [ ] 8.1 Implement `hw_manager` component
    - Create `src/components/hw_manager/` with `include/hw_manager.h`, `hw_manager.cpp`, `CMakeLists.txt`
    - Define the `TsnContext` struct owning all peripheral managers, monitors, ring buffers, and state
    - Implement `init()`: allocate context, init all peripherals (log failures, set bitmask), start worker threads
    - Implement `shutdown()`: set stop flags, join threads (2s timeout then detach), close FDs, free buffers, deallocate context
    - Reject double init (return `TSN_ERR_ALREADY_INITIALIZED`); reject null handle (return `TSN_ERR_INVALID_HANDLE`)
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 10.1_

  - [ ] 8.2 Implement `tube_sealer_native.cpp` — the public C API surface
    - Implement all `extern "C"` functions declared in `tube_sealer_native.h`
    - Route each function through `TsnContext` to the appropriate manager
    - Enforce system-halted check on actuator commands (return `TSN_ERR_SYSTEM_HALTED`)
    - Implement `tsn_poll_events()`: drain all ring buffers into `TsnEventBatch`, populate per-type counts and dropped total
    - Implement `tsn_set_log_level()` to update log handler at runtime
    - _Requirements: 1.1, 1.2, 1.4, 1.5, 1.6, 11.1, 11.2, 11.3, 11.4, 13.4_

  - [ ] 8.3 Write property test: initialization returns valid handle and status
    - **Property 1: Initialization returns valid handle and status**
    - **Validates: Requirements 1.1, 1.2**

  - [ ] 8.4 Write property test: partial initialization bitmask accuracy
    - **Property 2: Partial initialization bitmask accuracy**
    - **Validates: Requirements 1.3**

  - [ ] 8.5 Write property test: shutdown deallocates all resources
    - **Property 3: Shutdown deallocates all resources**
    - **Validates: Requirements 1.4**

  - [ ] 8.6 Write property test: peripheral initialization with valid config
    - **Property 4: Peripheral initialization with valid config**
    - **Validates: Requirements 4.1, 5.1, 6.1, 7.1, 8.1, 9.1**

  - [ ] 8.7 Write property test: worker thread clean shutdown
    - **Property 15: Worker thread clean shutdown**
    - **Validates: Requirements 10.3**

  - [ ] 8.8 Write property test: poll events drains all ring buffers into correct batch
    - **Property 16: Poll events drains all ring buffers into correct batch**
    - **Validates: Requirements 11.1, 11.2**

- [ ] 9. Checkpoint - Native API layer
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 10. Implement Dart FFI bridge and event serialization
  - [ ] 10.1 Create Dart FFI bindings in `lib/src/`
    - Define Dart `Struct` subclasses mirroring all C structs: `TsnEvent`, `TsnEventBatch`, `TsnConfig`, `TsnInitResult`, `TsnAdcReading`, `TsnSafetyStatus`, and all config structs
    - Load the native library via `DynamicLibrary.open` (`.so` on Linux, `.dll` on Windows)
    - Expose all native functions as typed Dart function references
    - Translate error codes to a Dart enum with human-readable descriptions
    - Throw descriptive exception if native library not found
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

  - [ ] 10.2 Implement event deserialization and memory management
    - Deserialize `TsnEventBatch` binary data into typed Dart event objects
    - Skip unrecognized event type tags with a warning log
    - Manage native memory allocation/deallocation for structs passed across FFI boundary
    - _Requirements: 17.1, 17.2, 17.3, 17.4_

  - [ ] 10.3 Write property test: event serialization round trip
    - **Property 27: Event serialization round trip**
    - **Validates: Requirements 17.1, 17.2, 17.3**

- [ ] 11. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- The plugin targets Linux ARM (RPi4B) for production and Windows for development/testing with mock hardware
- All native code uses `extern "C"` at the FFI boundary with C++ internals
