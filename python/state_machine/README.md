# Mission State Machine

## Purpose

The Mission State Machine manages the execution flow of the Aerospace Telemetry & Flight Computer Integrated Development Platform (ATFIDP).

Instead of executing subsystems sequentially without context, the mission controller transitions through well-defined operational states.

This architecture improves reliability, readability, scalability, and fault handling.

---

## Current Mission States

- INITIALIZATION
- SENSOR_SIMULATION
- FLIGHT_COMPUTER
- TELEMETRY
- GROUND_STATION
- HEALTH_MONITOR
- COMPLETED
- FAILED

---

## Future Mission States

These will be introduced gradually during later versions.

- POWER_ON
- SELF_TEST
- WAIT_FOR_COMMAND
- STANDBY
- SAFE_MODE
- SHUTDOWN

---

This module is responsible only for mission execution flow.

It does not perform telemetry generation or flight computations.