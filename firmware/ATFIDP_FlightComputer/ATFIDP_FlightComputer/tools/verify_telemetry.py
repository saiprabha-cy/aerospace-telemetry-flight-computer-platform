from struct import unpack_from


PACKET_LENGTH = 22
SYNC = 0xAA55
VERSION = 0x01


def crc16_modbus(data):
    crc = 0xFFFF

    for byte in data:
        crc ^= byte

        for _ in range(8):
            if crc & 1:
                crc = (crc >> 1) ^ 0xA001
            else:
                crc >>= 1

    return crc & 0xFFFF


def verify_packet(packet):
    if len(packet) != PACKET_LENGTH:
        raise ValueError(f"Invalid packet length: {len(packet)}")

    sync = unpack_from("<H", packet, 0)[0]
    version = packet[2]

    sequence = unpack_from("<I", packet, 3)[0]
    timestamp = unpack_from("<I", packet, 7)[0]

    temperature = unpack_from("<H", packet, 11)[0] / 10.0
    altitude = unpack_from("<H", packet, 13)[0]
    velocity = unpack_from("<H", packet, 15)[0] / 10.0
    battery = unpack_from("<H", packet, 17)[0] / 100.0

    status = packet[19]

    received_crc = unpack_from("<H", packet, 20)[0]
    calculated_crc = crc16_modbus(packet[:20])

    print("Telemetry Packet")
    print("----------------")
    print(f"Length     : {len(packet)} bytes")
    print(f"Sync       : 0x{sync:04X}")
    print(f"Version    : {version}")
    print(f"Sequence   : {sequence}")
    print(f"Timestamp  : {timestamp} s")
    print(f"Temperature: {temperature:.1f} °C")
    print(f"Altitude   : {altitude} m")
    print(f"Velocity   : {velocity:.1f} m/s")
    print(f"Battery    : {battery:.2f} V")
    print(f"Status     : {status}")
    print(f"CRC RX     : 0x{received_crc:04X}")
    print(f"CRC CALC   : 0x{calculated_crc:04X}")

    if sync != SYNC:
        raise ValueError("FAIL: Invalid sync")

    if version != VERSION:
        raise ValueError("FAIL: Invalid version")

    if received_crc != calculated_crc:
        raise ValueError("FAIL: CRC mismatch")

    print("\nTelemetry verification: PASS")


if __name__ == "__main__":
    packet = bytes.fromhex(
        "55 AA "
        "01 "
        "00 00 00 00 "
        "00 00 00 00 "
        "FA 00 "
        "E8 03 "
        "B0 04 "
        "60 09 "
        "00 "
        "18 13"
    )

    verify_packet(packet)