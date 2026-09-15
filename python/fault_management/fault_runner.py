"""
fault_runner.py

Runs the Fault Injection and Fault Manager together.

This module demonstrates how abnormal sensor data is
generated and immediately analysed.
"""

from fault_management.fault_injection import FaultInjection
from fault_management.fault_manager import FaultManager


def run_fault_management():

    print("\n========== Fault Management ==========\n")

    sensor = {
        "Temperature_C": 30.0,
        "Altitude_m": 1500.0,
        "Velocity_mps": 120.0,
        "Battery_V": 23.5
    }

    injector = FaultInjection()

    # Enable sample faults
    injector.enable_low_battery()
    injector.enable_high_temperature()

    sensor = injector.apply(sensor)

    print("Injected Sensor Data")

    for key, value in sensor.items():
        print(f"{key} : {value}")

    manager = FaultManager()

    faults = manager.analyze(sensor)

    print("\nDetected Faults")

    for fault in faults:
        print(f"- {fault}")

    print("\nFault Management Completed.")


if __name__ == "__main__":
    run_fault_management()