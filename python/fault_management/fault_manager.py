"""
fault_manager.py

Fault Detection and Classification Module

This module analyses sensor values and reports
faults detected by the Flight Computer.
"""


class FaultManager:

    LOW_BATTERY_LIMIT = 22.0
    HIGH_TEMPERATURE_LIMIT = 80.0

    def analyze(self, sensor_data):

        faults = []

        if sensor_data["Battery_V"] < self.LOW_BATTERY_LIMIT:
            faults.append("WARNING : LOW BATTERY")

        if sensor_data["Temperature_C"] > self.HIGH_TEMPERATURE_LIMIT:
            faults.append("WARNING : HIGH TEMPERATURE")

        if sensor_data["Altitude_m"] < 0:
            faults.append("ERROR : INVALID ALTITUDE")

        if sensor_data["Velocity_mps"] < 0:
            faults.append("ERROR : INVALID VELOCITY")

        if len(faults) == 0:
            faults.append("SYSTEM HEALTHY")

        return faults