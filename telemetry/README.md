# Telemetry Engine

## Overview

The Telemetry Engine converts processed flight computer data into structured telemetry packets.

These packets simulate the data that would be transmitted from a launch vehicle to a ground station during flight.

## Input

flight_log.csv

## Output

telemetry_packets.json

## Responsibilities

- Read validated flight data
- Create telemetry packets
- Assign packet IDs
- Add timestamps
- Store telemetry packets in JSON format

## Future Improvements

- Binary packet encoding
- CRC error checking
- Packet compression
- Encryption
- Wireless communication simulation