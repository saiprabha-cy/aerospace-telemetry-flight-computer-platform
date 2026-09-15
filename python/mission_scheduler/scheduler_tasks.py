"""
scheduler_tasks.py

Mission Scheduler Tasks

This module defines all periodic tasks that are executed
by the Mission Scheduler.

Later these tasks will become RTOS tasks running on STM32.
"""

import time


def sensor_task():
    print("  [Sensor Task] Reading sensors...")
    time.sleep(0.1)


def flight_computer_task():
    print("  [Flight Computer Task] Processing sensor data...")
    time.sleep(0.1)


def telemetry_task():
    print("  [Telemetry Task] Creating telemetry packet...")
    time.sleep(0.1)


def ground_station_task():
    print("  [Ground Station Task] Sending telemetry...")
    time.sleep(0.1)


def health_monitor_task():
    print("  [Health Monitor Task] Checking system health...")
    time.sleep(0.1)