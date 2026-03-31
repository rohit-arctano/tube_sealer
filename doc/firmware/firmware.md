sequenceDiagram
    autonumber
    participant Ctrl as Main Control / State Machine
    participant Recipe as Recipe Parameter Calculator
    participant Safety as Safety / Interlock Manager
    participant Thermal as Thermal Controller
    participant Temp as 4x Temperature Sensor Manager
    participant Motion as Motion / Block Controller
    participant LVDT as LVDT / Displacement Manager
    participant Lock as Door / Solenoid Lock Manager
    participant Fan as Cooling Controller
    participant Fault as Fault Manager
    participant Life as Lifecycle Manager
    participant Record as Cycle Record Manager
    participant Store as Local Persistent Storage
    participant Heater as Mica Heater PWM
    participant Motor as Motor Driver PWM
    participant Door as Door Closed Sensor
    participant Emer as Emergency Input

    rect rgb(245,245,245)
    Note over Ctrl,Store: Initialization and Background Monitoring
    Ctrl->>Safety: initialize_inputs_outputs()
    Ctrl->>Thermal: initialize_thermal_subsystem()
    Ctrl->>Motion: initialize_motion_subsystem()
    Ctrl->>Lock: initialize_lock_subsystem()
    Ctrl->>Life: load_lifecycle_counters()
    Life->>Store: read lifecycle counters and thresholds
    Store-->>Life: counters loaded
    Ctrl->>Record: initialize_cycle_recording()
    Record->>Store: open local storage
    Store-->>Record: storage ready

    par Thermal monitoring loop
        loop periodic
            Temp->>Temp: read BlockA_S1, BlockA_S2, BlockB_S1, BlockB_S2
            Temp->>Temp: validate range, drift, agreement
            Temp-->>Thermal: filtered temperatures and sensor health
            Thermal->>Thermal: compute effective block temperatures
            Thermal->>Thermal: evaluate over-temp and imbalance
        end
    and Safety monitoring loop
        loop periodic / interrupt
            Safety->>Door: read door closed state
            Door-->>Safety: door status
            Safety->>Emer: read emergency input
            Emer-->>Safety: emergency status
            Safety->>Lock: read lock feedback
            Lock-->>Safety: lock state
            Safety->>Safety: evaluate safe operating condition
        end
    and Motion monitoring loop
        loop periodic
            Motion->>LVDT: read displacement and touch state
            LVDT-->>Motion: filtered displacement
            Motion->>Motion: evaluate home, travel, stall, mismatch
        end
    end
    end

    rect rgb(235,245,255)
    Note over Ctrl,Store: Start Cycle Preparation
    Ctrl->>Safety: check_machine_ready()
    Safety-->>Ctrl: ready / blocked / emergency / active fault

    alt Machine not ready
        Safety->>Fault: raise_fault_or_block()
        Fault->>Record: append event with timestamp
        Record->>Store: save event
    else Machine ready
        Ctrl->>Life: check_maintenance_status()
        Life-->>Ctrl: ok / warning / due

        alt Maintenance due
            Life->>Fault: raise_fault(MAINTENANCE_DUE)
            Fault->>Record: append fault with timestamp
            Record->>Store: save fault
        else Continue
            Ctrl->>Recipe: calculate_cycle_parameters()
            Recipe-->>Ctrl: target temperature, tolerance, preheat, hold time, cooling time, travel target, motion profile
            Ctrl->>Record: open cycle record
            Record->>Store: save cycle start timestamp and metadata
        end
    end
    end

    rect rgb(245,255,235)
    Note over Ctrl,Store: Preheat Phase
    alt Preheat required
        Ctrl->>Thermal: start_preheat(target temperatures)
        loop until stable or timeout
            Thermal->>Temp: request latest validated temperatures
            Temp-->>Thermal: block temperatures
            Thermal->>Thermal: compare against target and tolerance
            Thermal->>Heater: update PWM duty
            Heater-->>Thermal: heater applied
            Thermal-->>Ctrl: progress / stable / warning / timeout

            alt Temperature warning
                Thermal->>Fault: raise_warning(TEMP_DRIFT or BLOCK_IMBALANCE)
                Fault->>Record: append warning with timestamp
                Record->>Store: save warning
            end
        end

        alt Preheat fault
            Thermal->>Fault: raise_fault(PREHEAT_TIMEOUT or OVER_TEMP or SENSOR_FAULT or TEMP_MISMATCH)
            Fault->>Ctrl: abort cycle
            Ctrl->>Heater: set PWM 0
            Ctrl->>Motor: stop
            Ctrl->>Fan: safe cooling if required
            Fault->>Record: append fault with timestamp
            Record->>Store: save fault
        else Preheat stable
            Thermal-->>Ctrl: preheat satisfied
        end
    else Preheat skipped
        Ctrl->>Record: append event(preheat skipped)
        Record->>Store: save event
    end
    end

    rect rgb(255,250,235)
    Note over Ctrl,Store: Load and Door Verification
    Ctrl->>Lock: release_solenoid_lock()
    Lock-->>Ctrl: released / failed

    alt Lock release failed
        Lock->>Fault: raise_fault(LOCK_RELEASE_FAIL)
        Ctrl->>Heater: safe hold or off
        Ctrl->>Motor: stop
        Fault->>Record: append fault with timestamp
        Record->>Store: save fault
    else Waiting for operator loading and manual door close
        loop until door closed or timeout
            Safety->>Door: read door state
            Door-->>Safety: open / closed
            Safety-->>Ctrl: door status
        end

        alt Door close timeout
            Safety->>Fault: raise_warning_or_fault(DOOR_CLOSE_TIMEOUT)
            Fault->>Record: append event with timestamp
            Record->>Store: save event
        else Door closed
            Ctrl->>Safety: verify_interlocks()
            Safety-->>Ctrl: verified / failed
        end

        alt Interlock failed
            Safety->>Fault: raise_fault(DOOR_INVALID or LOCK_INVALID or EMERGENCY_ACTIVE)
            Ctrl->>Heater: safe state
            Ctrl->>Motor: stop
            Fault->>Record: append fault with timestamp
            Record->>Store: save fault
        else Interlock ok
            Ctrl->>Record: append event(load verified)
            Record->>Store: save event
        end
    end
    end

    rect rgb(235,255,250)
    Note over Ctrl,Store: Motion, Touch Detection, Sealing Position
    Ctrl->>Motion: start_motion_profile(target travel, speed)
    Motion->>Motor: drive PWM output
    loop while motion active
        Motion->>LVDT: read displacement
        LVDT-->>Motion: displacement and touch indication
        Motion->>Motion: compare actual vs target
        Motion-->>Ctrl: progress / touch / reached / deviation / stall

        Ctrl->>Thermal: maintain sealing temperature
        Thermal->>Temp: read validated temperatures
        Temp-->>Thermal: live temperatures
        Thermal->>Heater: adjust PWM

        alt Motion warning
            Motion->>Fault: raise_warning(DISPLACEMENT_DRIFT_WARNING)
            Fault->>Record: append warning with timestamp
            Record->>Store: save warning
        end

        alt Motion fault
            Motion->>Fault: raise_fault(MOTOR_STALL or TRAVEL_TIMEOUT or OVERSHOOT or LVDT_FAULT or POSITION_MISMATCH)
            Ctrl->>Motor: stop
            Ctrl->>Heater: safe state
            Ctrl->>Fan: safe cooling if required
            Fault->>Record: append fault with timestamp
            Record->>Store: save fault
        else Target reached
            Motion->>Motor: stop PWM
            Motion-->>Ctrl: sealing position achieved
        end
    end

    Ctrl->>Record: append displacement confirmation
    Record->>Store: save displacement result
    end

    rect rgb(250,245,255)
    Note over Ctrl,Store: Seal Hold and Cooling
    Ctrl->>Thermal: hold_temperature_for_seal_duration()
    loop hold period
        Thermal->>Temp: read temperatures
        Temp-->>Thermal: validated values
        Thermal->>Thermal: maintain control band
        Thermal->>Heater: adjust PWM
        Thermal-->>Ctrl: hold progress / excursion / fault

        alt Thermal fault during hold
            Thermal->>Fault: raise_fault(OVER_TEMP or TEMP_DROP or SENSOR_FAILURE or BLOCK_IMBALANCE)
            Ctrl->>Heater: set PWM 0
            Ctrl->>Motor: stop
            Ctrl->>Fan: start safe cooling
            Fault->>Record: append fault with timestamp
            Record->>Store: save fault
        end
    end

    Ctrl->>Heater: set PWM 0
    Ctrl->>Fan: start cooling

    loop cooling phase
        Fan->>Fan: control cooling PWM
        Thermal->>Temp: monitor cooldown trend
        Temp-->>Thermal: temperatures
        Thermal-->>Ctrl: cooling progress / safe release / abnormal

        alt Cooling warning
            Thermal->>Fault: raise_warning(COOLING_SLOW_WARNING)
            Fault->>Record: append warning with timestamp
            Record->>Store: save warning
        end

        alt Cooling fault
            Thermal->>Fault: raise_fault(COOLING_FAILURE or OVER_TEMP_PERSIST)
            Ctrl->>Fan: max cooling or safe shutdown
            Fault->>Record: append fault with timestamp
            Record->>Store: save fault
        else Cooling complete
            Thermal-->>Ctrl: release condition satisfied
        end
    end
    end

    rect rgb(245,255,245)
    Note over Ctrl,Store: Return, Finalize Record, Lifecycle Update
    Ctrl->>Motion: return_block_to_safe_position()
    Motion->>Motor: drive return motion
    Motion->>LVDT: verify return displacement
    LVDT-->>Motion: home / return result
    Motion->>Motor: stop

    alt Return failed
        Motion->>Fault: raise_fault(RETURN_HOME_FAIL)
        Fault->>Record: append fault with timestamp
        Record->>Store: save fault
    else Return ok
        Ctrl->>Lock: set release / unlock state as designed
        Lock-->>Ctrl: unlock complete
    end

    Ctrl->>Record: finalize cycle record
    Record->>Store: save sealing temperature, sealing duration, displacement confirmation, warnings, alarms, timestamps, cycle result, cycle count
    Store-->>Record: record committed

    Ctrl->>Life: increment lifecycle counters()
    Life->>Store: save heater, motor, lock, fan, and cycle counters
    Store-->>Life: lifecycle saved
    Life-->>Ctrl: maintenance status updated

    alt Threshold crossed
        Life->>Fault: raise_warning(MAINTENANCE_DUE_SOON or PART_REPLACEMENT_DUE)
        Fault->>Record: append maintenance warning
        Record->>Store: save warning
    end
    end

    rect rgb(255,235,235)
    Note over Ctrl,Store: Emergency Handling at Any Time
    Safety->>Emer: detect emergency input
    Emer-->>Safety: active
    Safety->>Fault: raise_fault(EMERGENCY_STOP)
    Fault->>Ctrl: immediate stop request
    Ctrl->>Heater: set PWM 0 immediately
    Ctrl->>Motor: stop immediately
    Ctrl->>Fan: emergency cooling if needed
    Ctrl->>Lock: move to predefined safe state
    Fault->>Record: append emergency event with timestamp
    Record->>Store: save emergency event
    end