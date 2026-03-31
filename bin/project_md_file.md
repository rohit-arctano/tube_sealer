sequenceDiagram
    autonumber

    participant User
    participant FlutterUI as Flutter UI
    participant MainIsolate as Main Isolate
    participant BgIsolate as Background Isolate
    participant FFI as Dart FFI Bridge
    participant NativeAPI as Native C/C++ API Layer
    participant HWManager as Hardware Manager
    participant UartThread as UART RX Thread
    participant TempThread as Temp Monitor Thread
    participant GpioThread as GPIO/Interrupt Thread
    participant SharedMem as Shared Memory / Ring Buffer / Queue
    participant UART as UART Peripheral
    participant TEMP as SPI/I2C Temp Sensor
    participant GPIO as GPIO / Input Pins
    participant PWM as PWM Output
    participant I2C as I2C Bus Devices
    participant SPI as SPI Bus Devices

    User->>FlutterUI: Open app / start machine control
    FlutterUI->>MainIsolate: Initialize app state
    MainIsolate->>FFI: init_native_system()
    FFI->>NativeAPI: Call native init
    NativeAPI->>HWManager: Create hardware context
    HWManager->>HWManager: Init mutex / queues / callbacks / state flags

    par Native initialization
        HWManager->>UART: Open UART port + configure baudrate
        and
        HWManager->>GPIO: Configure GPIO directions / pull-up / pull-down
        and
        HWManager->>PWM: Configure PWM channel / frequency / duty
        and
        HWManager->>I2C: Init I2C bus
        and
        HWManager->>SPI: Init SPI bus
    end

    HWManager->>UartThread: Start continuous UART RX worker
    HWManager->>TempThread: Start periodic temperature monitor worker
    HWManager->>GpioThread: Start GPIO polling / interrupt worker

    NativeAPI-->>FFI: init success
    FFI-->>MainIsolate: native ready
    MainIsolate-->>FlutterUI: Show hardware connected status

    loop Continuous UART RX
        UartThread->>UART: read()
        UART-->>UartThread: incoming bytes / packets
        UartThread->>SharedMem: push UART packet into RX buffer
        SharedMem-->>NativeAPI: data available flag / notify
    end

    loop Continuous temperature monitoring
        TempThread->>TEMP: read temperature over SPI/I2C
        TEMP-->>TempThread: temperature value
        TempThread->>SharedMem: store latest temperature
        SharedMem-->>NativeAPI: temperature updated flag
    end

    loop GPIO monitoring
        GpioThread->>GPIO: poll input or wait interrupt
        GPIO-->>GpioThread: pin state change
        GpioThread->>SharedMem: push pin event/state
        SharedMem-->>NativeAPI: gpio event available
    end

    loop UI periodic fetch or callback-driven update
        MainIsolate->>FFI: get_system_events() / get_latest_status()
        FFI->>NativeAPI: fetch buffered events/status
        NativeAPI->>SharedMem: pop UART data / temp / gpio states
        SharedMem-->>NativeAPI: batched events
        NativeAPI-->>FFI: structured native response
        FFI-->>MainIsolate: Dart model / raw bytes
        MainIsolate->>BgIsolate: optional parse / heavy decode
        BgIsolate-->>MainIsolate: parsed data
        MainIsolate-->>FlutterUI: update UI widgets / charts / logs
    end

    User->>FlutterUI: Send command
    FlutterUI->>MainIsolate: User action event
    MainIsolate->>FFI: send_command(command)
    FFI->>NativeAPI: forward command
    NativeAPI->>HWManager: route command to proper peripheral

    alt UART transmit command
        HWManager->>UART: write(tx bytes)
        UART-->>HWManager: tx result
    else GPIO output command
        HWManager->>GPIO: set pin high/low
        GPIO-->>HWManager: pin set done
    else PWM control command
        HWManager->>PWM: set duty/frequency
        PWM-->>HWManager: pwm updated
    else I2C device command
        HWManager->>I2C: read/write register
        I2C-->>HWManager: response
    else SPI device command
        HWManager->>SPI: transfer frame
        SPI-->>HWManager: response
    end

    HWManager-->>NativeAPI: command result
    NativeAPI-->>FFI: success / failure / payload
    FFI-->>MainIsolate: response
    MainIsolate-->>FlutterUI: show result

    User->>FlutterUI: Close app / stop service
    FlutterUI->>MainIsolate: dispose request
    MainIsolate->>FFI: shutdown_native_system()
    FFI->>NativeAPI: shutdown
    NativeAPI->>HWManager: set stop flags
    HWManager->>UartThread: join thread
    HWManager->>TempThread: join thread
    HWManager->>GpioThread: join thread
    HWManager->>UART: close
    HWManager->>I2C: close
    HWManager->>SPI: close
    NativeAPI-->>FFI: shutdown complete
    FFI-->>MainIsolate: done
    MainIsolate-->>FlutterUI: app closed safely