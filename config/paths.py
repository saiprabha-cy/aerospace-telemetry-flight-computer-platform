import os

# Project Root
PROJECT_ROOT = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..")
)

# Simulation Files
SENSOR_DATA_FILE = os.path.join(
    PROJECT_ROOT,
    "simulations",
    "sensor_data.csv"
)

# Flight Computer Files
FLIGHT_LOG_FILE = os.path.join(
    PROJECT_ROOT,
    "flight_computer",
    "flight_log.csv"
)

# Telemetry Files
TELEMETRY_FILE = os.path.join(
    PROJECT_ROOT,
    "telemetry",
    "telemetry_packets.json"
)

# Ground Station Files
MISSION_REPORT_FILE = os.path.join(
    PROJECT_ROOT,
    "ground_station",
    "mission_report.txt"
)

# Testing Files
HEALTH_REPORT_FILE = os.path.join(
    PROJECT_ROOT,
    "testing",
    "health_report.txt"
)