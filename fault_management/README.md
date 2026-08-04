# Fault Management

## Purpose

This module introduces reliability testing into ATFIDP.

Instead of assuming ideal sensor values, the software deliberately injects abnormal conditions and verifies that they are detected correctly.

## Fault Injection

Current simulated faults:

- Low Battery
- High Temperature
- Invalid Altitude
- Invalid Velocity

## Fault Detection

The Fault Manager analyses incoming sensor data and classifies any abnormal condition.

## Future Expansion

Future versions will include:

- Missing sensor data
- Corrupted telemetry packets
- Communication timeout detection
- Sensor redundancy checks
- Safe mode transitions
- Fault logging