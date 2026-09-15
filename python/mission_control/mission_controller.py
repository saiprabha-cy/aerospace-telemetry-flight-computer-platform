from state_machine.mission_state_machine import MissionStateMachine
from state_machine.mission_states import MissionState

import subprocess
import sys
import os

# ---------------------------------------------------
# Project Root
# ---------------------------------------------------

PROJECT_ROOT = os.path.abspath(
    os.path.join(
        os.path.dirname(__file__),
        ".."
    )
)

PYTHON = sys.executable


# ---------------------------------------------------
# Execute Individual Module
# ---------------------------------------------------

def run_module(script_path, module_name):
    """
    Execute one subsystem.
    """

    print(f"\n========== {module_name} ==========\n")

    result = subprocess.run(
        [PYTHON, script_path],
        cwd=PROJECT_ROOT
    )

    if result.returncode != 0:
        print(f"{module_name} FAILED")
        return False

    print(f"{module_name} COMPLETED")

    return True


# ---------------------------------------------------
# Complete Mission Execution
# ---------------------------------------------------

def execute_complete_mission():

    print("\n======================================")
    print("ATFIDP Mission Started")
    print("======================================")

    # Create Mission State Machine
    mission = MissionStateMachine()

    modules = [

        (
            MissionState.SENSOR_SIMULATION,
            os.path.join(
                PROJECT_ROOT,
                "simulations",
                "virtual_sensors.py"
            ),
            "Virtual Sensors"
        ),

        (
            MissionState.FLIGHT_COMPUTER,
            os.path.join(
                PROJECT_ROOT,
                "flight_computer",
                "flight_computer.py"
            ),
            "Flight Computer"
        ),

        (
            MissionState.TELEMETRY,
            os.path.join(
                PROJECT_ROOT,
                "telemetry",
                "telemetry_engine.py"
            ),
            "Telemetry Engine"
        ),

        (
            MissionState.GROUND_STATION,
            os.path.join(
                PROJECT_ROOT,
                "ground_station",
                "ground_station.py"
            ),
            "Ground Station"
        ),

        (
            MissionState.HEALTH_MONITOR,
            os.path.join(
                PROJECT_ROOT,
                "health_monitor",
                "health_monitor.py"
            ),
            "Health Monitor"
        )

    ]

    # Execute each subsystem

    for state, script, name in modules:

        mission.transition_to(state)

        success = run_module(script, name)

        if not success:

            mission.transition_to(MissionState.FAILED)

            print("\nMission Aborted.")

            return

    # Mission completed successfully

    mission.transition_to(MissionState.COMPLETED)

    print("\n======================================")
    print("MISSION SUCCESSFULLY COMPLETED")
    print("======================================")