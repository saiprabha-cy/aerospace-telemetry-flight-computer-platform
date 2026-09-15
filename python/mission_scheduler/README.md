# Mission Scheduler

## Purpose

The Mission Scheduler controls the execution order of software tasks inside the ATFIDP project.

Instead of executing one large block of code, the scheduler repeatedly executes smaller tasks in a deterministic order.

## Current Tasks

- Sensor Task
- Flight Computer Task
- Telemetry Task
- Ground Station Task
- Health Monitor Task

## Current Scheduler

Version 1 uses a cooperative scheduler.

Each task executes sequentially.
Sensor

↓

Flight Computer

↓

Telemetry

↓

Ground Station

↓

Health Monitor


After all tasks complete, one scheduler cycle finishes.

## Future Improvements

During later development this scheduler will evolve into:

- Timer-driven scheduler
- Interrupt-based scheduler
- STM32 SysTick scheduler
- FreeRTOS task scheduler
- Priority-based scheduling
- Periodic task execution
- Real-time embedded scheduling

## Aerospace Relevance

Mission scheduling is used in:

- Flight Computers
- CubeSat On-Board Computers
- Satellite Avionics
- Rocket Avionics
- UAV Flight Controllers
- Embedded RTOS Systems

The scheduler is the foundation for deterministic real-time software execution.