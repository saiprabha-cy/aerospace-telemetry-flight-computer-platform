# Aerospace Telemetry, Flight Computer & Instrumentation Development Platform (ATFIDP)
## Current Status

**Current Version:** v1.1.0

### Completed

- Software Simulation
- Virtual Sensors
- Flight Computer
- Telemetry Engine
- Ground Station
- Health Monitor
- Mission Controller
- Mission State Machine
- Mission Timeline
- Mission Scheduler
- Fault Management
- Unit Testing
- Logging Framework
- Configuration Management

### Next Phase

Embedded Firmware Development using STM32CubeIDE

## Overview

ATFIDP is a software-first aerospace engineering project that simulates the core software components commonly found in experimental rockets, CubeSats, and embedded aerospace systems.

The project focuses on instrumentation, telemetry processing, health monitoring, and flight computer software before transitioning to embedded firmware and hardware implementation.

The development approach follows an incremental workflow:

Software Simulation → Embedded Firmware → Signal Processing → Rocket Simulation → Hardware Prototype

---

## Project Objectives

- Develop modular aerospace software architecture.
- Simulate flight instrumentation.
- Design a telemetry generation pipeline.
- Build a simplified flight computer.
- Monitor system health.
- Detect and classify faults.
- Prepare software for STM32 embedded implementation.

---

## Current Features

- Virtual Sensor Simulation
- Flight Computer
- Telemetry Packet Generator
- Ground Station
- Health Monitoring
- Mission Controller
- Mission Scheduler
- Mission Timeline
- Mission State Machine
- Fault Injection
- Fault Detection
- Logging System
- Configuration Management
- Unit Testing

---

## Software Architecture

```
Virtual Sensors
        │
        ▼
Flight Computer
        │
        ▼
Telemetry Engine
        │
        ▼
Ground Station
        │
        ▼
Health Monitor
        │
        ▼
Fault Management
```

Mission Controller coordinates the execution of each subsystem.

Mission Scheduler demonstrates periodic task execution.

Mission State Machine models mission progression.

Mission Timeline simulates Mission Elapsed Time (MET).

---

## Project Structure

```
ATFIDP/

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
├── reports/
├── simulations/
├── state_machine/
├── telemetry/
├── tests/
├── utils/
├── README.md
├── LICENSE
└── requirements.txt
```

---

## Technologies Used

- Python 3
- VS Code
- Git
- GitHub
- Draw.io

---

## Current Development Stage

Software Simulation (Version 1)

Completed:
- Software Architecture
- Core Mission Pipeline
- Logging
- Testing
- Fault Management

Upcoming:
- STM32CubeIDE Embedded Firmware
- GNU Octave Signal Processing
- OpenRocket Mission Integration
- Hardware Prototype

---

## Future Roadmap

- Embedded C Firmware
- STM32 HAL Drivers
- UART Telemetry
- Timer Interrupts
- Sensor Interfaces
- RTOS Concepts
- Signal Processing
- Hardware Integration

---

## License

This project is released under the MIT License.