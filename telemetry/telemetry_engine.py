import csv
import json
import os

INPUT_FILE = "../flight_computer/flight_log.csv"
OUTPUT_FILE = "telemetry_packets.json"

if not os.path.exists(INPUT_FILE):
    print("Error: flight_log.csv not found.")
    exit()

telemetry_packets = []

print("Generating telemetry packets...\n")

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

        print(f"Packet {packet_id} generated.")

        packet_id += 1

with open(OUTPUT_FILE, "w") as outfile:
    json.dump(telemetry_packets, outfile, indent=4)

print("\nTelemetry generation completed.")
print("telemetry_packets.json created successfully.")