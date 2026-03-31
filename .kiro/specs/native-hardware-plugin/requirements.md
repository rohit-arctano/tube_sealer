# Requirements Document

## Introduction

This document defines the requirements for a native FFI hardware plugin for the tube_sealer Flutter application. The plugin bridges Flutter/Dart to native C/C++ code via `dart:ffi`, enabling direct control of embedded hardware peripherals (UART, I2C, SPI, GPIO, PWM) and external ADC chips on a Raspberry Pi 4B (Linux ARM) platform. Since the RPi4B has no built-in ADC, analog readings are handled through external ADC chips (e.g., ADS1115 over I2C, MCP3008 over SPI). The architecture uses background pthreads for continuous hardware monitoring, shared ring buffers for thread-safe data exchange, and a pull-based model where Flutter periodically fetches batched events from the native layer.

## Glossary

- **FFI_Bridge**: The Dart FFI loading and binding layer that exposes native C functions to Dart code via `dart:ffi`
- **Native_API_Layer**: The C/C++ API surface callable from Dart through FFI, responsible for routing commands and aggregating events
- **Hardware_Manager**: The native component that owns the hardware context, manages peripheral lifecycles, and coordinates worker threads
- **Hardware_Context**: An opaque native struct holding all peripheral handles, thread references, shared buffers, and runtime state
- **Ring_Buffer**: A fixed-size, lock-free or mutex-protected circular buffer used for thread-safe data passing between native worker threads and the Native_API_Layer
- **Worker_Thread**: A background pthread that continuously monitors a hardware peripheral (UART RX, temperature, or GPIO interrupts)
- **Peripheral**: A hardware device accessed through a Linux subsystem (sysfs, gpiod, /dev/ttyS*, /dev/spidev*, /dev/i2c-*)
- **UART_Peripheral**: Serial communication peripheral accessed via Linux serial device files
- **I2C_Peripheral**: Inter-Integrated Circuit bus peripheral accessed via Linux i2c-dev
- **SPI_Peripheral**: Serial Peripheral Interface bus device accessed via Linux spidev
- **ADC_Peripheral**: Analog-to-Digital Converter abstraction for external ADC chips (e.g., ADS1115 over I2C, MCP3008 over SPI) since the Raspberry Pi 4B has no built-in ADC
- **GPIO_Peripheral**: General Purpose Input/Output pins accessed via libgpiod or sysfs
- **PWM_Peripheral**: Pulse Width Modulation output accessed via Linux sysfs PWM subsystem
- **Event_Batch**: A collection of hardware events (UART packets, temperature readings, GPIO state changes) fetched by Flutter in a single FFI call
- **Safety_Manager**: The native component responsible for watchdog timers, over-temperature protection, and emergency stop handling
- **Machine_Controller**: The native state machine governing the tube sealing process sequence
- **Log_Handler**: The native logging system that records diagnostic and error information
- **Component**: A self-contained native module following the three-layer pattern: platform-specific implementation, platform-agnostic manager, and public headers
- **CMake_Build_System**: The per-component and top-level CMake configuration that compiles native code into a shared library loadable by Dart FFI

## Requirements

### Requirement 1: Plugin Initialization and Lifecycle

**User Story:** As a Flutter application developer, I want to initialize the native hardware plugin through a single FFI call, so that all peripherals, threads, and shared buffers are set up atomically and the system is ready for operation.

#### Acceptance Criteria

1. WHEN the Flutter application calls the FFI initialization function, THE Native_API_Layer SHALL allocate a Hardware_Context, initialize all configured peripherals in parallel, start all Worker_Threads, and return a success or failure status code
2. WHEN the FFI initialization function succeeds, THE Native_API_Layer SHALL return an opaque handle to the Hardware_Context that Dart code uses for all subsequent FFI calls
3. IF a peripheral fails to initialize during startup, THEN THE Native_API_Layer SHALL log the failure via Log_Handler, skip the failed peripheral, and report partial initialization status with a bitmask indicating which peripherals succeeded
4. WHEN the Flutter application calls the FFI shutdown function with a valid Hardware_Context handle, THE Native_API_Layer SHALL set stop flags on all Worker_Threads, join all threads, close all peripheral file descriptors, free all Ring_Buffers, and deallocate the Hardware_Context
5. IF the FFI shutdown function is called with an invalid or null Hardware_Context handle, THEN THE Native_API_Layer SHALL return an invalid-handle error code without performing any cleanup
6. WHEN the FFI initialization function is called while a Hardware_Context already exists, THE Native_API_Layer SHALL return an already-initialized error code without creating a second context

### Requirement 2: Plugin Scaffold and Platform Support

**User Story:** As a Flutter plugin developer, I want the local plugin to be created via the `flutter create` command with FFI template and support both Linux and Windows platforms, so that the plugin follows Flutter's standard plugin conventions and can be developed/tested on Windows while deploying to Linux (RPi4B).

#### Acceptance Criteria

1. THE plugin SHALL be created using `flutter create --template=plugin_ffi --platforms=linux,windows` inside the project's `packages/` directory
2. THE plugin SHALL follow Flutter's standard FFI plugin structure with platform-specific native source directories (`linux/` and `windows/`) that integrate with the shared `src/` native code
3. THE plugin's `pubspec.yaml` SHALL declare both `linux` and `windows` under the `plugin.platforms` section with the correct FFI plugin class and file references
4. THE main Flutter application SHALL reference the plugin as a path dependency in its `pubspec.yaml`

### Requirement 3: Dart FFI Bridge and Bindings

**User Story:** As a Flutter application developer, I want type-safe Dart bindings to all native API functions, so that I can call native hardware functions from Dart without manual pointer arithmetic or unsafe casts.

#### Acceptance Criteria

1. THE FFI_Bridge SHALL load the native shared library (.so on Linux, .dll on Windows) at runtime using `DynamicLibrary.open` and expose all Native_API_Layer functions as typed Dart function references
2. THE FFI_Bridge SHALL define Dart `Struct` subclasses that mirror every C-ABI compatible struct exposed at the FFI boundary (Hardware_Context handle, Event_Batch, status codes, peripheral configuration structs). These native structs are declared with `extern "C"` linkage in C++ to ensure Dart FFI compatibility.
3. WHEN a native function returns an error code, THE FFI_Bridge SHALL translate the error code into a Dart-side enum value with a human-readable description
4. THE FFI_Bridge SHALL manage native memory allocation and deallocation for all structs passed across the FFI boundary, preventing memory leaks
5. IF the native shared library file is not found at the expected path, THEN THE FFI_Bridge SHALL throw a descriptive Dart exception indicating the missing library path

### Requirement 4: UART Serial Log and Report Output

**User Story:** As a machine diagnostics developer, I want to transmit machine logs, reports, and tube sealer details over UART serial to a connected mobile device, so that operators can view machine status and diagnostic information on their mobile phone.

#### Acceptance Criteria

1. WHEN the UART_Peripheral is initialized with a device path and baud rate, THE UART_Peripheral SHALL open the Linux serial device file, configure termios settings, and report success or failure
2. WHEN the Native_API_Layer receives a UART transmit command with log data, report data, or machine details, THE UART_Peripheral SHALL write the provided byte buffer to the serial device file descriptor and return the number of bytes written
3. THE UART_Peripheral SHALL support transmitting structured log messages, machine status reports, and tube sealer operational details as serialized byte payloads
4. IF the UART serial device file cannot be opened or becomes disconnected, THEN THE UART_Peripheral SHALL log the error via Log_Handler and set a peripheral-fault flag readable by the Native_API_Layer
5. THE UART_Peripheral SHALL support configurable baud rate, data bits, stop bits, parity, and flow control parameters at initialization time
6. THE Log_Handler SHALL support UART as an additional log output destination, allowing log entries to be automatically transmitted over serial to the connected mobile device

### Requirement 5: I2C Bus Communication

**User Story:** As a sensor integration developer, I want to read from and write to I2C bus devices, so that the application can interface with I2C-connected sensors and actuators on the sealing machine.

#### Acceptance Criteria

1. WHEN the I2C_Peripheral is initialized with a bus number and device address, THE I2C_Peripheral SHALL open the Linux i2c-dev device file and configure the target slave address
2. WHEN a read command is issued for a specific register address, THE I2C_Peripheral SHALL perform an I2C read transaction and return the read bytes to the caller
3. WHEN a write command is issued with a register address and data bytes, THE I2C_Peripheral SHALL perform an I2C write transaction and return success or failure
4. IF an I2C transaction fails due to bus error or NACK, THEN THE I2C_Peripheral SHALL return a specific error code indicating the failure type

### Requirement 6: SPI Bus Communication

**User Story:** As a sensor integration developer, I want to perform SPI transactions with bus devices, so that the application can interface with SPI-connected peripherals on the sealing machine.


#### Acceptance Criteria

1. WHEN the SPI_Peripheral is initialized with a bus number, chip select, clock speed, and SPI mode, THE SPI_Peripheral SHALL open the Linux spidev device file and configure the SPI parameters via ioctl
2. WHEN a full-duplex transfer command is issued with a transmit buffer, THE SPI_Peripheral SHALL perform the SPI transfer and return the received data buffer
3. IF an SPI transfer fails, THEN THE SPI_Peripheral SHALL return an error code indicating the failure reason

### Requirement 7: ADC Analog-to-Digital Conversion (External ADC)

**User Story:** As a sensor integration developer, I want to read analog voltage values from external ADC channels, so that the application can monitor analog sensors (e.g., pressure, position) on the sealing machine despite the Raspberry Pi 4B lacking a built-in ADC.

#### Acceptance Criteria

1. WHEN the ADC_Peripheral is initialized with an ADC chip type (e.g., ADS1115, MCP3008), bus configuration (I2C bus/address or SPI bus/chip-select), and channel number, THE ADC_Peripheral SHALL configure the underlying I2C_Peripheral or SPI_Peripheral to communicate with the external ADC chip
2. WHEN a read command is issued for an ADC channel, THE ADC_Peripheral SHALL send the appropriate register read or SPI transfer command to the external ADC chip and return the raw digital value along with the voltage scale factor
3. IF the ADC channel read fails or returns an out-of-range value, THEN THE ADC_Peripheral SHALL return an error code and the last known valid reading
4. THE ADC_Peripheral SHALL support at minimum ADS1115 (16-bit, I2C) and MCP3008 (10-bit, SPI) external ADC chips as configurable chip types

### Requirement 8: GPIO Input/Output Control

**User Story:** As a machine control developer, I want to configure and control GPIO pins for digital input and output, so that the application can read switches/sensors and drive indicators/actuators.

#### Acceptance Criteria

1. WHEN a GPIO pin is initialized with a pin number and direction (input or output), THE GPIO_Peripheral SHALL configure the pin using libgpiod or sysfs and report success or failure
2. WHEN a GPIO output write command is issued, THE GPIO_Peripheral SHALL set the specified pin to the requested logic level (high or low)
3. WHEN a GPIO input read command is issued, THE GPIO_Peripheral SHALL read and return the current logic level of the specified pin
4. WHILE the GPIO Worker_Thread is running, THE GPIO_Peripheral SHALL monitor configured interrupt-capable input pins and push state-change events into the GPIO Ring_Buffer
5. THE GPIO_Peripheral SHALL support configurable edge detection (rising, falling, both) for interrupt-monitored input pins

### Requirement 9: PWM Output Control

**User Story:** As a machine control developer, I want to control PWM outputs with configurable frequency and duty cycle, so that the application can drive heaters, motors, and other actuators requiring variable power control.

#### Acceptance Criteria

1. WHEN the PWM_Peripheral is initialized with a chip number, channel number, frequency, and duty cycle, THE PWM_Peripheral SHALL configure the Linux sysfs PWM interface and enable the output
2. WHEN a duty cycle update command is issued, THE PWM_Peripheral SHALL update the PWM duty cycle to the specified value within one PWM period
3. WHEN a frequency update command is issued, THE PWM_Peripheral SHALL update the PWM frequency to the specified value
4. WHEN a PWM disable command is issued, THE PWM_Peripheral SHALL set the duty cycle to zero and disable the PWM output
5. IF the PWM sysfs interface is not available for the specified chip and channel, THEN THE PWM_Peripheral SHALL return an error code indicating the unavailable PWM channel


### Requirement 10: Background Worker Threads and Shared Memory

**User Story:** As a Flutter application developer, I want hardware monitoring to run on background native threads with thread-safe shared memory, so that the Flutter UI thread is never blocked by hardware I/O and data integrity is maintained.

#### Acceptance Criteria

1. WHEN the Hardware_Manager starts Worker_Threads, THE Hardware_Manager SHALL create one pthread each for temperature monitoring and GPIO interrupt monitoring
2. THE Ring_Buffer SHALL use mutex-protected read and write operations to prevent data corruption when accessed concurrently by Worker_Threads and the Native_API_Layer
3. WHILE a Worker_Thread is running, THE Worker_Thread SHALL check a shared stop flag at each iteration and exit cleanly when the flag is set
4. IF a Ring_Buffer becomes full, THEN THE Ring_Buffer SHALL overwrite the oldest entry and increment a dropped-event counter accessible to the Native_API_Layer
5. THE Ring_Buffer SHALL maintain a monotonically increasing sequence number for each entry so that the consumer can detect dropped events

### Requirement 11: Pull-Based Event Batching

**User Story:** As a Flutter application developer, I want to periodically fetch batched hardware events from the native layer in a single FFI call, so that the UI can efficiently process multiple events per frame without excessive FFI call overhead.

#### Acceptance Criteria

1. WHEN the Flutter application calls the poll-events FFI function, THE Native_API_Layer SHALL drain all available events from all Ring_Buffers (temperature, GPIO) into a single Event_Batch struct and return the batch to the caller
2. THE Event_Batch SHALL contain a count of events per type (temperature readings, GPIO events) and a flat array of event records with type tags and timestamps
3. WHEN no events are available in any Ring_Buffer, THE Native_API_Layer SHALL return an empty Event_Batch with zero counts
4. THE Native_API_Layer SHALL serialize Event_Batch data into a contiguous memory layout that Dart can read directly through FFI pointer access without additional native calls

### Requirement 12: Temperature Monitoring

**User Story:** As a safety system developer, I want continuous temperature monitoring on a background thread, so that the application can track heater temperatures and detect over-temperature conditions in real time.

#### Acceptance Criteria

1. WHILE the temperature monitor Worker_Thread is running, THE Worker_Thread SHALL read temperature sensor values at a configurable sampling interval and push readings into the temperature Ring_Buffer
2. WHEN a temperature reading exceeds a configured high threshold, THE Worker_Thread SHALL push an over-temperature alert event into the Ring_Buffer with the sensor identifier and measured value
3. WHEN a temperature reading falls below a configured low threshold, THE Worker_Thread SHALL push an under-temperature alert event into the Ring_Buffer with the sensor identifier and measured value
4. IF the temperature sensor becomes unresponsive or returns an invalid reading, THEN THE Worker_Thread SHALL push a sensor-fault event into the Ring_Buffer and continue monitoring at the next interval

### Requirement 13: Safety Manager

**User Story:** As a safety system developer, I want a native safety manager that enforces hardware safety constraints independently of the Flutter application, so that critical safety responses (emergency stop, over-temperature shutdown) occur with minimal latency even if the Dart layer is unresponsive.

#### Acceptance Criteria

1. THE Safety_Manager SHALL run safety checks on the native side without requiring any Dart-layer involvement for time-critical safety responses
2. WHEN an over-temperature condition persists for longer than a configured timeout, THE Safety_Manager SHALL disable the associated PWM heater output and push an emergency-shutdown event into the Ring_Buffer
3. WHEN an emergency stop signal is detected on a configured GPIO input pin, THE Safety_Manager SHALL immediately disable all actuator outputs and set a system-halted flag
4. WHILE the system-halted flag is set, THE Native_API_Layer SHALL reject all actuator commands and return a system-halted error code
5. WHEN a watchdog timer expires without being refreshed by the Flutter application, THE Safety_Manager SHALL trigger a safe shutdown of all actuator outputs
6. IF the Safety_Manager detects multiple simultaneous fault conditions, THEN THE Safety_Manager SHALL prioritize emergency stop handling over individual fault responses

### Requirement 14: Machine Controller State Machine

**User Story:** As a sealing process developer, I want a native state machine that governs the tube sealing sequence, so that the sealing process follows a deterministic sequence of steps with proper safety interlocks.

#### Acceptance Criteria

1. THE Machine_Controller SHALL implement a state machine with defined states for: idle, preheat, seal, cool-down, complete, and fault
2. WHEN a state transition command is received, THE Machine_Controller SHALL validate that the transition is permitted from the current state before executing the transition
3. IF an invalid state transition is requested, THEN THE Machine_Controller SHALL reject the command and return an error code indicating the current state and the disallowed target state
4. WHILE the Machine_Controller is in the seal state, THE Machine_Controller SHALL monitor seal parameters (temperature, pressure, time) and transition to cool-down when seal criteria are met
5. IF a fault condition is detected during any active state (preheat, seal, cool-down), THEN THE Machine_Controller SHALL transition to the fault state and command the Safety_Manager to disable actuator outputs

### Requirement 15: Native Logging System

**User Story:** As a diagnostics developer, I want a native logging system that records events with severity levels and timestamps, so that hardware-level issues can be diagnosed without relying on Dart-side logging.

#### Acceptance Criteria

1. THE Log_Handler SHALL support log levels of: error, warning, info, and debug
2. WHEN a log message is recorded, THE Log_Handler SHALL include a timestamp, log level, component name, and message string
3. THE Log_Handler SHALL write log entries to a configurable output (stderr, file, or Ring_Buffer readable by Dart)
4. WHILE the log level is set to a given severity, THE Log_Handler SHALL suppress all messages below that severity level
5. THE Log_Handler SHALL be callable from any native thread without causing data races or deadlocks

### Requirement 16: CMake Build System and Component Structure

**User Story:** As a plugin developer, I want each native component to be a self-contained CMake target with a consistent three-layer file structure, supporting both Linux and Windows builds, so that components can be built, tested, and maintained independently on either platform.

#### Acceptance Criteria

1. THE CMake_Build_System SHALL define a top-level CMakeLists.txt that discovers and builds all Component subdirectories under the components/ folder
2. THE CMake_Build_System SHALL produce a single shared library (.so on Linux, .dll on Windows) file that the FFI_Bridge loads at runtime
3. WHEN a new Component is added to the components/ directory with a CMakeLists.txt, THE CMake_Build_System SHALL automatically include the new Component in the build without modifying the top-level CMakeLists.txt
4. THE CMake_Build_System SHALL support cross-compilation for ARM-based Linux targets via a configurable CMake toolchain file
5. WHEN a Component is compiled, THE CMake_Build_System SHALL enforce that the Component's public headers are in an include/ subdirectory and the Component exposes only its public API symbols
6. THE CMake_Build_System SHALL integrate with Flutter's platform-specific build systems: the `linux/CMakeLists.txt` and `windows/CMakeLists.txt` generated by `flutter create` SHALL include the shared `src/CMakeLists.txt` so that the same native source compiles on both platforms
7. ON Windows, THE CMake_Build_System SHALL use Windows threading APIs (CreateThread / _beginthreadex) or C++ std::thread as the threading backend, while on Linux it SHALL use pthreads

### Requirement 17: Event Serialization Round-Trip

**User Story:** As a plugin developer, I want to verify that hardware events serialized into the Event_Batch memory layout can be deserialized back to equivalent Dart objects, so that no data is lost or corrupted crossing the FFI boundary.

#### Acceptance Criteria

1. THE Native_API_Layer SHALL serialize each hardware event (temperature reading, GPIO event) into a tagged binary format within the Event_Batch memory region
2. THE FFI_Bridge SHALL deserialize Event_Batch binary data back into typed Dart event objects
3. FOR ALL valid hardware events, serializing an event to the Event_Batch binary format and then deserializing the binary data back SHALL produce a Dart event object with field values equivalent to the original native event (round-trip property)
4. IF the Event_Batch binary data contains an unrecognized event type tag, THEN THE FFI_Bridge SHALL skip the unrecognized event, log a warning, and continue deserializing remaining events
