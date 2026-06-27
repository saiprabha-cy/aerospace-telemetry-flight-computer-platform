# Health Monitoring and Fault Detection

## Overview

This module evaluates the health of the simulated launch vehicle.

It checks important parameters against predefined limits and generates warnings or fault reports.

## Input

flight_log.csv

## Output

health_report.txt

## Parameters Checked

- Battery Voltage
- Temperature
- Altitude
- Velocity

## Future Improvements

- IMU validation
- Pressure monitoring
- Sensor timeout detection
- Fault prediction
- Health score calculation