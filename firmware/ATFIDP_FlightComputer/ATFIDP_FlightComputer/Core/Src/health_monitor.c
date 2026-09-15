#include "health_monitor.h"
#include "logger.h"
#include <stddef.h>

void health_monitor_init(void)
{
    logger_info("Health Monitor Initialized");
}

void health_monitor_update(FlightData *data)
{
    if (data == NULL)
    {
        logger_info("Health Monitor Error: NULL data pointer");
        return;
    }

    data->status = FLIGHT_STATUS_OK;

    if (data->battery_v < 20.0f)
    {
        data->status = FLIGHT_STATUS_WARNING;
        logger_info("Health Warning: Low Battery");
        return;
    }

    if (data->temperature_c > 80.0f)
    {
        data->status = FLIGHT_STATUS_CRITICAL;
        logger_info("Health Critical: High Temperature");
        return;
    }

    logger_info("Health Status: OK");
}
