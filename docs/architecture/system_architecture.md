# ATFIDP System Architecture

## 1. Purpose

The Aerospace Telemetry, Flight Computer & Instrumentation Development Platform (ATFIDP) is structured as an integrated engineering environment for developing and verifying a small flight-computer and telemetry system.

The architecture connects:

- STM32 embedded firmware
- Flight-data and health-management logic
- Telemetry packet generation and verification
- UART transport
- MATLAB flight-data simulation
- Simulink system-level modeling
- OpenRocket trajectory simulation
- Python host-side telemetry verification

The project follows an engineering flow of:

**Model → Simulate → Implement → Generate Telemetry → Verify → Cross-Validate**

---

## 2. System Overview

```text
                         ATFIDP SYSTEM
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
          ▼                   ▼                   ▼
       MATLAB             OpenRocket            STM32
     Simulation           Trajectory       Flight Computer
          │                   │                   │
          │                   ▼                   │
          │               CSV Data                 │
          │                   │                   │
          │                   ▼                   │
          │                MATLAB                  │
          │               Preparation              │
          │                   │                   │
          │                   ▼                   │
          │                Simulink                │
          │                   │                   │
          └───────────────────┼───────────────────┘
                              │
                              ▼
                       Cross-Validation
                              │
                              ▼
                          Telemetry
                              │
                              ▼
                            UART
                              │
                              ▼
                      Host Verification
```

The three major engineering domains are:

1. **Embedded flight-computer implementation**
2. **MATLAB/Simulink system modeling**
3. **OpenRocket trajectory generation and integration**

Python provides an independent host-side verification path for the telemetry packet format.

---

## 3. Major Components

| Component | Responsibility |
|---|---|
| Sensor Module | Provides flight-data inputs to the flight-computer data structure |
| Health Monitor | Evaluates basic vehicle health conditions |
| Flight Controller | Provides the flight-control processing interface |
| Mission Manager | Provides mission-execution logic |
| Scheduler | Controls the periodic execution sequence |
| Telemetry Module | Builds and verifies telemetry packets |
| UART Interface | Provides the embedded telemetry transport |
| MATLAB | Generates deterministic flight scenarios and performs analysis |
| Simulink | Provides system-level simulation and signal-flow verification |
| OpenRocket | Generates a reference rocket trajectory |
| Python Verifier | Independently validates the telemetry packet format and CRC |

---

## 4. Embedded Flight-Computer Architecture

The embedded implementation targets an **STM32F446RETx** microcontroller using STM32CubeMX-generated initialization and STM32 HAL interfaces.

```text
                    STM32F446RETx
                          │
                          ▼
                       main.c
                          │
                          ▼
                     Scheduler
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
     Sensor         Health Monitor    Flight Controller
        │                 │                 │
        └─────────────────┼─────────────────┘
                          │
                          ▼
                    Mission Manager
                          │
                          ▼
                      Telemetry
                          │
                 ┌────────┴────────┐
                 │                 │
                 ▼                 ▼
          Packet Verification     CRC-16
                 │
                 ▼
             USART2 / UART
```

The scheduler provides the main application sequence:

```text
Sensor Update
      │
      ▼
Timestamp Update
      │
      ▼
Health Monitoring
      │
      ▼
Flight Controller Update
      │
      ▼
Mission Manager
      │
      ▼
Telemetry Packet Construction
      │
      ▼
Telemetry Packet Verification
      │
      ▼
UART Transmission
```

The current implementation uses deterministic simulated sensor values. The architecture is intentionally structured so that these inputs can later be replaced by real sensor interfaces.

---

## 5. Runtime Data Flow

The primary flight-data object is the `FlightData` structure.

```text
Sensor Inputs
     │
     ▼
 FlightData
     │
     ├── Temperature
     ├── Altitude
     ├── Velocity
     ├── Battery Voltage
     ├── Timestamp
     └── Status
          │
          ▼
   Health Monitoring
          │
          ▼
   Flight Processing
          │
          ▼
   Mission Processing
          │
          ▼
 Telemetry Serialization
          │
          ▼
     CRC-16
          │
          ▼
    UART Transport
```

This separates data acquisition, health evaluation, mission processing, telemetry serialization, and transport responsibilities.

---

## 6. Telemetry Interface

The embedded telemetry subsystem generates a fixed **22-byte binary packet**.

```text
┌────────┬─────────┬──────────┬───────────┬──────────────┬────────┐
│ Sync   │ Version │ Sequence │ Timestamp │ Flight Data  │ CRC-16 │
│ 2 B    │ 1 B     │ 4 B      │ 4 B       │ 9 B          │ 2 B    │
└────────┴─────────┴──────────┴───────────┴──────────────┴────────┘
```

The packet contains:

- Synchronization word
- Protocol version
- Sequence counter
- Timestamp
- Temperature
- Altitude
- Velocity
- Battery voltage
- Flight status
- CRC-16

Packet construction and verification are implemented independently within the embedded telemetry module.

The complete field-level packet definition is documented separately in:

`docs/telemetry/telemetry_protocol.md`

---

## 7. Engineering-Time Architecture

The project also contains an engineering-time simulation and verification chain.

### MATLAB Flight Simulation

```text
Simulation Parameters
        │
        ▼
Deterministic Flight Scenario
        │
        ▼
Flight Data Generation
        │
        ▼
Health Monitoring Model
        │
        ▼
Simulation Results
        │
        ▼
MAT File
```

### OpenRocket → MATLAB → Simulink

```text
             OpenRocket
                 │
                 ▼
        Reference Flight CSV
                 │
                 ▼
       MATLAB Data Preparation
                 │
                 ▼
          Cleaned Trajectory
                 │
                 ▼
             Timeseries
                 │
                 ▼
             Simulink
                 │
                 ▼
        System-Level Analysis
                 │
                 ▼
        Cross-Validation
```

This provides an independent trajectory source for checking the Simulink integration.

---

## 8. Interfaces

| Interface | Purpose |
|---|---|
| `FlightData` | Common internal representation of flight state |
| Telemetry Packet | Binary representation of flight data for transmission |
| CRC-16 | Detects corruption in the telemetry packet |
| USART2 | Embedded telemetry transport interface |
| OpenRocket CSV | External trajectory-data interface |
| MATLAB Timeseries | Data interface between MATLAB preparation and Simulink |
| Python Telemetry Verifier | Independent host-side packet validation |

The interfaces are kept explicit so that individual modules can be tested without requiring the complete system.

---

## 9. Verification Boundary

The architecture supports verification at multiple levels.

```text
                 ATFIDP Verification
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
     Firmware          Models         Integration
        │                │                │
        ▼                ▼                ▼
   Build Check      MATLAB Check     OpenRocket Check
   Module Logic     Simulink Check   Simulink Check
   Telemetry        Data Check       Cross-Validation
   CRC              Health Logic
        │                │                │
        └────────────────┼────────────────┘
                         ▼
                 System Evidence
```

Verified areas include:

- STM32 firmware compilation
- Embedded module integration
- Telemetry packet construction
- CRC verification
- MATLAB flight simulation
- Simulink execution
- OpenRocket trajectory processing
- OpenRocket-to-Simulink data consistency
- Python host-side telemetry verification
- Automated MATLAB/OpenRocket/Simulink integration verification

The final MATLAB/OpenRocket integration verification completed with:

**15 tests passed, 0 failed.**

---

## 10. Hardware Boundary

The embedded architecture targets:

**MCU:** STM32F446RETx  
**UART:** USART2  
**Configuration:** 115200 baud, 8-N-1

The firmware configuration, peripheral initialization, packet construction, CRC verification, and UART transmission code have been implemented and successfully compiled.

Physical UART electrical transmission has **not** been verified because physical STM32 hardware and an external UART receiver were not available during development.

Therefore, the project distinguishes between:

- **Software/peripheral integration:** implemented and build-verified
- **Physical electrical transmission:** not yet experimentally verified

---

## 11. Architectural Scope

The current architecture establishes a foundation for future aerospace-oriented extensions, including:

- Real sensor drivers
- IMU and GPS interfaces
- Additional communication interfaces
- Telecommand handling
- Watchdog supervision
- Fault recovery
- Expanded mission state machines
- CCSDS-compatible telemetry
- RF transceiver integration
- Hardware-in-the-loop testing
- Real-time hardware validation

These are future extensions rather than claims of functionality in the current implementation.

---

## 12. Summary

ATFIDP uses a layered architecture that connects embedded implementation with system-level modeling and independent verification.

```text
       MODEL
         │
         ▼
     SIMULATE
         │
         ▼
    IMPLEMENT
         │
         ▼
GENERATE TELEMETRY
         │
         ▼
      VERIFY
         │
         ▼
 CROSS-VALIDATE
```

The resulting architecture provides a traceable path from flight-data modeling to embedded telemetry implementation and system-level verification.

The project therefore serves as an integrated development and verification platform rather than a standalone firmware or simulation exercise.