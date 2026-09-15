"""
fault_injection.py

Fault Injection Module

This module creates artificial faults for testing
the Instrumentation & Telemetry software.

Real aerospace software is tested under abnormal
conditions before deployment.
"""


class FaultInjection:

    def __init__(self):

        self.low_battery = False
        self.high_temperature = False
        self.invalid_altitude = False
        self.invalid_velocity = False

    def enable_low_battery(self):
        self.low_battery = True

    def enable_high_temperature(self):
        self.high_temperature = True

    def enable_invalid_altitude(self):
        self.invalid_altitude = True

    def enable_invalid_velocity(self):
        self.invalid_velocity = True

    def apply(self, sensor_data):

        data = sensor_data.copy()

        if self.low_battery:
            data["Battery_V"] = 20.5

        if self.high_temperature:
            data["Temperature_C"] = 95.0

        if self.invalid_altitude:
            data["Altitude_m"] = -50.0

        if self.invalid_velocity:
            data["Velocity_mps"] = -25.0

        return data