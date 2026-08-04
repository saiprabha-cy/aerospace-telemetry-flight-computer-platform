import unittest
import sys
import os

sys.path.append(
    os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..")
    )
)

from models.sensor import SensorData


class TestSensor(unittest.TestCase):

    def test_sensor_creation(self):

        sensor = SensorData(
            timestamp=1,
            temperature=28.5,
            altitude=120,
            velocity=12,
            battery=23.8
        )

        self.assertEqual(sensor.temperature, 28.5)
        self.assertEqual(sensor.altitude, 120)
        self.assertEqual(sensor.velocity, 12)
        self.assertEqual(sensor.battery, 23.8)


if __name__ == "__main__":
    unittest.main()