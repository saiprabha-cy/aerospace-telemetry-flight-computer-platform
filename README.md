# Aerospace Telemetry, Flight Computer & Instrumentation Development Platform

A software-first aerospace systems platform integrating **flight instrumentation, flight-computer logic, telemetry packetization, embedded STM32 firmware, MATLAB/Simulink simulation, OpenRocket trajectory data, and Python-based telemetry verification** into one end-to-end engineering workflow.

**Status:** Completed — Integrated and Verified

---

## Why This Project

A flight computer is not simply a microcontroller reading sensors.

A useful aerospace flight-computer development workflow must connect:

**Flight Scenario → Instrumentation → Flight Computer → Health Monitoring → Mission Execution → Telemetry → Communication Interface → Embedded Firmware → Simulation → Verification**

This project was developed to implement that complete chain at software and firmware level.

The platform combines:

* **C / STM32 embedded firmware**
* **MATLAB flight-data modelling**
* **Simulink system simulation**
* **OpenRocket trajectory generation**
* **Python host-side telemetry verification**
* **Automated cross-validation**
* **Structured telemetry packet design**
* **UART transport integration**
* **Fault and health monitoring**
* **Mission execution and scheduling**

The objective is not to create a flight-qualified avionics system, but to demonstrate how aerospace flight-computer software can be designed, simulated, implemented, tested, and cross-validated across multiple engineering environments.

---

# System Architecture

```text
                    FLIGHT SCENARIO
                          │
                          ▼
                    ┌─────────────┐
                    │ OpenRocket  │
                    │ Trajectory  │
                    └──────┬──────┘
                           │
                           ▼
                  ┌──────────────────┐
                  │ MATLAB Flight    │
                  │ Data Generation  │
                  └────────┬─────────┘
                           │
                           ▼
                  ┌──────────────────┐
                  │ Health Monitoring│
                  │ & Flight State   │
                  └────────┬─────────┘
                           │
                           ▼
                  ┌──────────────────┐
                  │ Simulink Model   │
                  │ System Simulation│
                  └────────┬─────────┘
                           │
                           │ cross-validation
                           ▼
┌───────────────────────────────────────────────────────────┐
│                    STM32 FLIGHT COMPUTER                  │
│                                                           │
│  Sensor → Health Monitor → Flight Controller → Mission  │
│                              │                            │
│                              ▼                            │
│                       Telemetry Builder                   │
│                              │                            │
│                              ▼                            │
│                         CRC16 Check                        │
│                              │                            │
│                              ▼                            │
│                         USART2 / UART                     │
└──────────────────────────────┬────────────────────────────┘
                               │
                               ▼
                     ┌──────────────────┐
                     │ Python Telemetry │
                     │ Verification     │
                     └──────────────────┘
```

The same telemetry concept is therefore exercised at multiple levels:

**Simulation → Embedded implementation → Packet verification → Transport integration**

---

# Core Engineering Pipeline

The platform implements the following software chain:

```text
Flight Scenario
      ↓
Instrumentation Data
      ↓
Flight State Representation
      ↓
Health Monitoring
      ↓
Flight Controller
      ↓
Mission Execution
      ↓
Telemetry Packet Construction
      ↓
CRC16 Verification
      ↓
UART Transport
      ↓
STM32 Embedded Firmware
      ↓
MATLAB / Simulink Cross-Validation
      ↓
Python Host-Side Verification
      ↓
Automated Integration Verification
```

This separation makes the project more representative of an actual engineering workflow than a single standalone embedded program.

---

# Telemetry Engineering

A custom binary telemetry packet was implemented in embedded C.

The final packet size is:

**22 bytes**

## Packet Format

| Byte(s) | Field            | Representation |
| ------- | ---------------- | -------------- |
| 0–1     | Synchronization  | `0xAA55`       |
| 2       | Protocol version | `uint8`        |
| 3–6     | Sequence counter | `uint32`       |
| 7–10    | Timestamp        | `uint32`       |
| 11–12   | Temperature      | °C × 10        |
| 13–14   | Altitude         | metres         |
| 15–16   | Velocity         | m/s × 10       |
| 17–18   | Battery voltage  | V × 100        |
| 19      | Flight status    | `uint8`        |
| 20–21   | CRC16            | CRC-16         |

The packet uses:

* Explicit field sizes
* Little-endian integer encoding
* Scaled integer representation for floating-point telemetry
* Sequence numbering
* Timestamping
* Status information
* CRC16 integrity verification

This provides a deterministic binary interface suitable for later integration with real communication links.

---

# Telemetry Packet Verification

The generated packet was independently checked using a **Python host-side verification script**.

The Python tool:

1. Reads the telemetry packet representation.
2. Decodes the binary fields.
3. Recalculates CRC16.
4. Compares the received and calculated CRC values.
5. Reports packet integrity.
6. Displays the decoded engineering values.

Example verified packet:

```text
Telemetry Packet
----------------
Length     : 22 bytes
Sync       : 0xAA55
Version    : 1
Sequence   : 0
Timestamp  : 0 s
Temperature: 25.0 °C
Altitude   : 1000 m
Velocity   : 120.0 m/s
Battery    : 24.00 V
Status     : 0
CRC RX     : 0x1318
CRC CALC   : 0x1318

Telemetry verification: PASS
```

### Why Python is included

Python is intentionally used as a **host-side engineering and verification tool**, not as the flight-computer runtime.

This creates a useful separation:

```text
STM32 / C
    │
    │ generates telemetry
    ▼
Binary Packet
    │
    ▼
Python
    │
    ├── decode
    ├── inspect
    ├── recalculate CRC
    └── verify
```

This approach allows the embedded implementation and host-side verification implementation to independently check the telemetry protocol.

---

# STM32 Flight Computer Firmware

The embedded implementation targets:

**STM32F446RETx**

The firmware was developed using:

* STM32CubeMX
* STM32CubeIDE
* ARM GCC
* STM32 HAL
* Embedded C

The firmware contains separate modules for:

```text
flight_data
sensor
health_monitor
flight_controller
mission
scheduler
telemetry
telemetry_uart
logger
```

The modular structure separates flight-data handling, health management, mission logic, telemetry construction, communication, and scheduling.

---

# Firmware Execution Flow

The scheduler executes the following sequence:

```text
Sensor Update
     ↓
Timestamp Update
     ↓
Health Monitoring
     ↓
Flight Controller
     ↓
Mission Execution
     ↓
Telemetry Packet Construction
     ↓
Telemetry Packet Verification
     ↓
UART Transmission
```

The main loop executes the scheduler once per second:

```c
while (1)
{
    scheduler_run(&flight_data);
    HAL_Delay(1000);
}
```

The architecture is intentionally modular so that simulated sensor sources can later be replaced by actual sensor drivers.

---

# Health Monitoring

The firmware implements basic flight-system health monitoring.

### Monitored parameters

* Battery voltage
* Temperature

### Status levels

| Status   | Value | Condition               |
| -------- | ----: | ----------------------- |
| OK       |     0 | Nominal                 |
| WARNING  |     1 | Battery below 20 V      |
| CRITICAL |     2 | Temperature above 80 °C |

The health state is incorporated directly into the telemetry packet.

---

# UART Communication

USART2 was configured through STM32CubeMX and integrated using STM32 HAL.

Configuration:

```text
Baud rate : 115200
Data      : 8 bits
Parity    : None
Stop bits : 1
Mode      : TX/RX
```

The firmware contains a dedicated UART transport layer:

```text
telemetry.c
      ↓
telemetry_uart.c
      ↓
HAL_UART_Transmit()
      ↓
USART2
```

The software integration was successfully compiled and linked.

**Physical UART electrical transmission was not verified because no physical STM32 hardware was available during this development phase.**

Therefore, this project does not claim hardware-level UART validation.

---

# Embedded Firmware Build Verification

The final STM32 firmware build completed with:

```text
Build Finished.
0 errors, 0 warnings.
```

Target:

```text
STM32F446RETx
```

Firmware size:

```text
text    data    bss    dec    hex
15668    104   2040  17812   4594
```

The loadable static sections reported by the ELF analysis include:

```text
.data : 104 bytes
.bss  : 500 bytes
```

The generated ELF, linker map, and symbol information were inspected to verify that the expected flight-computer modules were compiled and linked into the final firmware image.

Important linked modules include:

```text
flight_controller
health_monitor
logger
mission
scheduler
sensor
telemetry
telemetry_uart
```

---

# MATLAB Flight Simulation

MATLAB provides the flight-data modelling and simulation layer.

The simulation generates deterministic flight data containing:

* Timestamp
* Temperature
* Altitude
* Velocity
* Battery voltage
* Flight status

Simulation configuration:

| Parameter           |  Value |
| ------------------- | -----: |
| Simulation timestep | 0.10 s |
| Duration            |   60 s |
| Samples             |    601 |

Final simulated state:

| Parameter   | Final value |
| ----------- | ----------: |
| Time        |      60.0 s |
| Temperature |    34.00 °C |
| Altitude    |   3997.32 m |
| Velocity    |  120.82 m/s |
| Battery     |     22.20 V |
| Status      |           0 |

The MATLAB model provides a deterministic software reference against which the embedded flight-data architecture can be reasoned about.

---

# Simulink Model

The MATLAB workflow is extended into Simulink to represent the flight-computer processing chain using block-level simulation.

The model includes:

* Flight-data inputs
* Temperature monitoring
* Battery monitoring
* Health-state logic
* Status generation
* Simulation scopes

Configuration:

```text
Solver : Fixed-step
Step   : 0.1 s
Start  : 0 s
Stop   : 60 s
```

The Simulink model executes successfully without simulation errors.

---

# OpenRocket Integration

OpenRocket was used to generate an independent reference flight trajectory.

The project includes:

```text
openrocket/
├── designs/
│   └── ATFIDP_Test_Rocket.ork
├── simulations/
│   └── ATFIDP_reference_flight.csv
└── README.md
```

The exported OpenRocket trajectory is imported into MATLAB and converted into Simulink-compatible timeseries.

The integration therefore follows:

```text
OpenRocket
     ↓
CSV trajectory
     ↓
MATLAB import
     ↓
Data cleaning
     ↓
MATLAB timeseries
     ↓
Simulink
```

---

# OpenRocket Reference Flight

The verified reference trajectory contains:

| Parameter                |      Result |
| ------------------------ | ----------: |
| Raw samples              |          88 |
| Invalid rows removed     |           9 |
| Valid trajectory samples |          79 |
| Flight duration          | 1.97–1.98 s |
| Apogee                   |      2.15 m |
| Time to apogee           |      1.32 s |
| Maximum velocity         |   24.02 m/s |
| Maximum acceleration     |  18.98 m/s² |
| Maximum Mach             |       0.071 |

The small difference in reported flight duration between displays is due to the cleaned trajectory endpoint/precision; the verified reference trajectory remains consistent at approximately 1.98 s.

---

# OpenRocket → MATLAB → Simulink Integration

The OpenRocket CSV data is cleaned before entering Simulink.

Processing includes:

* Invalid-row removal
* Time sorting
* Duplicate handling
* Finite-value validation
* Timeseries generation
* Cross-checking against the source trajectory

Five Simulink signals are generated:

```text
openrocket_altitude
openrocket_velocity
openrocket_vertical_velocity
openrocket_acceleration
openrocket_mach
```

The prepared trajectory was verified against the original cleaned OpenRocket dataset.

---

# OpenRocket / Simulink Cross-Validation

The final integration produced:

| Parameter            | OpenRocket |   Simulink |
| -------------------- | ---------: | ---------: |
| End time             |     1.98 s |     1.98 s |
| Maximum altitude     |     2.15 m |     2.15 m |
| Maximum velocity     |  24.02 m/s |  24.02 m/s |
| Maximum acceleration | 18.98 m/s² | 18.98 m/s² |
| Maximum Mach         |      0.071 |      0.071 |

The independently prepared Simulink data agrees with the cleaned OpenRocket reference trajectory.

This provides a basic cross-tool validation path rather than relying on a single simulation environment.

---

# Automated Integration Verification

A dedicated MATLAB verification script performs the final integration checks:

```text
scripts/
└── verify_atfidp_integration.m
```

The verification covers:

* Project file availability
* OpenRocket data loading
* Invalid-data removal
* Trajectory validity
* OpenRocket flight-result verification
* MATLAB simulation data validation
* Simulink timeseries validation
* Timeseries length consistency
* Finite-value validation
* Data consistency
* Simulink model execution
* OpenRocket / Simulink cross-check

Final result:

```text
============================================================
 FINAL VERIFICATION SUMMARY
============================================================
Raw OpenRocket samples : 88
Invalid rows removed   : 9
Valid trajectory       : 79

Total tests : 15
Passed      : 15
Failed      : 0

============================================================
 ATFIDP MATLAB / OPENROCKET INTEGRATION: PASS
============================================================
```

**15 / 15 automated integration tests passed.**

---

# Verification Philosophy

The project intentionally uses several independent verification layers.

## Layer 1 — Embedded build verification

```text
STM32 C source
     ↓
ARM GCC
     ↓
ELF
     ↓
0 errors / 0 warnings
```

## Layer 2 — Telemetry verification

```text
Binary packet
     ↓
Python decoder
     ↓
CRC16 recalculation
     ↓
PASS
```

## Layer 3 — MATLAB verification

```text
Flight scenario
     ↓
MATLAB model
     ↓
Expected flight state
```

## Layer 4 — Simulink verification

```text
MATLAB / OpenRocket data
     ↓
Simulink model
     ↓
Successful execution
```

## Layer 5 — Cross-tool verification

```text
OpenRocket
     ↓
MATLAB
     ↓
Simulink
     ↓
15/15 PASS
```

This layered approach is intended to catch errors at different stages of the engineering workflow rather than relying only on compilation success.

---

# Key Engineering Findings

### 1. Telemetry should have an explicit protocol

A telemetry system becomes much easier to validate when packet structure, field widths, scaling, synchronization, and integrity checks are explicitly defined.

### 2. Embedded software and simulation should share data concepts

The MATLAB `FlightData` representation was designed around the same engineering quantities used by the STM32 firmware:

```text
temperature
altitude
velocity
battery
timestamp
status
```

This makes software-level comparison more straightforward.

### 3. Host-side tools provide independent verification

Using Python outside the embedded environment allows the telemetry protocol to be inspected independently from the firmware implementation.

### 4. Simulation is more useful when connected to external reference data

OpenRocket provides a separate trajectory source that can be imported into MATLAB and Simulink instead of relying exclusively on synthetic internal signals.

### 5. Modular firmware makes future hardware integration easier

The sensor, health-monitoring, telemetry, UART, mission, and scheduler modules can evolve independently as real hardware drivers are introduced.

---

# Repository Structure

```text
aerospace-telemetry-flight-computer-platform/
│
├── architecture/
│   └── system architecture documentation
│
├── config/
│   └── configuration files
│
├── docs/
│   └── engineering documentation
│
├── fault_management/
│   └── fault handling logic
│
├── flight_computer/
│   └── flight-computer software components
│
├── ground_station/
│   └── ground-side software components
│
├── health_monitor/
│   └── health monitoring logic
│
├── mission_control/
│   └── mission-control components
│
├── mission_scheduler/
│   └── mission scheduling
│
├── mission_timeline/
│   └── mission timeline handling
│
├── models/
│   └── system models
│
├── simulations/
│   └── simulation components
│
├── state_machine/
│   └── system state-machine logic
│
├── telemetry/
│   └── telemetry processing
│
├── tests/
│   └── software tests
│
├── utils/
│   └── utility modules
│
├── firmware/
│   └── ATFIDP_FlightComputer/
│       └── STM32 embedded firmware
│
├── matlab/
│   └── flight_computer_model/
│       ├── models/
│       ├── scripts/
│       ├── functions/
│       ├── data/
│       └── results/
│           ├── figures/
│           └── logs/
│
├── openrocket/
│   ├── designs/
│   ├── simulations/
│   └── README.md
│
├── CHANGELOG.md
├── VERSION.md
├── LICENSE
├── README.md
└── requirements.txt
```

---

# Main Technologies

| Area                        | Technology    |
| --------------------------- | ------------- |
| Embedded firmware           | C             |
| MCU                         | STM32F446RETx |
| MCU configuration           | STM32CubeMX   |
| Embedded IDE                | STM32CubeIDE  |
| Compiler                    | ARM GNU GCC   |
| HAL                         | STM32 HAL     |
| Flight simulation           | MATLAB        |
| System simulation           | Simulink      |
| Rocket trajectory           | OpenRocket    |
| Host telemetry verification | Python        |
| Data exchange               | CSV / MAT     |
| Communication               | UART / USART  |
| Integrity checking          | CRC16         |
| Version control             | Git / GitHub  |

---

# Engineering Scope

This project covers multiple layers of an aerospace embedded system:

```text
                 APPLICATION
                     │
          Mission / Flight Logic
                     │
                     ▼
              SYSTEM SOFTWARE
                     │
        Health / Scheduler / State
                     │
                     ▼
               TELEMETRY
                     │
       Packetization / CRC / UART
                     │
                     ▼
              EMBEDDED FIRMWARE
                     │
              STM32 / HAL / C
                     │
                     ▼
              SYSTEM SIMULATION
                     │
          MATLAB / Simulink
                     │
                     ▼
              FLIGHT REFERENCE
                     │
                 OpenRocket
                     │
                     ▼
              VERIFICATION
                     │
                  Python
```

The project therefore demonstrates experience across **embedded software, telemetry, simulation, modelling, verification, and aerospace-oriented engineering tools**.

---

# Project Limitations

This project is intentionally a development and verification platform rather than a flight-qualified avionics system.

### Hardware

No physical STM32 board was available for final testing.

Therefore:

* GPIO electrical behavior was not physically verified.
* UART electrical transmission was not physically verified.
* Sensor electrical interfaces were not physically verified.
* Oscilloscope / logic-analyzer measurements were not performed.
* No hardware-in-the-loop testing was performed.

### Sensors

The current embedded sensor layer uses deterministic software-generated values rather than physical sensor drivers.

### Communication

UART transmission is implemented through STM32 HAL, but the physical TX/RX signal path has not been measured on hardware.

### Flight qualification

This project does **not** claim:

* Flight qualification
* Radiation tolerance
* Environmental qualification
* EMC/EMI qualification
* Safety certification
* Launch certification
* Space-qualified hardware
* Flight heritage

The purpose is engineering development, modelling, implementation, integration, and verification.

---

# Possible Future Extensions

The completed platform provides a foundation for future hardware-oriented work.

Potential extensions include:

* Real STM32 sensor drivers
* IMU integration
* Barometric altitude sensing
* GPS/GNSS telemetry
* DMA-based UART communication
* Interrupt-driven telemetry
* Real RF communication
* LoRa telemetry
* CCSDS packet formats
* Ground-station telemetry decoding
* Hardware-in-the-loop testing
* Logic-analyzer verification
* Fault-injection testing
* Watchdog integration
* RTOS-based task scheduling
* Real-time telemetry dashboards

These are extensions to the current completed platform, not prerequisites for the current project to be considered complete.

---

# What This Project Demonstrates

The project demonstrates the ability to move an aerospace software concept through several engineering stages:

```text
Concept
  ↓
Architecture
  ↓
Data Model
  ↓
Simulation
  ↓
Telemetry Protocol
  ↓
Embedded C Implementation
  ↓
STM32 Firmware Build
  ↓
UART Integration
  ↓
Python Packet Verification
  ↓
OpenRocket Reference Data
  ↓
MATLAB / Simulink Integration
  ↓
Automated Verification
```

The final system is therefore more than an isolated MATLAB simulation or a standalone STM32 program.

It demonstrates an **integrated aerospace flight-computer development workflow** spanning modelling, embedded implementation, telemetry engineering, trajectory data, host-side verification, and cross-tool validation.

---

# Final Verification Status

| Component                     | Status                  |
| ----------------------------- | ----------------------- |
| System architecture           | ✅ Complete              |
| Flight-data model             | ✅ Complete              |
| MATLAB simulation             | ✅ Verified              |
| Simulink model                | ✅ Verified              |
| OpenRocket trajectory         | ✅ Verified              |
| OpenRocket → MATLAB           | ✅ Verified              |
| MATLAB → Simulink             | ✅ Verified              |
| STM32 firmware                | ✅ Built                 |
| Firmware build                | ✅ 0 errors / 0 warnings |
| Telemetry packet              | ✅ Implemented           |
| CRC16 verification            | ✅ PASS                  |
| Python telemetry verification | ✅ PASS                  |
| UART software integration     | ✅ Complete              |
| Automated integration tests   | ✅ 15/15 PASS            |
| Physical UART validation      | ⚠️ Not performed        |
| Flight qualification          | ⚠️ Out of scope         |

---

# Final Result

**ATFIDP — Aerospace Telemetry, Flight Computer & Instrumentation Development Platform**

**Completed and integrated across:**

**C / STM32 + MATLAB + Simulink + OpenRocket + Python**

with:

**15/15 automated integration tests passed.**

The project provides a software-first foundation for further development toward real embedded aerospace instrumentation, telemetry, and flight-computer systems.

---

## Author

**SaiPrabha C Y**

Embedded Systems | Firmware | Avionics | Aerospace

GitHub: `saiprabha-cy`

---

## License

This project is released under the MIT License.
