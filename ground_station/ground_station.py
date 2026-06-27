import json
import os

INPUT_FILE = "../telemetry/telemetry_packets.json"
OUTPUT_FILE = "mission_report.txt"

if not os.path.exists(INPUT_FILE):
    print("Telemetry packets not found.")
    exit()

with open(INPUT_FILE, "r") as file:
    packets = json.load(file)

print("\n========== MISSION CONTROL ==========\n")

healthy_count = 0
warning_count = 0

with open(OUTPUT_FILE, "w") as report:

    report.write("MISSION REPORT\n")
    report.write("====================\n\n")

    for packet in packets:

        print(f"Packet ID : {packet['packet_id']}")
        print(f"Time      : {packet['timestamp']} s")
        print(f"Altitude  : {packet['altitude_m']} m")
        print(f"Velocity  : {packet['velocity_mps']} m/s")
        print(f"Battery   : {packet['battery_V']} V")
        print(f"Status    : {packet['system_status']}")
        print("-----------------------------")

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

print("\nMission report generated successfully.")