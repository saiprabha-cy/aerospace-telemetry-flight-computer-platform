import csv
import time
import random

# Number of samples to generate
NUM_SAMPLES = 100

# Initial values
altitude = 0.0          # meters
velocity = 0.0          # m/s
temperature = 28.0      # Celsius
battery_voltage = 24.0  # Volts

# CSV file creation
with open("sensor_data.csv", mode="w", newline="") as file:
    writer = csv.writer(file)

    # Header
    writer.writerow([
        "Timestamp",
        "Temperature_C",
        "Altitude_m",
        "Velocity_mps",
        "Battery_V"
    ])

    print("Generating sensor data...\n")

    for second in range(NUM_SAMPLES):

        # Simulated rocket ascent behaviour

        velocity += random.uniform(1, 5)

        altitude += velocity

        temperature += random.uniform(-0.3, 0.5)

        battery_voltage -= random.uniform(0.005, 0.02)

        timestamp = second

        # Console Output
        print(
            f"Time: {timestamp:03d}s | "
            f"Temp: {temperature:.2f}°C | "
            f"Alt: {altitude:.2f}m | "
            f"Vel: {velocity:.2f}m/s | "
            f"Battery: {battery_voltage:.2f}V"
        )

        # CSV Output
        writer.writerow([
            timestamp,
            round(temperature, 2),
            round(altitude, 2),
            round(velocity, 2),
            round(battery_voltage, 2)
        ])

print("\nSensor simulation completed.")
print("Data saved to sensor_data.csv")