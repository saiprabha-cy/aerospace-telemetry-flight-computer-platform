from fault_management.fault_injection import FaultInjection
from fault_management.fault_manager import FaultManager

sensor = {
    "Temperature_C": 30,
    "Altitude_m": 1500,
    "Velocity_mps": 120,
    "Battery_V": 23.5
}

injector = FaultInjection()

injector.enable_low_battery()
injector.enable_high_temperature()

sensor = injector.apply(sensor)

manager = FaultManager()

faults = manager.analyze(sensor)

print("\nSensor Data")
print(sensor)

print("\nDetected Faults")

for fault in faults:
    print("-", fault)