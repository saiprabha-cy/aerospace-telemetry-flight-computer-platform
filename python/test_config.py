from config.mission_loader import load_config

config = load_config()

print(config["mission"]["name"])
print(config["mission"]["version"])
print(config["simulation"]["samples"])
print(config["battery"]["warning_voltage"])