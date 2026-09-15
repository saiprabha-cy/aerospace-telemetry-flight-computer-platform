import unittest
import sys
import os

sys.path.append(
    os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..")
    )
)

from models.flight_computer import FlightStatus


class TestFlightComputer(unittest.TestCase):

    def test_status(self):

        status = FlightStatus(
            timestamp=0,
            temperature=28,
            altitude=100,
            velocity=10,
            battery=23.5,
            system_status="HEALTHY"
        )

        self.assertEqual(status.system_status, "HEALTHY")


if __name__ == "__main__":
    unittest.main()