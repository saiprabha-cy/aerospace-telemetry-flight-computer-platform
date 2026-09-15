"""
ATFIDP Configuration File

This module stores all configurable parameters used
throughout the Aerospace Telemetry and Flight Computer
Integrated Development Platform.
"""

# ----------------------------
# Simulation Configuration
# ----------------------------

NUM_SAMPLES = 100

INITIAL_TEMPERATURE = 28.0      # Celsius
INITIAL_ALTITUDE = 0.0          # meters
INITIAL_VELOCITY = 0.0          # m/s
INITIAL_BATTERY = 24.0          # Volts

# ----------------------------
# Sensor Thresholds
# ----------------------------

LOW_BATTERY_LIMIT = 22.0

HIGH_TEMPERATURE_LIMIT = 80.0

MAX_ALTITUDE = 100000

MAX_VELOCITY = 8000

# ----------------------------
# Project Information
# ----------------------------

PROJECT_NAME = "ATFIDP"

VERSION = "1.0.0"