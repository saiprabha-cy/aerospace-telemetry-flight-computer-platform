from enum import Enum


class MissionState(Enum):
    INITIALIZATION = "Initialization"

    SENSOR_SIMULATION = "Sensor Simulation"

    FLIGHT_COMPUTER = "Flight Computer"

    TELEMETRY = "Telemetry"

    GROUND_STATION = "Ground Station"

    HEALTH_MONITOR = "Health Monitor"

    COMPLETED = "Mission Completed"

    FAILED = "Mission Failed"