# Flight Computer Core

## Overview

The Flight Computer Core is the central processing unit of the Aerospace Telemetry and Flight Computer Integrated Development Platform.

Its responsibility is to read simulated sensor data, validate it, determine the health of the system, and generate a processed flight log.

## Responsibilities

- Read sensor data
- Validate sensor values
- Detect abnormal conditions
- Generate system health status
- Store processed flight data

## Input

sensor_data.csv

## Output

flight_log.csv

## Future Improvements

- CRC validation
- Sensor redundancy
- Fault recovery
- Event logging
- RTOS task simulation