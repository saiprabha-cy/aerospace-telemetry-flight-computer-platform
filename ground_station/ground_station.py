import sys
import os
import json

# Add project root to Python path
sys.path.append(
    os.path.abspath(
        os.path.join(os.path.dirname(__file__), "..")
    )
)

from utils.logger import logger

from config.paths import (
    TELEMETRY_FILE,
    MISSION_REPORT_FILE
)

# Input and Output files
INPUT_FILE = TELEMETRY_FILE
OUTPUT_FILE = MISSION_REPORT_FILE

# Check whether telemetry file exists
if not os.path.exists(INPUT_FILE):
    logger.error("telemetry_packets.json not found.")
    raise FileNotFoundError(INPUT_FILE)

logger.info("Starting Ground Station Mission Control...")

healthy_count = 0
warning_count = 0

try:

    with open(INPUT_FILE, "r") as file:
        packets = json.load(file)

    with open(OUTPUT_FILE, "w") as report:

        report.write("MISSION REPORT\n")
        report.write("====================\n\n")

        for packet in packets:

            logger.info(
                f"Packet {packet['packet_id']} | "
                f"Time {packet['timestamp']} s | "
                f"Altitude {packet['altitude_m']} m | "
                f"Velocity {packet['velocity_mps']} m/s | "
                f"Battery {packet['battery_V']} V | "
                f"Status {packet['system_status']}"
            )

            report.write(
                f"Packet {packet['packet_id']} | "
                f"Time {packet['timestamp']} s | "
                f"Altitude {packet['altitude_m']} m | "
                f"Velocity {packet['velocity_mps']} m/s | "
                f"Battery {packet['battery_V']} V | "
                f"Status {packet['system_status']}\n"
            )

            if packet["system_status"] == "HEALTHY":
                healthy_count += 1
            else:
                warning_count += 1

        report.write("\n====================\n")
        report.write(f"Healthy Packets : {healthy_count}\n")
        report.write(f"Warning Packets : {warning_count}\n")

    logger.info("Mission report generated successfully.")
    logger.info(f"Healthy Packets : {healthy_count}")
    logger.info(f"Warning Packets : {warning_count}")

except Exception as e:
    logger.exception(f"Ground Station failed: {e}")