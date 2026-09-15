#include "telemetry.h"
#include "logger.h"
#include <stddef.h>

static void write_u16_le(uint8_t *buffer, uint16_t value)
{
    buffer[0] = (uint8_t)(value & 0xFFU);
    buffer[1] = (uint8_t)((value >> 8) & 0xFFU);
}

static void write_u32_le(uint8_t *buffer, uint32_t value)
{
    buffer[0] = (uint8_t)(value & 0xFFU);
    buffer[1] = (uint8_t)((value >> 8) & 0xFFU);
    buffer[2] = (uint8_t)((value >> 16) & 0xFFU);
    buffer[3] = (uint8_t)((value >> 24) & 0xFFU);
}

static uint16_t float_to_u16(float value, float scale)
{
    if (value < 0.0f)
    {
        return 0U;
    }

    return (uint16_t)(value * scale);
}

static uint16_t telemetry_crc16(const uint8_t *data, uint16_t length)
{
    uint16_t crc = 0xFFFFU;

    for (uint16_t i = 0U; i < length; i++)
    {
        crc ^= data[i];

        for (uint8_t bit = 0U; bit < 8U; bit++)
        {
            if ((crc & 1U) != 0U)
            {
                crc = (uint16_t)((crc >> 1U) ^ 0xA001U);
            }
            else
            {
                crc >>= 1U;
            }
        }
    }

    return crc;
}

void telemetry_init(void)
{
    logger_info("Telemetry Module Initialized");
}

uint16_t telemetry_build_packet(const FlightData *data,
                                uint32_t sequence,
                                uint8_t *buffer,
                                uint16_t buffer_size)
{
    if ((data == NULL) || (buffer == NULL))
    {
        logger_info("Telemetry Error: NULL argument");
        return 0U;
    }

    /*
     * Packet layout:
     *
     * 0-1   : Sync
     * 2     : Version
     * 3-6   : Sequence
     * 7-10  : Timestamp
     * 11-12 : Temperature x10
     * 13-14 : Altitude
     * 15-16 : Velocity x10
     * 17-18 : Battery x100
     * 19    : Status
     * 20-21 : CRC16
     *
     * Total: 22 bytes
     */

    const uint16_t packet_length = 22U;

    if (buffer_size < packet_length)
    {
        logger_info("Telemetry Error: Buffer too small");
        return 0U;
    }

    write_u16_le(&buffer[0], TELEMETRY_SYNC);

    buffer[2] = TELEMETRY_VERSION;

    write_u32_le(&buffer[3], sequence);

    write_u32_le(&buffer[7], data->timestamp_s);

    write_u16_le(&buffer[11],
                 float_to_u16(data->temperature_c, 10.0f));

    write_u16_le(&buffer[13],
                 float_to_u16(data->altitude_m, 1.0f));

    write_u16_le(&buffer[15],
                 float_to_u16(data->velocity_mps, 10.0f));

    write_u16_le(&buffer[17],
                 float_to_u16(data->battery_v, 100.0f));

    buffer[19] = (uint8_t)data->status;

    uint16_t crc = telemetry_crc16(buffer, 20U);

    write_u16_le(&buffer[20], crc);

    return packet_length;
}

uint8_t telemetry_verify_packet(const uint8_t *buffer, uint16_t length)
{
    if ((buffer == NULL) || (length != 22U))
    {
        return 0U;
    }

    /* Verify sync */
    if ((buffer[0] != 0x55U) || (buffer[1] != 0xAAU))
    {
        return 0U;
    }

    /* Verify protocol version */
    if (buffer[2] != TELEMETRY_VERSION)
    {
        return 0U;
    }

    /* Verify CRC */
    uint16_t received_crc =
        (uint16_t)buffer[20] |
        ((uint16_t)buffer[21] << 8U);

    uint16_t calculated_crc =
        telemetry_crc16(buffer, 20U);

    if (received_crc != calculated_crc)
    {
        return 0U;
    }

    return 1U;
}
