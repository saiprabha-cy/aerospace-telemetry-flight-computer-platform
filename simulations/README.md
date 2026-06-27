# Virtual Sensor Simulation

## Overview

This module simulates the onboard sensors of a launch vehicle.

The generated data represents the information that would normally be acquired from physical sensors during a rocket mission.

## Simulated Sensors

- Temperature Sensor
- Altitude Sensor
- Velocity Sensor
- Battery Voltage Sensor

## Output

The simulation generates:

- Console telemetry output
- sensor_data.csv

The CSV file will be used by the Flight Computer module in the next phase.

## Technologies Used

- Python
- CSV Module

## Future Improvements

- Pressure Sensor
- IMU (Accelerometer + Gyroscope)
- GPS Simulation
- Fuel Tank Level
- Random Sensor Noise
- Sensor Failure Simulation