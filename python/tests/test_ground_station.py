import unittest
import sys
import os

sys.path.append(
    os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..")
    )
)

from models.ground_station import GroundStation


class TestGroundStation(unittest.TestCase):

    def test_packet_count(self):

        gs = GroundStation()

        gs.update("HEALTHY")
        gs.update("HEALTHY")
        gs.update("LOW BATTERY")

        summary = gs.summary()

        self.assertEqual(summary["Total"], 3)
        self.assertEqual(summary["Healthy"], 2)
        self.assertEqual(summary["Warning"], 1)


if __name__ == "__main__":
    unittest.main()