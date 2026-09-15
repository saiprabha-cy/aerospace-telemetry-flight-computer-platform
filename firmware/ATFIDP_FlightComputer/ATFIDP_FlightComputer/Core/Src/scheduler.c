#include "main.h"
#include "scheduler.h"
#include "logger.h"
#include "sensor.h"
#include "health_monitor.h"
#include "flight_controller.h"
#include "telemetry.h"
#include "mission.h"
#include "telemetry_uart.h"
#include <stddef.h>

void scheduler_init(void)
{
    logger_info("Scheduler Initialized");
}

void scheduler_run(FlightData *data)
{
    if (data == NULL)
    {
        logger_info("Scheduler Error: NULL data pointer");
        return;
    }

    sensor_update(data);

    data->timestamp_s = HAL_GetTick() / 1000U;

    health_monitor_update(data);
    flight_controller_update(data);
    mission_run();
    static uint32_t sequence = 0U;
    static uint8_t telemetry_packet[TELEMETRY_MAX_PACKET];

    uint16_t packet_length = telemetry_build_packet(
        data,
        sequence++,
        telemetry_packet,
        sizeof(telemetry_packet)
    );

    if (packet_length > 0U)
    {
        logger_info("Telemetry Packet Built");
        logger_hex_dump(telemetry_packet, packet_length);

        if (telemetry_verify_packet(telemetry_packet, packet_length) != 0U)
        {
            logger_info("Telemetry Packet Verification: PASS");

            if (telemetry_uart_send(telemetry_packet, packet_length) != 0U)
            {
                logger_info("Telemetry UART Transmission: PASS");
            }
            else
            {
                logger_info("Telemetry UART Transmission: FAIL");
            }
        }
        else
        {
            logger_info("Telemetry Packet Verification: FAIL");
        }
    }
}
