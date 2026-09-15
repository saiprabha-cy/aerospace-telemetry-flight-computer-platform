# ATFIDP System Architecture

## 1. Purpose

The Aerospace Telemetry, Flight Computer & Instrumentation Development Platform (ATFIDP) is an integrated engineering platform for developing and verifying flight-computer, telemetry, instrumentation, simulation, and mission-support software.

The architecture connects:

- Flight-data generation
- Health monitoring
- Flight-control software
- Mission execution
- Telemetry packet generation
- UART telemetry transmission
- MATLAB simulation
- Simulink execution
- OpenRocket trajectory data
- Python host-side telemetry verification

The project is designed as a development and verification platform rather than a flight-qualified avionics system.

---

## 2. System-Level Architecture

```text
                         ATFIDP SYSTEM
                              │
              ┌───────────────┴───────────────┐
              │                               │
       FLIGHT COMPUTER                  ENGINEERING MODELS
              │                               │
       ┌──────┼────────┐              ┌───────┼──────────┐
       │      │        │              │       │          │
    Sensor  Health   Mission       MATLAB  Simulink  OpenRocket
       │    Monitor  Manager          │       │          │
       │      │        │              │       │          │
       └──────┴────────┘              └───────┴──────────┘
              │                               │
              ▼                               ▼
       Flight Controller               Simulation Data
              │
              ▼
       Telemetry Builder
              │
       ┌──────┴─────────┐
       │                │
   CRC Verification   Packet
       │                │
       └──────┬─────────┘
              ▼
        UART Interface
              │
              ▼
       External Telemetry
              │
              ▼
     Host-Side Verification
            Python
            
## 3. Flight-Computer Software Architecture

The embedded software is organized into modular components.

main
 │
 ├── Hardware Initialization
 │
 ├── Logger
 ├── Sensor
 ├── Health Monitor
 ├── Flight Controller
 ├── Mission Manager
 ├── Telemetry
 ├── Telemetry UART
 └── Scheduler

The scheduler provides the main software execution path.

Scheduler
   │
   ├── Sensor Update
   │
   ├── Timestamp Update
   │
   ├── Health Monitoring
   │
   ├── Flight Controller Update
   │
   ├── Mission Execution
   │
   ├── Telemetry Packet Construction
   │
   ├── CRC Verification
   │
   └── UART Transmission


## 4. Flight Data Flow

The common FlightData structure acts as the internal data model.

Sensor Data
    │
    ▼
FlightData
    │
    ├── Temperature
    ├── Altitude
    ├── Velocity
    ├── Battery Voltage
    ├── Timestamp
    └── Health Status
         │
         ├── Health Monitor
         │
         ├── Flight Controller
         │
         └── Telemetry Builder

This avoids unnecessary coupling between individual software modules.

## 5. Telemetry Data Flow

FlightData
    │
    ▼
Telemetry Builder
    │
    ├── Sync
    ├── Version
    ├── Sequence
    ├── Timestamp
    ├── Sensor Values
    ├── Status
    └── CRC16
    │
    ▼
22-byte Packet
    │
    ▼
Packet Verification
    │
    ├── PASS ──► UART
    │
    └── FAIL ──► Reject
## 6. Simulation Architecture

The engineering simulation environment provides an independent model of the flight-computer data path.

MATLAB
  │
  ├── Flight Scenario Generation
  │
  ├── Health Model
  │
  └── Simulation Dataset
          │
          ▼
      Simulink
          │
          ▼
   Model Execution

OpenRocket provides a separate trajectory source:

OpenRocket
    │
    ▼
CSV Flight Data
    │
    ▼
MATLAB Import
    │
    ▼
Data Cleaning
    │
    ▼
MATLAB Timeseries
    │
    ▼
Simulink


## 7. Verification Architecture

The platform uses multiple verification layers.

Layer 1 — Source-level verification

Embedded C modules are compiled as part of the STM32 firmware project.

Layer 2 — Firmware build verification

The complete STM32 firmware is compiled using STM32CubeIDE/GCC.

Layer 3 — Telemetry verification

The generated telemetry packet is independently checked using Python.

Layer 4 — MATLAB verification

The flight-data generation and health-monitoring model are executed independently.

Layer 5 — Simulink verification

The Simulink models are executed to verify model behavior.

Layer 6 — OpenRocket verification

Reference trajectory values are extracted from OpenRocket.

Layer 7 — Cross-tool verification

OpenRocket trajectory data is compared against the Simulink representation.

## 8. Engineering Boundaries

ATFIDP currently demonstrates:

Embedded C architecture
STM32 HAL integration
UART telemetry interface
Binary telemetry packet construction
CRC16 verification
Host-side packet verification
MATLAB simulation
Simulink execution
OpenRocket trajectory integration
Automated cross-tool verification

The project does not claim:

Flight qualification
Hardware-in-the-loop qualification
Radiation tolerance
EMC/EMI qualification
Real sensor electrical validation
Physical UART link validation
Flight certification


## 9. Target Hardware

The firmware project targets:

STM32F446RETx

The project uses STM32CubeMX-generated peripheral configuration and STM32 HAL APIs.

USART2 is configured for telemetry communication.

Current firmware configuration:

Baud rate: 115200
Data bits: 8
Parity: None
Stop bits: 1
TX/RX enabled

The firmware has been successfully built.

Physical UART transmission has not been electrically verified because the required hardware was not available during development.

## 10. Repository-Level Architecture
ATFIDP/
│
├── architecture/
├── config/
├── docs/
├── fault_management/
├── flight_computer/
├── ground_station/
├── health_monitor/
├── mission_control/
├── mission_scheduler/
├── mission_timeline/
├── models/
├── simulations/
├── state_machine/
├── telemetry/
├── tests/
├── utils/
│
├── firmware/
│   └── ATFIDP_FlightComputer/
│
├── matlab/
│   └── flight_computer_model/
│
├── openrocket/
│   ├── designs/
│   └── simulations/
│
├── CHANGELOG.md
├── LICENSE
├── README.md
├── VERSION.md
└── requirements.txt

## 11. Architectural Objective

The primary architectural objective is separation of concerns.

The system separates:

Flight-data acquisition
Health assessment
Control logic
Mission execution
Telemetry construction
Communications
Simulation
Verification

This structure allows individual components to be developed, tested, replaced, and extended without restructuring the complete platform.
