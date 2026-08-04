# Mission Control

## Purpose

Mission Control coordinates the execution of all aerospace software subsystems.

Instead of manually running each subsystem individually, Mission Control executes the complete mission pipeline automatically.

## Responsibilities

- Start virtual sensor simulation
- Execute Flight Computer
- Generate telemetry packets
- Launch Ground Station
- Run Health Monitoring
- Display mission completion status

## Future Expansion

This module will later support:

- Mission states
- Launch countdown
- Abort logic
- Fault recovery
- Mission replay
- Multi-threaded subsystem execution
- Real-time telemetry streaming