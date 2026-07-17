# Aerospace Telemetry and Flight Computer Integrated Development Platform (ATFIDP)

> A software-first aerospace avionics development platform designed to simulate telemetry, flight computer logic, mission monitoring, and system health validation before deployment to embedded hardware.

---

# Project Overview

The Aerospace Telemetry and Flight Computer Integrated Development Platform (ATFIDP) is an educational and engineering-oriented project that simulates the software architecture commonly found in modern launch vehicles, sounding rockets, CubeSats, and spacecraft.

Rather than beginning with hardware, this project follows a software-first development methodology similar to that used in professional aerospace organizations, where algorithms, telemetry pipelines, and flight logic are validated extensively before deployment onto embedded processors.

The project will progressively evolve from software simulation into embedded firmware, communication systems, signal processing, PCB hardware, and complete aerospace system integration.

---

# Objectives

- Learn professional embedded software engineering
- Understand aerospace telemetry systems
- Simulate onboard flight computer operations
- Design modular avionics software
- Build reusable aerospace software architecture
- Transition simulation into STM32 firmware
- Develop communication systems for aerospace applications
- Design custom avionics hardware using KiCad
- Integrate software with OpenRocket flight simulation

---

# Current Features

✔ Virtual Sensor Simulation

✔ Flight Computer Processing

✔ Telemetry Packet Generation

✔ Ground Station Monitoring

✔ Health Monitoring

✔ Configuration Management

✔ Centralized Logging

✔ Exception Handling

✔ Modular Repository Structure

---

# System Architecture

```
                 +-----------------------+
                 |  Virtual Sensors      |
                 +-----------+-----------+
                             |
                             v
                 +-----------------------+
                 |  Flight Computer      |
                 +-----------+-----------+
                             |
                             v
                 +-----------------------+
                 |  Telemetry Engine     |
                 +-----------+-----------+
                             |
                             v
                 +-----------------------+
                 |  Ground Station       |
                 +-----------+-----------+
                             |
                             v
                 +-----------------------+
                 |  Health Monitor       |
                 +-----------------------+
```

---

# Repository Structure

```text
ATFIDP/

├── architecture/
├── config/
├── docs/
├── flight_computer/
├── ground_station/
├── logs/
├── models/
├── reports/
├── simulations/
├── telemetry/
├── testing/
├── utils/

├── CHANGELOG.md
├── LICENSE
├── README.md
├── requirements.txt
└── .gitignore
```

---

# Technology Stack

## Programming

- Python

## Version Control

- Git
- GitHub

## Documentation

- Markdown

## Architecture

- Draw.io

## Future Development

- STM32CubeIDE
- GNU Octave
- KiCad
- OpenRocket

---

# Software Workflow

Virtual Sensors

↓

Flight Computer

↓

Telemetry Engine

↓

Ground Station

↓

Health Monitoring

↓

Mission Report

---

# Current Version

Version : 1.2

Status :

Software Simulation Complete

---

# Development Roadmap

## Version 1

Software Simulation

- Virtual Sensors
- Flight Computer
- Telemetry
- Ground Station
- Health Monitor

---

## Version 2

Embedded Firmware

- STM32CubeIDE
- UART
- GPIO
- ADC
- Timers
- Interrupts
- HAL Drivers

---

## Version 3

Communication Systems

- Telemetry Protocols
- Serial Communication
- Packet Validation
- Error Detection

---

## Version 4

Signal Processing

- Sensor Filtering
- FFT
- Kalman Filter
- GNU Octave

---

## Version 5

Hardware Design

- KiCad PCB
- STM32 Board
- Power System
- Sensors

---

## Version 6

OpenRocket Integration

- Flight Simulation
- Trajectory Analysis
- Mission Replay

---

# Learning Outcomes

This project focuses on understanding:

- Embedded Systems
- Aerospace Software
- Flight Computers
- Telemetry Systems
- Communication Systems
- System Validation
- Software Architecture
- Engineering Documentation

---

# License

This project is licensed under the MIT License.

---

# Author

SaiPrabha C Y

Electronics and Communication Engineering

Embedded Systems | Aerospace | Communication Systems