# Flight Computer

## Purpose

The Flight Computer is the onboard decision-making software.

It receives sensor measurements, validates system health, and prepares information for telemetry transmission.

---

## Responsibilities

- Read sensor data
- Validate measurements
- Detect abnormal conditions
- Generate flight logs
- Prepare telemetry inputs

---

## Input

sensor_data.csv

---

## Output

flight_log.csv

---

## Health Checks

Current implementation:

- Low Battery
- High Temperature
- Invalid Altitude

Future implementation:

- Sensor Timeout
- CRC Errors
- Watchdog Monitoring
- Redundant Sensors
- Fault Recovery