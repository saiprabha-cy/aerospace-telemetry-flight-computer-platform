from dataclasses import dataclass

@dataclass
class TelemetryPacket:

    packet_id: int

    timestamp: int

    temperature: float

    altitude: float

    velocity: float

    battery: float

    status: str