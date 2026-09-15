import unittest
import sys
import os

sys.path.append(
    os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..")
    )
)

from models.telemetry_packet import TelemetryPacket


class TestTelemetry(unittest.TestCase):

    def test_packet(self):

        packet = TelemetryPacket(
            packet_id=1,
            timestamp=0,
            temperature=30,
            altitude=100,
            velocity=15,
            battery=23.9,
            status="HEALTHY"
        )

        self.assertEqual(packet.packet_id, 1)
        self.assertEqual(packet.status, "HEALTHY")


if __name__ == "__main__":
    unittest.main()