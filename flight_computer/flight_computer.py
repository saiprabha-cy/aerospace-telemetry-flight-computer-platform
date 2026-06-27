import csv
import os

# Path to input sensor data
INPUT_FILE = "../simulations/sensor_data.csv"

# Output flight log
OUTPUT_FILE = "flight_log.csv"

# Check if sensor data exists
if not os.path.exists(INPUT_FILE):
    print("Error: sensor_data.csv not found.")
    exit()

print("Reading sensor data...\n")

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

        if battery < 22:
            status = "LOW BATTERY"

        if temperature > 80:
            status = "HIGH TEMPERATURE"

        if altitude < 0:
            status = "ALTITUDE ERROR"

        print("-------------------------------------")
        print(f"Time        : {row['Timestamp']} s")
        print(f"Temperature : {temperature:.2f} °C")
        print(f"Altitude    : {altitude:.2f} m")
        print(f"Velocity    : {velocity:.2f} m/s")
        print(f"Battery     : {battery:.2f} V")
        print(f"Status      : {status}")

        writer.writerow({
            "Timestamp": row["Timestamp"],
            "Temperature_C": temperature,
            "Altitude_m": altitude,
            "Velocity_mps": velocity,
            "Battery_V": battery,
            "System_Status": status
        })

print("\nFlight Computer Processing Complete.")
print("flight_log.csv generated successfully.")