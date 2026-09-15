# Engineering Design Decisions

## 1. Purpose

This document records the major engineering decisions made during development of the Aerospace Telemetry, Flight Computer & Instrumentation Development Platform (ATFIDP).

The goal is to explain **why** the system was designed in its current form rather than simply documenting what was implemented.

The decisions prioritize:

- deterministic behavior
- modularity
- interface clarity
- verifiability
- embedded-system suitability
- independent validation
- realistic engineering boundaries

---

## 2. Modular Embedded Architecture

### Decision

The STM32 flight-computer software was divided into separate modules:

- Sensor
- Health Monitor
- Flight Controller
- Mission Manager
- Scheduler
- Telemetry
- UART Interface
- Logger

### Rationale

A monolithic `main.c` implementation would make individual functions harder to test, replace, and extend.

A modular architecture allows the simulated sensor source to eventually be replaced by a real sensor driver without redesigning the entire application.

It also provides clear interfaces between data acquisition, health processing, mission logic, telemetry generation, and communication.

### Result

The firmware follows a layered flow:

    Sensor
       ↓
    Flight Data
       ↓
    Health / Control / Mission
       ↓
    Telemetry
       ↓
    UART

This structure provides a practical foundation for future embedded hardware integration.

---

## 3. Central Flight Data Structure

### Decision

A common `FlightData` structure is used to represent the primary flight state.

It contains:

    temperature_c
    altitude_m
    velocity_mps
    battery_v
    timestamp_s
    status

### Rationale

Using one defined data model across the firmware and MATLAB simulation reduces interface ambiguity.

The same conceptual fields can therefore move through:

    Sensor → FlightData → Health Monitor → Telemetry

while the MATLAB environment can reproduce equivalent test scenarios.

### Result

The flight-data model acts as an internal software interface between major subsystems.

---

## 4. Deterministic Simulation Data

### Decision

MATLAB uses deterministic mathematical profiles rather than random sensor values.

### Rationale

Random inputs are useful for some robustness tests, but deterministic inputs are better for baseline verification because the expected result is reproducible.

For example, the same 60-second scenario can be regenerated whenever the simulation is executed.

This makes it easier to:

- compare software revisions,
- reproduce failures,
- validate Simulink behavior,
- inspect numerical results,
- automate regression checks.

### Result

The baseline MATLAB simulation uses:

    60 s duration
    0.1 s timestep
    601 samples

and produces repeatable flight-state results.

---

## 5. Fixed-Length Telemetry Packet

### Decision

ATFIDP uses a fixed 22-byte telemetry packet for the current implementation.

### Rationale

A fixed packet simplifies embedded implementation and deterministic parsing.

The current packet contains:

- synchronization word
- protocol version
- sequence number
- timestamp
- temperature
- altitude
- velocity
- battery voltage
- health status
- CRC-16

A fixed layout also makes host-side verification straightforward.

### Result

The packet can be constructed by the STM32 firmware and independently decoded by the Python verification tool.

The design can later be extended with a length field, message identifier, payload expansion, or versioned packet families if the communications architecture grows.

---

## 6. Little-Endian Field Encoding

### Decision

Multi-byte telemetry fields are encoded in little-endian byte order.

### Rationale

The firmware explicitly serializes integer values byte-by-byte instead of relying on direct memory copies of C structures.

This avoids dependence on compiler structure padding and makes the packet layout explicit.

For example, a 32-bit sequence number is written as four defined bytes rather than transmitting the in-memory representation of a C variable.

### Result

The packet format is deterministic and independently reproducible by host-side tools.

---

## 7. Scaled Integer Telemetry Fields

### Decision

Floating-point engineering values are converted to scaled unsigned integers before packet transmission.

Examples:

    Temperature × 10
    Velocity × 10
    Battery voltage × 100

Altitude is currently transmitted with a scale factor of 1.

### Rationale

Transmitting compact integer representations gives the packet a deterministic binary representation without requiring the receiver to depend on the STM32 floating-point representation.

The engineering scaling preserves useful resolution while keeping the packet compact.

### Result

The telemetry packet remains small and straightforward to decode.

A future protocol revision could define signed fields or wider representations where negative or higher-range measurements are required.

---

## 8. CRC-16 Integrity Check

### Decision

A CRC-16 is appended to every telemetry packet.

### Rationale

Telemetry data can be corrupted during storage, processing, or communication.

A CRC provides a lightweight integrity check suitable for embedded systems.

The CRC is calculated over the first 20 bytes and stored in the final two bytes of the 22-byte packet.

### Result

The firmware can reject a packet whose calculated CRC does not match the received CRC.

The same reference packet was independently verified using Python, providing a second implementation of the integrity check.

---

## 9. Sequence Number

### Decision

Every telemetry packet contains a 32-bit sequence number.

### Rationale

A sequence number allows a receiver or post-processing system to identify packet ordering and detect missing packets.

The current implementation increments the sequence number for each packet generated by the scheduler.

### Result

The protocol has a basic mechanism for future packet-loss detection without requiring changes to the core telemetry architecture.

---

## 10. Timestamp Representation

### Decision

The current firmware telemetry timestamp is represented as elapsed seconds using a 32-bit unsigned integer.

### Rationale

The value is simple to generate from the embedded system tick and provides a deterministic representation for the current prototype.

It avoids introducing a dependency on a real-time clock or external time source at this stage.

### Result

The timestamp can be used for basic packet ordering and mission-time correlation.

A future implementation can replace or extend this with mission elapsed time, RTC time, GPS time, or higher-resolution timestamps.

---

## 11. UART Transport

### Decision

USART2 is used as the current embedded telemetry transport.

Configuration:

    Baud rate : 115200
    Data      : 8 bits
    Parity    : None
    Stop bits : 1

### Rationale

UART provides a simple and widely supported interface for initial telemetry integration and debugging.

It allows the packet-generation layer to remain independent from the eventual physical communications system.

### Result

The telemetry module creates the packet while the UART module handles transmission.

This separation allows UART to be replaced later with another transport such as a radio modem, USB interface, or spacecraft communication subsystem.

---

## 12. Separation of Telemetry Generation and Transport

### Decision

Telemetry packet construction and UART transmission are implemented as separate modules.

### Rationale

The telemetry protocol should not depend directly on the physical transport.

The packet generator is responsible for:

    data → binary packet

The UART interface is responsible for:

    binary packet → serial transmission

### Result

The architecture can evolve from a development UART interface toward a real telemetry radio without rewriting the packet-generation logic.

---

## 13. Python as a Host-Side Verification Tool

### Decision

Python is used to independently verify telemetry packets.

### Rationale

The Python implementation provides an independent host-side representation of the packet decoder and CRC calculation.

This reduces reliance on a single implementation when checking packet correctness.

Python was deliberately kept outside the flight-computer runtime.

### Result

The system has two distinct roles:

    STM32 C
    → packet generation

    Python
    → independent host-side verification

This makes Python a verification and engineering-support tool rather than an artificial replacement for embedded firmware.

---

## 14. MATLAB for Numerical Simulation

### Decision

MATLAB is used for deterministic flight-data generation and numerical analysis.

### Rationale

MATLAB provides a convenient environment for generating controlled engineering scenarios, analysing numerical data, and exchanging data with Simulink.

The same environment also provides a natural interface to trajectory data imported from OpenRocket.

### Result

MATLAB acts as the numerical test-data and analysis layer rather than the embedded runtime.

---

## 15. Simulink for System-Level Modelling

### Decision

Simulink is used as a block-level system representation and execution environment.

### Rationale

Text-based MATLAB scripts are effective for deterministic calculations, while Simulink provides explicit signal-flow representation.

Using both makes it possible to inspect the processing chain visually and execute the model using defined simulation settings.

### Result

The project contains:

    ATFIDP_FlightComputer.slx

for the flight-computer simulation and:

    ATFIDP_OpenRocket_Integration.slx

for trajectory-data integration.

---

## 16. OpenRocket as an Independent Reference

### Decision

OpenRocket is used to generate an independent reference trajectory.

### Rationale

The MATLAB simulation is software-generated, so it should not be treated as an independent physical trajectory source.

OpenRocket provides a separate aerospace-specific simulation environment whose exported trajectory can be processed independently.

This makes it useful for testing the data-import and Simulink integration pipeline.

### Result

The project verifies the following chain:

    OpenRocket
        ↓
    CSV
        ↓
    MATLAB
        ↓
    Simulink
        ↓
    Cross-Validation

The verified OpenRocket trajectory contained 88 raw samples and 79 valid samples after preprocessing.

---

## 17. Automated Verification

### Decision

Integration verification is implemented as a repeatable MATLAB script instead of relying only on manual inspection.

### Rationale

Manual inspection of plots and console output is useful during development but is insufficient as the only regression mechanism.

The automated verification script checks required files, data consistency, numerical results, Simulink execution, and cross-validation.

### Result

The final automated verification produced:

    Total tests : 15
    Passed      : 15
    Failed      : 0

This provides a reproducible baseline for future changes.

---

## 18. Verification Before Hardware Claims

### Decision

Software verification and hardware verification are explicitly separated.

### Rationale

The firmware contains STM32 HAL UART integration, but physical hardware was not available for electrical testing.

Claiming successful physical UART transmission without hardware evidence would overstate the project.

Therefore, the documentation distinguishes between:

    Software peripheral integration
    and
    Physical electrical verification

### Result

The project can truthfully claim:

- STM32 firmware builds successfully.
- USART2 is configured and integrated.
- UART transmission code is implemented.
- telemetry construction and CRC verification are tested.

It does not claim:

- measured physical UART transmission,
- RF transmission,
- hardware-in-the-loop validation,
- flight qualification.

---

## 19. Simulation vs. Firmware Separation

### Decision

MATLAB and Simulink are treated as engineering models rather than replacements for the STM32 firmware.

### Rationale

The purpose of simulation is to validate algorithms, data flow, and interfaces before hardware deployment.

The actual embedded implementation remains C running on the STM32 target.

### Result

The project maintains a clear distinction:

    MATLAB / Simulink
    → modelling, simulation, analysis, verification

    STM32 C / HAL
    → embedded implementation

    Python
    → host-side verification

This prevents the development tools from being confused with the eventual flight-computer runtime.

---

## 20. Modular Extension Strategy

### Decision

The current implementation intentionally leaves extension points for future aerospace functionality.

Potential additions include:

- real sensor drivers
- IMU processing
- GPS integration
- watchdog management
- fault recovery
- mission state machines
- telecommand handling
- CCSDS-compatible packetization
- radio/transceiver interfaces
- hardware-in-the-loop testing

### Rationale

Implementing every future subsystem immediately would increase complexity without improving the current verification objective.

The architecture instead establishes interfaces that can be expanded as the platform develops.

### Result

The current project remains compact enough to understand while providing a reasonable foundation for future avionics-oriented development.

---

## 21. Engineering Trade-Off Summary

| Decision | Primary Reason |
|---|---|
| Modular firmware | Maintainability and subsystem isolation |
| Central `FlightData` structure | Consistent internal interface |
| Deterministic MATLAB data | Reproducibility |
| Fixed 22-byte packet | Simple embedded parsing |
| Explicit little-endian encoding | Deterministic binary format |
| Scaled integer fields | Compact telemetry representation |
| CRC-16 | Packet integrity |
| Sequence number | Packet ordering/loss detection |
| UART | Simple development transport |
| Separate telemetry/UART modules | Transport independence |
| Python verifier | Independent host-side validation |
| MATLAB | Numerical simulation and analysis |
| Simulink | Block-level system modelling |
| OpenRocket | Independent trajectory reference |
| Automated verification | Repeatable regression testing |
| Explicit hardware boundary | Honest engineering claims |

---

## 22. Final Design Philosophy

The overall design philosophy is:

    Define Interfaces
          ↓
    Build Modular Components
          ↓
    Simulate Deterministically
          ↓
    Implement on Embedded Target
          ↓
    Verify Independently
          ↓
    Cross-Validate Results
          ↓
    Extend Toward Hardware

The project therefore emphasizes not only implementation, but also the ability to explain, test, and verify the engineering decisions behind that implementation.

The current ATFIDP architecture is intentionally positioned as a software-integrated aerospace development platform rather than a flight-qualified avionics system.