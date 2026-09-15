# Simulation and OpenRocket Integration

## 1. Purpose

This document describes the simulation and trajectory-analysis workflow used in the Aerospace Telemetry, Flight Computer & Instrumentation Development Platform (ATFIDP).

The simulation environment provides three complementary engineering views:

- **MATLAB** — deterministic flight-data generation and numerical analysis
- **Simulink** — block-level system execution and signal-flow verification
- **OpenRocket** — independent rocket trajectory reference data

The objective is not to claim flight-qualified performance, but to establish a reproducible workflow for generating, processing, and cross-validating aerospace-related data before hardware integration.

---

## 2. MATLAB Flight Computer Simulation

The MATLAB simulation provides a deterministic flight-data scenario corresponding to the data model used by the embedded flight-computer firmware.

### Simulation Configuration

| Parameter | Value |
|---|---:|
| Simulation duration | 60 s |
| Time step | 0.1 s |
| Samples | 601 |
| Initial temperature | 25.0 °C |
| Initial altitude | 1000.0 m |
| Initial velocity | 120.0 m/s |
| Initial battery | 24.0 V |

The flight scenario contains:

- timestamp
- altitude
- velocity
- temperature
- battery voltage
- health status

Altitude, velocity, temperature, and battery voltage are generated using deterministic mathematical profiles so that the same scenario can be reproduced during development and verification.

### Final Simulation State

The verified 60-second simulation produced:

| Parameter | Final Value |
|---|---:|
| Timestamp | 60.0 s |
| Temperature | 34.00 °C |
| Altitude | 3997.32 m |
| Velocity | 120.82 m/s |
| Battery | 22.20 V |
| Health status | 0 — OK |

Simulation data is saved as:

    data/flight_simulation.mat

The main execution script is:

    scripts/run_simulation.m

---

## 3. Health-Monitoring Simulation

The MATLAB model reproduces the health-monitoring concept implemented in the firmware.

The nominal thresholds are:

- Battery below 20.0 V → WARNING
- Temperature above 80.0 °C → CRITICAL

The health-monitoring test cases produced:

| Test | Condition | Expected Status | Result |
|---|---|---:|---|
| 1 | Nominal | 0 — OK | PASS |
| 2 | Low battery | 1 — WARNING | PASS |
| 3 | High temperature | 2 — CRITICAL | PASS |
| 4 | Both faults | 2 — CRITICAL | PASS |

This provides a simple software-level verification of the health-state logic before hardware sensor integration.

---

## 4. Simulink Integration

A discrete-time Simulink representation was generated to provide a block-level implementation of the flight-computer processing chain.

### Model

    models/ATFIDP_FlightComputer.slx

The model uses:

- From Workspace input signals
- temperature, altitude, velocity, and battery inputs
- health-monitoring comparison logic
- status generation
- scopes for signal observation
- fixed-step discrete execution

### Configuration

| Parameter | Value |
|---|---:|
| Solver | Fixed-step discrete |
| Step size | 0.1 s |
| Start time | 0 s |
| Stop time | 60 s |

The model was executed successfully without simulation errors.

The Simulink implementation is intended as a system-level verification model rather than a replacement for the embedded C firmware.

---

## 5. OpenRocket Reference Trajectory

OpenRocket is used to generate an independent reference trajectory for the ATFIDP test rocket configuration.

### Tool

- OpenRocket 22.02

### Project

    openrocket/designs/ATFIDP_Test_Rocket.ork

The reference configuration contains a simplified rocket geometry with:

- 150 mm nose cone
- 800 mm body tube
- 50 mm target body diameter
- three trapezoidal fins
- internal motor mount
- 100 g mass component

The resulting reference flight was exported as:

    openrocket/simulations/ATFIDP_reference_flight.csv

---

## 6. OpenRocket Reference Results

The verified OpenRocket trajectory contains 88 raw samples.

After preprocessing, 9 invalid rows were removed, leaving 79 valid trajectory samples.

### Reference Flight

| Parameter | Result |
|---|---:|
| Flight duration | 1.98 s |
| Time to apogee | 1.32 s |
| Apogee altitude | 2.15 m |
| Maximum velocity | 24.02 m/s |
| Time of maximum velocity | 1.98 s |
| Maximum acceleration | 18.98 m/s² |
| Time of maximum acceleration | 0.20 s |
| Maximum Mach number | 0.071 |

These values represent the configured OpenRocket reference case only. They are not intended to represent the performance of an actual launch vehicle.

---

## 7. OpenRocket → MATLAB Data Preparation

The OpenRocket CSV is imported into MATLAB using:

    scripts/import_openrocket_data.m

The preparation workflow:

1. Load the OpenRocket CSV.
2. Identify invalid trajectory samples.
3. Remove non-finite or unusable rows.
4. Sort samples by time.
5. Remove duplicate timestamps.
6. Generate MATLAB timeseries objects.
7. Save the cleaned data for Simulink.

Prepared signals include:

- altitude
- velocity
- vertical velocity
- acceleration
- Mach number

The prepared dataset is stored in:

    data/openrocket_simulink_data.mat

The preparation script reported:

    Original samples : 88
    Invalid rows     : 9
    Valid samples    : 79

The resulting trajectory begins at approximately 0.01 s and ends at 1.98 s.

---

## 8. OpenRocket → Simulink Integration

The prepared OpenRocket trajectory is connected to Simulink through MATLAB timeseries objects.

The integration model is:

    models/ATFIDP_OpenRocket_Integration.slx

The model contains five trajectory inputs:

    openrocket_altitude
    openrocket_velocity
    openrocket_vertical_velocity
    openrocket_acceleration
    openrocket_mach

Each signal is connected to a corresponding From Workspace block and observation scope.

The integration model uses variable-step `ode45` execution for processing the imported trajectory data.

The model was executed successfully.

---

## 9. Cross-Validation

The final integration verification compares the independently generated OpenRocket trajectory against the data processed by Simulink.

The verified comparison was:

| Parameter | OpenRocket | Simulink | Result |
|---|---:|---:|---|
| End time | 1.98 s | 1.98 s | PASS |
| Maximum altitude | 2.15 m | 2.15 m | PASS |
| Maximum velocity | 24.02 m/s | 24.02 m/s | PASS |
| Maximum acceleration | 18.98 m/s² | 18.98 m/s² | PASS |
| Maximum Mach | 0.071 | 0.071 | PASS |

This confirms that the cleaned OpenRocket trajectory was transferred into the Simulink environment without changing the verified reference results.

---

## 10. Automated Integration Verification

The complete verification workflow is executed by:

    scripts/verify_atfidp_integration.m

The final verification covered:

- required project files
- OpenRocket data loading
- invalid-row filtering
- trajectory validity
- OpenRocket reference results
- MATLAB simulation data
- Simulink timeseries generation
- timeseries length consistency
- finite-value checks
- data consistency between OpenRocket and MATLAB
- Simulink model loading
- Simulink execution
- OpenRocket/Simulink result agreement

### Final Result

    Total tests : 15
    Passed      : 15
    Failed      : 0

Therefore:

    ATFIDP MATLAB / OPENROCKET INTEGRATION: PASS

The verification report is saved to:

    results/figures/ATFIDP_Final_Integration_Verification.txt

---

## 11. Engineering Workflow

The resulting simulation pipeline is:

    MATLAB
       │
       ├── Deterministic Flight Scenario
       │
       └── Flight Simulation Data
                │
                ▼
            Simulink
                │
                │
    OpenRocket ─┘
        │
        └── Reference Trajectory
                │
                ▼
       Data Preparation
                │
                ▼
          Cross-Validation
                │
                ▼
          15/15 Tests PASS

This separates the sources of data while allowing the same trajectory to be independently processed and compared.

---

## 12. Engineering Value

The simulation environment establishes several useful development practices:

- deterministic test-data generation
- repeatable health-monitoring tests
- block-level system modelling
- independent trajectory generation
- automated data cleaning
- MATLAB timeseries integration
- numerical cross-validation
- reproducible verification results

The workflow also creates a bridge between aerospace analysis tools and embedded-system development:

    Aerospace Model
          ↓
    Reference Data
          ↓
    System Simulation
          ↓
    Embedded Data Model
          ↓
    Telemetry / Verification

This makes the simulation environment useful as an engineering validation layer before introducing real sensors, avionics hardware, or hardware-in-the-loop testing.

---

## 13. Scope and Limitations

The current implementation is a software and simulation development platform.

It does **not** demonstrate:

- actual rocket flight
- flight-qualified avionics
- real sensor measurements
- physical UART electrical transmission
- hardware-in-the-loop operation
- closed-loop propulsion or guidance control

The OpenRocket configuration is a reference test case, while the MATLAB flight scenario is a deterministic software-generated dataset. These datasets are used for software integration and verification rather than physical flight prediction validation.

---

## 14. Future Extensions

The simulation architecture can be extended with:

- real IMU and GPS datasets
- higher-fidelity atmospheric and trajectory models
- hardware-in-the-loop testing
- real-time telemetry replay
- fault-injection campaigns
- embedded target-in-the-loop testing
- mission-state and telecommand simulation
- CCSDS-compatible telemetry processing
- sensor-driver integration
- flight-data log replay and analysis

---

## 15. Summary

The ATFIDP simulation environment integrates MATLAB, Simulink, and OpenRocket into a reproducible engineering workflow.

The completed implementation demonstrates:

    Deterministic MATLAB Simulation
                ↓
          Simulink Execution
                ↓
       OpenRocket Reference Data
                ↓
        MATLAB Data Preparation
                ↓
        Simulink Integration
                ↓
         Cross-Validation
                ↓
           15 / 15 PASS

The result is a verified software-level simulation and trajectory-integration environment that supports the broader ATFIDP flight-computer and telemetry architecture.