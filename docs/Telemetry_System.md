# Telemetry System

## Purpose

Telemetry transfers information from the onboard flight computer to the ground station.

This allows engineers to monitor vehicle health throughout the mission.

---

## Responsibilities

- Read flight logs
- Build telemetry packets
- Serialize mission data
- Export JSON packets

---

## Packet Contents

- Timestamp
- Temperature
- Altitude
- Velocity
- Battery Voltage
- System Status

---

## Future Improvements

- Binary Packet Format
- CRC Validation
- Packet Counters
- Compression
- CCSDS-inspired framing