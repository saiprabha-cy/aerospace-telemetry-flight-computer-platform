from dataclasses import dataclass

@dataclass
class SensorData:
    timestamp: int
    temperature: float
    altitude: float
    velocity: float
    battery: float