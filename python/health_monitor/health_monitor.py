import sys
import os
import csv

# Add project root to Python path
sys.path.append(
    os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..")
    )
)

from utils.logger import logger

from config.paths import (
    FLIGHT_LOG_FILE,
    HEALTH_REPORT_FILE
)

# Input and Output files
INPUT_FILE = FLIGHT_LOG_FILE
OUTPUT_FILE = HEALTH_REPORT_FILE

# Check whether flight log exists
if not os.path.exists(INPUT_FILE):
    logger.error("flight_log.csv not found.")
    raise FileNotFoundError(INPUT_FILE)

logger.info("Starting Health Monitor...")

healthy = 0
warning = 0

try:

    with open(INPUT_FILE, "r") as csvfile, open(OUTPUT_FILE, "w") as report:

        reader = csv.DictReader(csvfile)

        report.write("HEALTH REPORT\n")
        report.write("=========================\n\n")

        for row in reader:

            battery = float(row["Battery_V"])
            temperature = float(row["Temperature_C"])
            altitude = float(row["Altitude_m"])
            velocity = float(row["Velocity_mps"])

            faults = []

            if battery < 22.0:
                faults.append("LOW BATTERY")

            if temperature > 80:
                faults.append("HIGH TEMPERATURE")

            if altitude < 0:
                faults.append("INVALID ALTITUDE")

            if velocity < 0:
                faults.append("INVALID VELOCITY")

            if len(faults) == 0:
                status = "HEALTHY"
                healthy += 1
            else:
                status = ", ".join(faults)
                warning += 1

            logger.info(
                f"Time {row['Timestamp']} s | Status: {status}"
            )

            report.write(
                f"Time {row['Timestamp']} s : {status}\n"
            )

        report.write("\n=========================\n")
        report.write(f"Healthy Records : {healthy}\n")
        report.write(f"Warning Records : {warning}\n")

    logger.info("Health report generated successfully.")
    logger.info(f"Healthy Records : {healthy}")
    logger.info(f"Warning Records : {warning}")

except Exception as e:
    logger.exception(f"Health Monitor failed: {e}")