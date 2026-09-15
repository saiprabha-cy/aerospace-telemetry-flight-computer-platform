# Verification Report

## 1. Purpose

This document records the verification evidence for the Aerospace Telemetry, Flight Computer & Instrumentation Development Platform (ATFIDP).

Verification was performed across the embedded firmware, telemetry protocol, MATLAB simulation, Simulink models, OpenRocket trajectory processing, and host-side telemetry validation.

The objective is to demonstrate that the implemented software components execute correctly and that independently generated data remains consistent across the simulation and integration chain.

This verification is software-level validation and does not represent flight qualification or hardware certification.

---

## 2. Verification Scope

The verification boundary covers:

- STM32 embedded firmware compilation
- firmware module integration
- telemetry packet construction
- telemetry CRC verification
- UART interface integration
- Python host-side telemetry verification
- MATLAB flight simulation
- health-monitoring logic
- Simulink model execution
- OpenRocket trajectory processing
- OpenRocket → MATLAB data preparation
- OpenRocket → Simulink integration
- cross-validation of trajectory results
- automated end-to-end integration checks

Physical electrical UART transmission and real sensor operation are outside the current verification boundary because physical flight-computer hardware was not available.

---

## 3. Firmware Build Verification

The STM32 flight-computer firmware targets the STM32F446RETx and uses STM32CubeMX-generated initialization with the STM32 HAL.

The final firmware build completed with:

    Build Finished. 0 errors, 0 warnings.

### ELF Size

The generated firmware image was inspected using `arm-none-eabi-size`.

    text    data    bss    dec    hex
    15668   104     2040   17812  4594

The executable therefore contains:

- 15,668 bytes of text/data code and read-only program content reported in the standard size output
- 104 bytes of initialized data
- 2,040 bytes of BSS/reserved zero-initialized data

The detailed linker map was also generated for further memory inspection.

The reported BSS value includes the complete linked BSS region and should not be interpreted as the exact application-owned RAM requirement without further linker-map accounting.

---

## 4. Firmware Module Verification

The firmware was organized into independent modules for sensor processing, health monitoring, flight-control interfacing, mission management, scheduling, telemetry, logging, and UART transport.

The integrated execution sequence is:

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
    CRC Verification
        ↓
    UART Transmission

The modules compile and link together successfully as part of the final STM32 firmware image.

---

## 5. Telemetry Packet Verification

The firmware generates a fixed 22-byte telemetry packet.

The verified packet layout contains:

| Field | Size |
|---|---:|
| Sync | 2 bytes |
| Version | 1 byte |
| Sequence | 4 bytes |
| Timestamp | 4 bytes |
| Temperature | 2 bytes |
| Altitude | 2 bytes |
| Velocity | 2 bytes |
| Battery | 2 bytes |
| Status | 1 byte |
| CRC-16 | 2 bytes |
| **Total** | **22 bytes** |

The firmware performs CRC-16 verification over the first 20 bytes before accepting the packet as valid.

---

## 6. Reference Telemetry Packet

A reference nominal packet was independently decoded using the Python host-side verification tool.

Reference packet:

    55 AA 01 00 00 00 00 00 00 00 00 FA 00 E8 03 B0 04 60 09 00 18 13

Decoded values:

| Parameter | Value |
|---|---:|
| Packet length | 22 bytes |
| Sync | 0xAA55 |
| Version | 1 |
| Sequence | 0 |
| Timestamp | 0 s |
| Temperature | 25.0 °C |
| Altitude | 1000 m |
| Velocity | 120.0 m/s |
| Battery | 24.00 V |
| Status | 0 — OK |
| Received CRC | 0x1318 |
| Calculated CRC | 0x1318 |

Result:

    Telemetry verification: PASS

This provides an independent host-side check of the packet structure and CRC implementation.

---

## 7. Python Host-Side Verification

The telemetry packet was also checked using:

    tools/verify_telemetry.py

Python is used here as a host-side engineering and verification tool.

It is not part of the STM32 flight-computer runtime.

The verifier independently:

1. reads the reference packet,
2. decodes the fields,
3. calculates the CRC-16,
4. compares the calculated CRC against the received value,
5. reports the decoded telemetry values.

The matching CRC result confirms that the reference packet is internally consistent.

---

## 8. MATLAB Simulation Verification

The MATLAB simulation uses deterministic input generation so that the same test scenario can be reproduced.

### Configuration

| Parameter | Value |
|---|---:|
| Duration | 60.0 s |
| Time step | 0.1 s |
| Samples | 601 |
| Initial temperature | 25.0 °C |
| Initial altitude | 1000.0 m |
| Initial velocity | 120.0 m/s |
| Initial battery | 24.00 V |

### Final State

| Parameter | Final Value |
|---|---:|
| Timestamp | 60.0 s |
| Temperature | 34.00 °C |
| Altitude | 3997.32 m |
| Velocity | 120.82 m/s |
| Battery | 22.20 V |
| Status | 0 — OK |

The simulation completed successfully and generated:

    data/flight_simulation.mat

---

## 9. Health-Monitoring Verification

The MATLAB health model was exercised using nominal and fault conditions.

| Test | Condition | Expected Status | Result |
|---|---|---:|---|
| 1 | Nominal | 0 — OK | PASS |
| 2 | Low battery | 1 — WARNING | PASS |
| 3 | High temperature | 2 — CRITICAL | PASS |
| 4 | Both faults | 2 — CRITICAL | PASS |

This confirms the intended behavior of the MATLAB health-monitoring model for the tested cases.

---

## 10. Simulink Verification

The main flight-computer Simulink model was generated and executed successfully.

Model:

    models/ATFIDP_FlightComputer.slx

Configuration:

    Solver       : Fixed-step discrete
    Step size    : 0.1 s
    Start time   : 0 s
    Stop time    : 60 s

The model executed without simulation errors.

A separate OpenRocket integration model was also generated:

    models/ATFIDP_OpenRocket_Integration.slx

This model processes five prepared trajectory signals:

- altitude
- velocity
- vertical velocity
- acceleration
- Mach number

The model executed successfully using the prepared OpenRocket data.

---

## 11. OpenRocket Data Verification

The OpenRocket reference trajectory was exported as:

    openrocket/simulations/ATFIDP_reference_flight.csv

The raw dataset contained:

    Raw samples : 88

The MATLAB preprocessing stage identified:

    Invalid rows : 9
    Valid rows   : 79

The cleaned trajectory was checked for finite values and chronological consistency.

Result:

    Cleaned OpenRocket trajectory is finite: PASS

---

## 12. OpenRocket Reference Results

The processed OpenRocket trajectory produced:

| Parameter | Verified Value |
|---|---:|
| Flight duration | 1.98 s |
| Time to apogee | 1.32 s |
| Apogee altitude | 2.15 m |
| Maximum velocity | 24.02 m/s |
| Time of maximum velocity | 1.98 s |
| Maximum acceleration | 18.98 m/s² |
| Time of maximum acceleration | 0.20 s |
| Maximum Mach number | 0.071 |
| Time of maximum Mach | 1.98 s |

These values correspond to the configured OpenRocket reference design and are not claims about actual vehicle flight performance.

---

## 13. OpenRocket → Simulink Data Verification

The cleaned OpenRocket trajectory was converted into MATLAB timeseries objects.

The verification confirmed:

- all five required timeseries exist,
- timeseries lengths match the cleaned trajectory,
- all prepared values are finite,
- prepared values match the cleaned OpenRocket data,
- time vectors match the cleaned trajectory.

Result:

    OpenRocket → MATLAB → Simulink data preparation: PASS

---

## 14. OpenRocket / Simulink Cross-Validation

The independently generated OpenRocket results were compared with the results obtained after Simulink processing.

| Parameter | OpenRocket | Simulink | Result |
|---|---:|---:|---|
| End time | 1.98 s | 1.98 s | PASS |
| Maximum altitude | 2.15 m | 2.15 m | PASS |
| Maximum velocity | 24.02 m/s | 24.02 m/s | PASS |
| Maximum acceleration | 18.98 m/s² | 18.98 m/s² | PASS |
| Maximum Mach | 0.071 | 0.071 | PASS |

The agreement confirms that the trajectory data was transferred and processed consistently.

---

## 15. Automated Integration Verification

The complete verification procedure is implemented in:

    scripts/verify_atfidp_integration.m

The script verifies:

1. required OpenRocket MATLAB data,
2. prepared OpenRocket Simulink data,
3. MATLAB flight simulation data,
4. required Simulink models,
5. OpenRocket table loading,
6. invalid-row handling,
7. trajectory validity,
8. OpenRocket flight results,
9. MATLAB simulation data validity,
10. Simulink timeseries consistency,
11. prepared-data consistency,
12. Simulink model execution,
13. OpenRocket/Simulink end time,
14. OpenRocket/Simulink maximum altitude,
15. OpenRocket/Simulink maximum velocity, acceleration, and Mach consistency.

Final automated result:

    Total tests : 15
    Passed      : 15
    Failed      : 0

Final status:

    ATFIDP MATLAB / OPENROCKET INTEGRATION: PASS

The detailed verification output is saved to:

    results/figures/ATFIDP_Final_Integration_Verification.txt

---

## 16. Verification Evidence Matrix

| Area | Verification Method | Result |
|---|---|---|
| STM32 firmware | ARM GCC build | PASS |
| Firmware warnings/errors | Compiler output | 0 / 0 |
| Firmware image | ELF inspection | PASS |
| Module integration | Final linked firmware | PASS |
| Telemetry construction | Firmware packet builder | PASS |
| CRC verification | Firmware + Python | PASS |
| Host telemetry decoding | Python | PASS |
| MATLAB simulation | Script execution | PASS |
| Health monitoring | Four test cases | PASS |
| Main Simulink model | Model execution | PASS |
| OpenRocket import | CSV processing | PASS |
| OpenRocket trajectory | Numerical checks | PASS |
| Simulink trajectory data | Timeseries checks | PASS |
| OpenRocket/Simulink consistency | Cross-validation | PASS |
| End-to-end automated verification | 15 automated checks | **15/15 PASS** |

---

## 17. Verification Boundary

The completed verification demonstrates software and simulation consistency.

It does not demonstrate:

- physical sensor acquisition,
- physical UART electrical transmission,
- RF transmission,
- hardware-in-the-loop behavior,
- environmental qualification,
- vibration or thermal qualification,
- flight qualification,
- propulsion validation,
- closed-loop flight performance.

USART2 is configured in the STM32 firmware and the transmission function is integrated using STM32 HAL. However, physical electrical transmission was not tested because physical hardware was not available.

This distinction is intentional so that the project documentation reflects the actual verification evidence.

---

## 18. Reproducibility

The verification workflow is designed to be repeatable.

Key inputs and outputs are stored within the repository:

    MATLAB simulation
        → data/flight_simulation.mat

    OpenRocket design
        → openrocket/designs/ATFIDP_Test_Rocket.ork

    OpenRocket reference data
        → openrocket/simulations/ATFIDP_reference_flight.csv

    Prepared Simulink data
        → data/openrocket_simulink_data.mat

    Simulink models
        → models/ATFIDP_FlightComputer.slx
        → models/ATFIDP_OpenRocket_Integration.slx

    Final verification report
        → results/figures/ATFIDP_Final_Integration_Verification.txt

This allows the software and simulation results to be regenerated and inspected independently.

---

## 19. Final Assessment

The ATFIDP implementation has reached a completed software-integration verification stage.

The strongest verification evidence is the agreement between independent engineering stages:

    Embedded Firmware
          ↓
    Telemetry Packet
          ↓
    Host-Side Verification

and:

    OpenRocket
          ↓
    MATLAB Data Processing
          ↓
    Simulink Integration
          ↓
    Cross-Validation
          ↓
    15 / 15 PASS

The project therefore demonstrates a coherent software engineering and aerospace simulation workflow with verified interfaces between its major development stages.

The results should be interpreted as software-level and simulation-level verification, not as evidence of flight readiness or hardware qualification.