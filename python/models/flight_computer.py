from dataclasses import dataclass

@dataclass
class FlightStatus:

    timestamp: int

    temperature: float

    altitude: float

    velocity: float

    battery: float

    system_status: str