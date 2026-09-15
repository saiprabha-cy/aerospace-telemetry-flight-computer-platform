import unittest
import sys
import os

sys.path.append(
    os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..")
    )
)

from models.health_monitor import HealthMonitor


class TestHealthMonitor(unittest.TestCase):

    def setUp(self):
        self.monitor = HealthMonitor()

    def test_healthy(self):
        status = self.monitor.evaluate(
            battery=23.5,
            temperature=35,
            altitude=100,
            velocity=25
        )
        self.assertEqual(status, "HEALTHY")

    def test_low_battery(self):
        status = self.monitor.evaluate(
            battery=20,
            temperature=30,
            altitude=100,
            velocity=25
        )
        self.assertEqual(status, "LOW BATTERY")

    def test_high_temperature(self):
        status = self.monitor.evaluate(
            battery=23,
            temperature=100,
            altitude=100,
            velocity=25
        )
        self.assertEqual(status, "HIGH TEMPERATURE")


if __name__ == "__main__":
    unittest.main()