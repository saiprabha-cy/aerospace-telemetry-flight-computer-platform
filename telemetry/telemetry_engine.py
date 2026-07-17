import sys
import os
import csv
import json

# Add project root to Python path
sys.path.append(
    os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..")
    )
)

from utils.logger import logger

from config.paths import (
    FLIGHT_LOG_FILE,
    TELEMETRY_FILE
)

# Input and Output files
INPUT_FILE = FLIGHT_LOG_FILE
OUTPUT_FILE = TELEMETRY_FILE

# Check input file
if not os.path.exists(INPUT_FILE):
    logger.error("flight_log.csv not found.")
    raise FileNotFoundError(INPUT_FILE)

logger.info("Generating telemetry packets...")

telemetry_packets = []

try:

    with open(INPUT_FILE, "r") as csvfile:

        reader = csv.DictReader(csvfile)

        packet_id = 1

        for row in reader:

            packet = {
                "packet_id": packet_id,
                "timestamp": row["Timestamp"],
                "temperature_C": float(row["Temperature_C"]),
                "altitude_m": float(row["Altitude_m"]),
                "velocity_mps": float(row["Velocity_mps"]),
                "battery_V": float(row["Battery_V"]),
                "system_status": row["System_Status"]
            }

            telemetry_packets.append(packet)

            logger.info(f"Packet {packet_id} generated.")

            packet_id += 1

    with open(OUTPUT_FILE, "w") as outfile:
        json.dump(telemetry_packets, outfile, indent=4)

    logger.info("Telemetry generation completed.")
    logger.info("telemetry_packets.json created successfully.")

except Exception as e:
    logger.exception(f"Telemetry Engine failed: {e}")