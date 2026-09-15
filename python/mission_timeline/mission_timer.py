"""
mission_timer.py

Mission Elapsed Time (MET) simulator.
"""

import time

from mission_timeline.mission_events import MISSION_EVENTS


class MissionTimer:

    def __init__(self):

        self.start_time = -10
        self.end_time = 100

    def run(self):

        print("\n========== Mission Timeline ==========\n")

        for current_time in range(self.start_time,
                                  self.end_time + 1):

            if current_time < 0:
                print(f"T{current_time}")

            else:
                print(f"T+{current_time}")

            if current_time in MISSION_EVENTS:

                print(f"EVENT : {MISSION_EVENTS[current_time]}")

            time.sleep(0.05)

        print("\nMission Timeline Finished.")

if __name__ == "__main__":

    timer = MissionTimer()
    timer.run()