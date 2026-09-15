"""
scheduler.py

Simple Cooperative Mission Scheduler

This scheduler demonstrates how embedded software executes
periodic tasks before introducing RTOS concepts.
"""

import time

from mission_scheduler.scheduler_tasks import (
    sensor_task,
    flight_computer_task,
    telemetry_task,
    ground_station_task,
    health_monitor_task,
)


class MissionScheduler:

    def __init__(self):

        self.total_cycles = 5

    def run(self):

        print("\n========== Mission Scheduler ==========\n")

        for cycle in range(1, self.total_cycles + 1):

            print(f"\n========== Scheduler Cycle {cycle} ==========\n")

            sensor_task()

            flight_computer_task()

            telemetry_task()

            ground_station_task()

            health_monitor_task()

            print("\nCycle Completed.\n")

            time.sleep(0.5)

        print("Mission Scheduler Finished.")

if __name__ == "__main__":

    scheduler = MissionScheduler()

    scheduler.run()