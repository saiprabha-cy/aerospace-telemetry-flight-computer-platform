# Aerospace Telemetry, Flight Computer & Instrumentation Development Platform

**ATFIDP** is a software-first aerospace flight-computer development platform that models, implements, and verifies a telemetry and instrumentation pipeline across **MATLAB, Simulink, OpenRocket, and STM32 embedded C firmware**.

The project is designed around a realistic engineering progression:

**Flight Scenario → Instrumentation → Flight Computer → Health Monitoring → Mission Execution → Telemetry Packetization → UART Transport → Embedded Firmware → Simulation Cross-Validation → Automated Verification**

Rather than treating telemetry as an isolated packet-format exercise, ATFIDP connects the complete data path from simulated flight parameters to an embedded flight-computer execution path.

---

## Project Status

**Status: Completed — Integrated and Verified**

| Layer                              | Implementation      | Status           |
| ---------------------------------- | ------------------- | ---------------- |
| Flight-data model                  | MATLAB              | ✅ Complete       |
| Flight scenario generation         | MATLAB              | ✅ Complete       |
| Health monitoring                  | MATLAB + Embedded C | ✅ Complete       |
| Mission execution                  | Embedded C          | ✅ Complete       |
| Deterministic scheduler            | Embedded C          | ✅ Complete       |
| Telemetry packet generation        | Embedded C          | ✅ Complete       |
| CRC-16 packet verification         | Embedded C + Python | ✅ Complete       |
| UART transport layer               | STM32 HAL           | ✅ Complete       |
| STM32 firmware build               | STM32CubeIDE / GCC  | ✅ Complete       |
| MATLAB simulation                  | MATLAB              | ✅ Complete       |
| Simulink model                     | Simulink            | ✅ Complete       |
| Rocket flight simulation           | OpenRocket          | ✅ Complete       |
| OpenRocket → Simulink integration  | MATLAB + Simulink   | ✅ Complete       |
| Automated integration verification | MATLAB              | ✅ **15/15 PASS** |

---

# Why This Project

A flight computer is not simply a microcontroller reading sensors.

A useful aerospace embedded system must establish a deterministic chain between:

* sensor or simulated flight data
* state representation
* health assessment
* mission logic
* telemetry generation
* packet integrity
* communications transport
* embedded execution
* independent simulation and verification

ATFIDP was developed to demonstrate that complete chain.

The project intentionally connects **software architecture, embedded C, telemetry engineering, MATLAB/Simulink modeling, rocket simulation, and verification** rather than presenting each technology as an isolated exercise.

---

# System Architecture

```text
                         FLIGHT SCENARIO
                              │
                              ▼
                    ┌────────────────────┐
                    │  MATLAB / OpenRocket│
                    │  Flight Parameters │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │   FlightData Model │
                    │                    │
                    │ Temperature        │
                    │ Altitude           │
                    │ Velocity           │
                    │ Battery            │
                    │ Timestamp          │
                    │ Health Status      │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │   Sensor Layer     │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │ Health Monitor     │
                    │                    │
                    │ Battery            │
                    │ Temperature        │
                    │ Status Generation  │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │ Flight Controller │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │ Mission Manager    │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │ Deterministic      │
                    │ Scheduler           │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │ Telemetry Engine   │
                    │                    │
                    │ Framing            │
                    │ Serialization      │
                    │ Sequence           │
                    │ CRC-16             │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │ UART Transport     │
                    │ STM32 HAL          │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │ Embedded Flight    │
                    │ Computer Firmware  │
                    │ STM32F446RETx      │
                    └────────────────────┘


      Independent Verification Path
      ──────────────────────────────

      OpenRocket
          │
          ▼
      MATLAB preprocessing
          │
          ▼
      Simulink
          │
          ▼
      Automated integration verification
```

---

# Core Engineering Pipeline

## 1. Flight Data

The common `FlightData` representation carries:

* temperature
* altitude
* velocity
* battery voltage
* timestamp
* health status

This structure forms the interface between the flight-computer subsystems.

---

## 2. Deterministic Execution

The embedded scheduler executes the flight-computer functions in a defined order:

```text
Sensor Update
     ↓
Timestamp Update
     ↓
Health Monitoring
     ↓
Flight Controller
     ↓
Mission Manager
     ↓
Telemetry Packet Construction
     ↓
Packet Verification
     ↓
UART Transmission
```

This makes the execution path explicit rather than relying on unrelated module calls scattered throughout the application.

---

# Telemetry Engineering

The telemetry subsystem produces a compact binary packet rather than transmitting human-readable text.

## Packet Format

| Offset | Field                |    Size |
| -----: | -------------------- | ------: |
|    0–1 | Synchronization word | 2 bytes |
|      2 | Protocol version     |  1 byte |
|    3–6 | Sequence counter     | 4 bytes |
|   7–10 | Timestamp            | 4 bytes |
|  11–12 | Temperature ×10      | 2 bytes |
|  13–14 | Altitude             | 2 bytes |
|  15–16 | Velocity ×10         | 2 bytes |
|  17–18 | Battery ×100         | 2 bytes |
|     19 | Health status        |  1 byte |
|  20–21 | CRC-16               | 2 bytes |

**Total packet size: 22 bytes**

The packet uses little-endian integer serialization for multi-byte fields and CRC-16 validation for packet integrity.

---

# Example Telemetry Packet

The verified nominal packet represents:

```text
Temperature : 25.0 °C
Altitude    : 1000 m
Velocity    : 120.0 m/s
Battery     : 24.00 V
Status      : OK
```

The host-side telemetry verifier independently reconstructs the fields and recalculates the CRC.

Example verification:

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

This verifies the packet structure independently from the firmware implementation.

---

# STM32 Embedded Firmware

The flight-computer implementation targets:

**STM32F446RETx**

The firmware is implemented in embedded C using the STM32 HAL environment.

Major modules include:

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

The firmware integrates:

* deterministic application scheduling
* timestamp acquisition
* health monitoring
* binary telemetry serialization
* CRC-16 packet validation
* UART transmission
* logging
* STM32 HAL peripheral access

The firmware builds successfully with:

```text
0 errors
0 warnings
```

---

# Firmware Memory Footprint

Verified ELF size:

```text
text     : 15,668 bytes
data     :    104 bytes
bss      :  2,040 bytes
--------------------------------
decimal  : 17,812 bytes
```

Static initialized/uninitialized data:

```text
.data + .bss = 2,144 bytes
```

The generated ELF and linker map were inspected to verify the resulting firmware image and major symbols.

---

# MATLAB Flight Simulation

MATLAB provides an independent flight-data generation and health-monitoring environment.

The deterministic simulation uses:

```text
Timestep : 0.10 s
Duration : 60.00 s
Samples  : 601
```

The simulated parameters include:

* altitude
* velocity
* temperature
* battery voltage
* timestamp
* health status

Example final state:

```text
Timestamp    : 60.0 s
Temperature  : 34.00 °C
Altitude     : 3997.32 m
Velocity     : 120.82 m/s
Battery      : 22.20 V
Status       : 0
```

Simulation data is stored in:

```text
data/flight_simulation.mat
```

---

# Simulink Model

The MATLAB flight-computer model was independently represented in Simulink.

The model uses a discrete simulation configuration with:

```text
Step size : 0.1 s
Duration  : 60 s
```

The Simulink implementation provides a block-diagram representation of the flight-computer processing chain and serves as an independent model against which the software implementation can be compared.

---

# OpenRocket Integration

OpenRocket is used to generate an independent rocket-flight trajectory.

The reference rocket model contains:

* nose cone
* body tube
* three fins
* motor mount
* mass component
* Estes C6 motor configuration

The verified reference trajectory contains:

```text
Raw samples          : 88
Invalid rows removed : 9
Valid samples        : 79
```

After preprocessing, the trajectory is converted into MATLAB `timeseries` objects for Simulink.

---

# OpenRocket Flight Results

The verified reference flight produced:

| Parameter                    |     Result |
| ---------------------------- | ---------: |
| Flight duration              |     1.97 s |
| Apogee altitude              |     2.15 m |
| Time to apogee               |     1.32 s |
| Maximum velocity             |  24.02 m/s |
| Time of maximum velocity     |     1.98 s |
| Maximum acceleration         | 18.98 m/s² |
| Time of maximum acceleration |     0.20 s |
| Maximum Mach number          |      0.071 |
| Time of maximum Mach         |     1.98 s |

These values are independently checked by the final MATLAB verification script.

---

# OpenRocket → Simulink Data Path

The OpenRocket CSV is processed through MATLAB:

```text
OpenRocket CSV
      │
      ▼
CSV Import
      │
      ▼
Invalid-row filtering
      │
      ▼
Time sorting
      │
      ▼
Duplicate removal
      │
      ▼
MATLAB timeseries
      │
      ▼
Simulink
```

Five independent timeseries are generated:

```text
openrocket_altitude
openrocket_velocity
openrocket_vertical_velocity
openrocket_acceleration
openrocket_mach
```

The prepared Simulink data was verified against the cleaned OpenRocket trajectory.

---

# Automated Integration Verification

The final verification script performs an end-to-end check across the project.

It verifies:

```text
Project files
      ↓
OpenRocket CSV
      ↓
Trajectory cleaning
      ↓
OpenRocket flight results
      ↓
Simulink timeseries
      ↓
MATLAB flight simulation
      ↓
Simulink model execution
      ↓
OpenRocket / Simulink cross-check
```

## Final Verification Result

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

**Final integration status: 15/15 tests passed.**

This is the final verification baseline for the completed project.

---

# Verification Philosophy

The project deliberately uses multiple implementations and representations rather than trusting a single simulation.

```text
                 ┌──────────────────┐
                 │    OpenRocket    │
                 │ Flight Dynamics  │
                 └────────┬─────────┘
                          │
                          ▼
                 ┌──────────────────┐
                 │ MATLAB Processing│
                 └────────┬─────────┘
                          │
                          ▼
                 ┌──────────────────┐
                 │    Simulink      │
                 │ Block Simulation │
                 └────────┬─────────┘
                          │
                          ▼
                 ┌──────────────────┐
                 │ Automated Tests  │
                 └──────────────────┘


                 Independent path

                 ┌──────────────────┐
                 │ Embedded C       │
                 │ STM32 Firmware   │
                 └────────┬─────────┘
                          │
                          ▼
                 ┌──────────────────┐
                 │ Telemetry Packet │
                 │ + CRC Validation │
                 └──────────────────┘
```

The objective is not merely to produce plots or compile firmware, but to establish agreement between independent representations of the same engineering data.

---

# Repository Structure

```text
aerospace-telemetry-flight-computer-platform/
│
├── architecture/
├── config/
├── docs/
│
├── fault_management/
├── flight_computer/
├── ground_station/
├── health_monitor/
│
├── mission_control/
├── mission_scheduler/
├── mission_timeline/
├── state_machine/
│
├── telemetry/
├── tests/
├── utils/
│
├── firmware/
│   └── ATFIDP_FlightComputer/
│       └── ATFIDP_FlightComputer/
│
├── matlab/
│   └── flight_computer_model/
│       ├── models/
│       ├── scripts/
│       ├── functions/
│       ├── data/
│       └── results/
│           └── figures/
│
├── models/
├── simulations/
│
├── CHANGELOG.md
├── LICENSE
├── VERSION.md
└── README.md
```

---

# Main Technologies

### Embedded Systems

* Embedded C
* STM32F446RETx
* STM32 HAL
* STM32CubeIDE
* UART
* binary serialization
* CRC-16
* deterministic scheduling

### Modeling & Simulation

* MATLAB
* Simulink
* OpenRocket
* MATLAB `timeseries`

### Verification

* MATLAB automated verification
* host-side telemetry verification
* ELF inspection
* linker-map inspection
* numerical cross-validation

### Development

* Git
* GitHub
* structured modular software architecture
* reproducible simulation scripts

---

# Engineering Scope

This project intentionally focuses on the **flight-computer and telemetry/instrumentation software layer**.

It does not claim to be a complete flight-qualified spacecraft or launch vehicle avionics system.

The implementation is a development and verification platform for studying and demonstrating:

* embedded flight-computer architecture
* telemetry pipelines
* instrumentation data handling
* health monitoring
* mission execution
* packet integrity
* UART communications
* simulation-to-embedded workflows
* aerospace software verification

---

# Current Limitations

The following boundaries are intentional:

* Physical STM32 UART transmission has not been electrically verified on hardware.
* Sensors are represented by deterministic software inputs in the current firmware implementation.
* The OpenRocket vehicle is a simplified reference vehicle rather than a flight-certified launch vehicle.
* The telemetry protocol is a project-specific binary protocol and is not intended to represent a complete CCSDS implementation.
* The MATLAB/Simulink and embedded implementations are cross-validated at the data and execution level, but the complete system has not undergone hardware-in-the-loop testing.

These limitations define the next possible engineering stages rather than being hidden assumptions.

---

# Possible Extensions

Future extensions could include:

* physical STM32 sensor interfaces
* ADC-based instrumentation
* IMU integration
* GPS telemetry
* DMA-based UART communication
* interrupt-driven telemetry
* CCSDS packetization
* ground-station telemetry decoding
* hardware-in-the-loop testing
* RF telemetry
* real-time operating system integration
* hardware prototype integration

---

# What This Project Demonstrates

ATFIDP demonstrates a complete engineering workflow from simulated aerospace data to an embedded flight-computer software implementation:

```text
                    MODEL
                      │
                      ▼
               FLIGHT SCENARIO
                      │
                      ▼
              DATA PROCESSING
                      │
                      ▼
             FLIGHT COMPUTER
                      │
                      ▼
             HEALTH / MISSION
                      │
                      ▼
                 TELEMETRY
                      │
                      ▼
             PACKET + CRC
                      │
                      ▼
                 UART / MCU
                      │
                      ▼
              INDEPENDENT TEST
                      │
                      ▼
               15/15 PASS
```

The main engineering outcome is not a single algorithm or simulation.

It is the integration of **aerospace modeling, embedded firmware, telemetry engineering, simulation, communications, and verification into one coherent flight-computer development workflow.**

---

# Author

**SAIPRABHA C Y**


---

# License

This project is released under the MIT License.
