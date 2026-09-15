import sys
import os
import csv

# Add project root to Python path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from utils.logger import logger

from config.config import (
    LOW_BATTERY_LIMIT,
    HIGH_TEMPERATURE_LIMIT
)

from config.paths import (
    SENSOR_DATA_FILE,
    FLIGHT_LOG_FILE
)

# Input and Output files
INPUT_FILE = SENSOR_DATA_FILE
OUTPUT_FILE = FLIGHT_LOG_FILE

# Check whether sensor data exists
if not os.path.exists(INPUT_FILE):
    logger.error("sensor_data.csv not found.")
    raise FileNotFoundError(INPUT_FILE)

logger.info("Reading sensor data...")

try:

    with open(INPUT_FILE, "r") as infile, open(OUTPUT_FILE, "w", newline="") as outfile:

        reader = csv.DictReader(infile)

        fieldnames = [
            "Timestamp",
            "Temperature_C",
            "Altitude_m",
            "Velocity_mps",
            "Battery_V",
            "System_Status"
        ]

        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        writer.writeheader()

        for row in reader:

            temperature = float(row["Temperature_C"])
            altitude = float(row["Altitude_m"])
            velocity = float(row["Velocity_mps"])
            battery = float(row["Battery_V"])

            status = "HEALTHY"

            if battery < LOW_BATTERY_LIMIT:
                status = "LOW BATTERY"

            if temperature > HIGH_TEMPERATURE_LIMIT:
                status = "HIGH TEMPERATURE"

            if altitude < 0:
                status = "ALTITUDE ERROR"

            logger.info(
                f"Time: {row['Timestamp']} s | "
                f"Temp: {temperature:.2f} °C | "
                f"Altitude: {altitude:.2f} m | "
                f"Velocity: {velocity:.2f} m/s | "
                f"Battery: {battery:.2f} V | "
                f"Status: {status}"
            )

            writer.writerow({
                "Timestamp": row["Timestamp"],
                "Temperature_C": temperature,
                "Altitude_m": altitude,
                "Velocity_mps": velocity,
                "Battery_V": battery,
                "System_Status": status
            })

    logger.info("Flight Computer Processing Complete.")
    logger.info("flight_log.csv generated successfully.")

except Exception as e:
    logger.exception(f"Flight computer failed: {e}")