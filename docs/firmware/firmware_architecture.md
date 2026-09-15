# ATFIDP Firmware Architecture

## 1. Purpose

The ATFIDP firmware provides the embedded flight-computer implementation of the platform.

It is designed around a modular C architecture in which sensing, health monitoring, flight processing, mission processing, telemetry generation, logging, scheduling, and UART transport are separated into independent modules.

The current target is an **STM32F446RETx** using STM32CubeMX-generated initialization and the STM32 HAL.

The firmware currently provides:

- Deterministic flight-data acquisition
- Flight-state management
- Basic health monitoring
- Flight-controller interface
- Mission-management interface
- Binary telemetry generation
- CRC-16 telemetry verification
- USART2 telemetry transmission
- Structured logging
- Periodic scheduler execution

---

## 2. Firmware Architecture

```text
                         STM32F446RETx
                                │
                                ▼
                             main.c
                                │
                                ▼
                           Scheduler
                                │
             ┌──────────────────┼──────────────────┐
             │                  │                  │
             ▼                  ▼                  ▼
          Sensor          Health Monitor    Flight Controller
             │                  │                  │
             └──────────────────┼──────────────────┘
                                │
                                ▼
                         Mission Manager
                                │
                                ▼
                           Telemetry
                                │
                    ┌───────────┴───────────┐
                    │                       │
                    ▼                       ▼
              CRC Verification        Packet Buffer
                    │
                    ▼
                 USART2
                    │
                    ▼
             UART Transmission
```

The scheduler acts as the application-level coordinator.

Individual modules do not directly control the complete application flow. Instead, the scheduler invokes them in a deterministic sequence.

---

## 3. Software Modules

| Module | Responsibility |
|---|---|
| `main.c` | Hardware initialization and main application loop |
| `scheduler.c` | Controls periodic application execution |
| `sensor.c` | Updates flight-data inputs |
| `health_monitor.c` | Evaluates basic health conditions |
| `flight_controller.c` | Provides the flight-control processing interface |
| `mission.c` | Provides mission-execution logic |
| `telemetry.c` | Serializes flight data and calculates/verifies CRC |
| `telemetry_uart.c` | Provides UART transport through STM32 HAL |
| `logger.c` | Provides diagnostic and hexadecimal packet logging |
| `flight_data.h` | Defines the common flight-state data structure |

This separation allows individual modules to be modified or replaced without restructuring the entire application.

---

## 4. Main Application Flow

The STM32 startup sequence initializes the hardware peripherals and then initializes the ATFIDP software modules.

```text
STM32 Startup
      │
      ▼
HAL Initialization
      │
      ▼
System Clock Configuration
      │
      ▼
GPIO Initialization
      │
      ▼
USART2 Initialization
      │
      ▼
ATFIDP Module Initialization
      │
      ├── Logger
      ├── Sensor
      ├── Health Monitor
      ├── Flight Controller
      ├── Telemetry
      ├── Mission Manager
      ├── Scheduler
      └── Telemetry UART
      │
      ▼
Main Loop
```

The main loop repeatedly calls the scheduler and waits for the next execution period.

```c
while (1)
{
    scheduler_run(&flight_data);

    HAL_Delay(1000);
}
```

The current implementation therefore operates as a simple periodic flight-computer loop.

---

## 5. Scheduler

The scheduler is the central application-level coordinator.

Its current execution sequence is:

```text
scheduler_run()
      │
      ▼
sensor_update()
      │
      ▼
Timestamp Update
      │
      ▼
health_monitor_update()
      │
      ▼
flight_controller_update()
      │
      ▼
mission_run()
      │
      ▼
telemetry_build_packet()
      │
      ▼
telemetry_verify_packet()
      │
      ▼
telemetry_uart_send()
```

This ordering establishes a clear data dependency:

**Acquire → Evaluate → Process → Serialize → Verify → Transmit**

The scheduler also owns the telemetry sequence counter and telemetry packet buffer used during packet construction.

---

## 6. Flight Data Model

The modules communicate through a shared `FlightData` structure.

```c
typedef struct
{
    float temperature_c;
    float altitude_m;
    float velocity_mps;
    float battery_v;
    uint32_t timestamp_s;
    FlightStatus status;
} FlightData;
```

The structure contains:

| Field | Purpose |
|---|---|
| `temperature_c` | Vehicle/environment temperature |
| `altitude_m` | Current altitude |
| `velocity_mps` | Current velocity |
| `battery_v` | Battery voltage |
| `timestamp_s` | Elapsed system time |
| `status` | Health state |

The status enumeration is:

```c
typedef enum
{
    FLIGHT_STATUS_OK = 0,
    FLIGHT_STATUS_WARNING,
    FLIGHT_STATUS_CRITICAL
} FlightStatus;
```

Using a shared data model keeps module interfaces explicit and avoids passing individual parameters between every subsystem.

---

## 7. Sensor Module

The sensor module is responsible for updating the `FlightData` structure.

The current implementation uses deterministic values:

```text
Temperature : 25.0 °C
Altitude    : 1000.0 m
Velocity    : 120.0 m/s
Battery     : 24.0 V
```

This is a software-development abstraction rather than a physical sensor driver.

The module interface is intentionally simple:

```c
void sensor_init(void);
void sensor_update(FlightData *data);
```

Future implementations can replace these deterministic assignments with actual ADC, I2C, SPI, UART, or other sensor interfaces without changing the scheduler interface.

---

## 8. Health Monitor

The health monitor evaluates basic flight-data limits.

Current thresholds include:

```text
Battery < 20.0 V       → WARNING
Temperature > 80.0 °C  → CRITICAL
Otherwise              → OK
```

The module updates the status field of `FlightData`.

```text
FlightData
    │
    ├── Battery Voltage
    │        │
    │        └── < 20 V → WARNING
    │
    └── Temperature
             │
             └── > 80 °C → CRITICAL
```

The health-monitoring logic is intentionally simple in the current implementation and provides a foundation for future fault-management expansion.

---

## 9. Flight Controller

The flight-controller module provides the interface where flight-control processing can be integrated.

Current interface:

```c
void flight_controller_init(void);
void flight_controller_update(const FlightData *data);
```

The current implementation logs the update event rather than implementing a closed-loop actuator-control algorithm.

This boundary allows future integration of:

- Attitude estimation
- Guidance logic
- Control laws
- Actuator commands
- Navigation data
- Sensor fusion

without changing the overall scheduler structure.

---

## 10. Mission Manager

The mission module provides a separate boundary for mission-execution logic.

Current interface:

```c
void mission_init(void);
void mission_run(void);
```

The current implementation reports that the mission is running.

The separation is intentional because mission logic can later evolve into a state machine containing phases such as:

```text
Initialization
      │
      ▼
Pre-Launch
      │
      ▼
Launch
      │
      ▼
Powered Flight
      │
      ▼
Coast
      │
      ▼
Descent
      │
      ▼
Recovery / End
```

These states are architectural extension points rather than implemented flight states in the current firmware.

---

## 11. Telemetry Module

The telemetry module converts the internal `FlightData` representation into a fixed binary packet.

Its primary interface is:

```c
uint16_t telemetry_build_packet(
    const FlightData *data,
    uint32_t sequence,
    uint8_t *buffer,
    uint16_t buffer_size
);
```

The module performs:

1. Argument validation
2. Buffer-size validation
3. Field serialization
4. Scaling of floating-point values
5. CRC-16 calculation
6. CRC insertion
7. Packet-length return

The resulting packet is 22 bytes.

```text
FlightData
    │
    ▼
Quantization
    │
    ▼
Binary Serialization
    │
    ▼
CRC-16
    │
    ▼
22-byte Packet
```

Detailed packet structure is documented in:

`docs/telemetry/telemetry_protocol.md`

---

## 12. Telemetry Verification

Before transmission, the scheduler verifies the constructed packet.

```text
Packet Built
     │
     ▼
Length Check
     │
     ▼
Sync Check
     │
     ▼
Version Check
     │
     ▼
CRC Check
     │
 ┌───┴───┐
 ▼       ▼
PASS    FAIL
 │       │
 ▼       ▼
UART    Reject
```

This creates a local software integrity boundary before the packet is passed to the UART transport layer.

---

## 13. UART Interface

The UART interface isolates STM32 HAL transport details from the telemetry module.

Interface:

```c
void telemetry_uart_init(void);

uint8_t telemetry_uart_send(
    const uint8_t *data,
    uint16_t length
);
```

The current configuration uses USART2:

| Parameter | Value |
|---|---|
| Peripheral | USART2 |
| Baud Rate | 115200 |
| Data Bits | 8 |
| Parity | None |
| Stop Bits | 1 |
| Flow Control | None |

The transmission function uses:

```c
HAL_UART_Transmit()
```

and reports transmission success or failure to the application layer.

Physical UART electrical transmission was not experimentally verified because physical STM32 hardware and an external receiver were not available.

---

## 14. Logging

The logger provides a lightweight diagnostic interface.

Current functions include:

```c
void logger_init(void);
void logger_info(const char *message);
void logger_log(const char *message);
void logger_hex_dump(const uint8_t *data, uint16_t length);
```

The hexadecimal dump is particularly useful for telemetry development because it exposes the exact bytes generated by the serializer.

Example:

```text
[HEX] 55 AA 01 00 00 00 00 00 00 00 00 FA 00 E8 03 B0 04 60 09 00 18 13
```

This provides a direct bridge between embedded packet generation and host-side protocol verification.

---

## 15. Error Handling

The current firmware uses explicit return values and defensive pointer checks for key module interfaces.

Examples include:

```text
NULL data pointer
        │
        ▼
Error Log
        │
        ▼
Return Without Processing
```

Telemetry construction additionally checks whether the supplied output buffer is large enough for the fixed packet.

UART transmission reports a failure when the STM32 HAL transmission call does not return `HAL_OK`.

The current implementation does not yet provide a centralized fault-recovery manager or persistent fault/event storage.

---

## 16. Memory and Build Verification

The firmware was successfully compiled for the STM32 target with:

```text
Build Finished.
0 errors, 0 warnings.
```

The resulting ELF image reported:

```text
text    data    bss    dec    hex
15668   104     2040   17812  4594
```

The firmware therefore has a verified build artifact and a measurable compiled image.

Selected application symbols include:

```text
flight_controller_init
flight_controller_update
health_monitor_init
health_monitor_update
logger_init
logger_info
logger_hex_dump
mission_init
mission_run
scheduler_init
scheduler_run
sensor_init
sensor_update
telemetry_init
telemetry_build_packet
telemetry_verify_packet
telemetry_uart_init
telemetry_uart_send
```

The `.debug_*` sections shown by ELF section reports are debugging information and are not treated as runtime program memory.

---

## 17. Module Dependency Flow

The high-level software dependency relationship is:

```text
                         main.c
                           │
                           ▼
                       scheduler
                           │
       ┌───────────┬───────┼────────┬─────────────┐
       │           │       │        │             │
       ▼           ▼       ▼        ▼             ▼
     sensor     health   flight   mission     telemetry
                           │                    │
                           │                    ▼
                           │              telemetry_uart
                           │                    │
                           └────────────────────┘
                                      │
                                      ▼
                                    USART2

                        logger
                          ▲
                          │
                 Used by application modules
```

The telemetry module depends on the flight-data definition and logger, while the UART module isolates the hardware transport implementation.

---

## 18. Design Characteristics

The firmware architecture intentionally favors:

- Small modules
- Explicit interfaces
- Deterministic execution
- Minimal coupling
- Static data structures
- Clear data ownership
- Testable serialization
- Hardware-abstraction boundaries

The current implementation is not intended to represent a complete flight-qualified flight computer.

It is a development and verification platform demonstrating how flight-data processing, health monitoring, mission logic, telemetry, and embedded transport can be organized into a coherent firmware architecture.

---

## 19. Verification Status

The firmware architecture has been verified through:

- STM32 project generation and configuration
- Successful firmware compilation
- Zero compiler errors
- Zero compiler warnings
- Integration of all application modules
- Telemetry packet generation
- CRC verification
- UART HAL integration
- Host-side telemetry verification

The telemetry reference packet was independently decoded using Python and produced matching received and calculated CRC values.

Physical hardware execution and electrical UART verification remain outside the current verification boundary.

---

## 20. Future Firmware Extensions

The architecture provides clear integration points for future development:

```text
Current Architecture
        │
        ├── Real Sensor Drivers
        │
        ├── IMU / GPS
        │
        ├── RTOS Tasks
        │
        ├── Watchdog Supervision
        │
        ├── Fault Manager
        │
        ├── Mission State Machine
        │
        ├── Telecommand Handling
        │
        ├── RF Transceiver Driver
        │
        └── Hardware-in-the-Loop
```

These extensions can be introduced without fundamentally restructuring the existing module boundaries.

---

## 21. Summary

The ATFIDP firmware implements a modular embedded flight-computer architecture around the STM32F446RETx.

The central runtime path is:

```text
Sensor
  │
  ▼
FlightData
  │
  ▼
Health Monitor
  │
  ▼
Flight Controller
  │
  ▼
Mission Manager
  │
  ▼
Telemetry Serializer
  │
  ▼
CRC Verification
  │
  ▼
USART2
```

The architecture establishes a clear separation between application logic, telemetry processing, and hardware transport while providing measurable build and protocol-verification evidence.

It forms the embedded implementation layer of the larger ATFIDP MATLAB, Simulink, OpenRocket, and host-verification environment.