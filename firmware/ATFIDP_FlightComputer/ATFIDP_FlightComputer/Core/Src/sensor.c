#include "sensor.h"
#include "logger.h"
#include <stddef.h>

void sensor_init(void)
{
    logger_info("Sensor Module Initialized");
}

void sensor_update(FlightData *data)
{
    if (data == NULL)
    {
        logger_info("Sensor Error: NULL data pointer");
        return;
    }

    /*
     * Software-only sensor simulation.
     *
     * These values represent what real sensors
     * could eventually provide.
     */

    data->temperature_c = 25.0f;
    data->altitude_m = 1000.0f;
    data->velocity_mps = 120.0f;
    data->battery_v = 24.0f;
}
