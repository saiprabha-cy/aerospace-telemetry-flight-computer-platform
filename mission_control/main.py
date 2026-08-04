import sys
import os

PROJECT_ROOT = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..")
)

sys.path.append(PROJECT_ROOT)

from mission_control.mission_controller import execute_complete_mission


def main():
    execute_complete_mission()


if __name__ == "__main__":
    main()