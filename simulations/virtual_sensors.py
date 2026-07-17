import sys
import os

# Add project root to Python path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

import csv
import random

from utils.logger import logger
from config.config import (
    NUM_SAMPLES,
    INITIAL_TEMPERATURE,
    INITIAL_ALTITUDE,
    INITIAL_VELOCITY,
    INITIAL_BATTERY
)
from config.paths import SENSOR_DATA_FILE

# Output CSV path
OUTPUT_FILE = SENSOR_DATA_FILE

# Initial values
altitude = INITIAL_ALTITUDE
velocity = INITIAL_VELOCITY
temperature = INITIAL_TEMPERATURE
battery_voltage = INITIAL_BATTERY

logger.info("Generating sensor data...")

try:
    with open(OUTPUT_FILE, "w", newline="") as csvfile:

        writer = csv.writer(csvfile)

        writer.writerow([
            "Timestamp",
            "Temperature_C",
            "Altitude_m",
            "Velocity_mps",
            "Battery_V"
        ])

        for second in range(NUM_SAMPLES):

            # Simulated rocket ascent behaviour
            velocity += random.uniform(1, 5)
            altitude += velocity
            temperature += random.uniform(-0.3, 0.5)
            battery_voltage -= random.uniform(0.005, 0.02)

            timestamp = second

            logger.info(
                f"Time: {timestamp:03d}s | "
                f"Temp: {temperature:.2f}°C | "
                f"Alt: {altitude:.2f}m | "
                f"Vel: {velocity:.2f}m/s | "
                f"Battery: {battery_voltage:.2f}V"
            )

            writer.writerow([
                timestamp,
                round(temperature, 2),
                round(altitude, 2),
                round(velocity, 2),
                round(battery_voltage, 2)
            ])

    logger.info("Sensor simulation completed.")
    logger.info("sensor_data.csv generated successfully.")

except Exception as e:
    logger.exception(f"Failed to generate sensor_data.csv: {e}")