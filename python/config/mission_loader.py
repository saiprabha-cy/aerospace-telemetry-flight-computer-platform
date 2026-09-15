"""
mission_loader.py

Loads mission configuration from mission.json.
"""

import json
import os

from config.paths import PROJECT_ROOT

MISSION_FILE = os.path.join(
    PROJECT_ROOT,
    "config",
    "mission.json"
)


def load_config():
    with open(MISSION_FILE, "r") as file:
        return json.load(file)


# Load once when the module is imported
CONFIG = load_config()