# Software Architecture

## Overview

The software architecture is designed as a modular aerospace avionics pipeline.

Each subsystem performs one specific task and forwards processed information to the next subsystem.

This modular design improves maintainability, scalability, testing, and future hardware deployment.

---

## Data Flow

Virtual Sensors

↓

Flight Computer

↓

Telemetry Engine

↓

Ground Station

↓

Health Monitor

↓

Mission Reports

---

## Module Responsibilities

### Virtual Sensors

Generates simulated sensor values.

Inputs:

None

Outputs:

sensor_data.csv

---

### Flight Computer

Processes sensor information.

Performs basic system checks.

Generates flight_log.csv.

---

### Telemetry Engine

Converts flight logs into telemetry packets.

Produces telemetry_packets.json.

---

### Ground Station

Displays telemetry information.

Creates mission reports.

---

### Health Monitor

Analyzes telemetry.

Detects abnormal conditions.

Produces health_report.txt.

---

## Supporting Modules

config/

Stores configuration constants.

utils/

Logging utilities.

models/

Future reusable classes.

reports/

Generated reports.

logs/

Runtime logs.