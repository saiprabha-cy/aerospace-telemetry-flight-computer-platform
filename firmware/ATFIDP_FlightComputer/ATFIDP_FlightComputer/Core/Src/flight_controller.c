#include "flight_controller.h"
#include "logger.h"
#include <stddef.h>

void flight_controller_init(void)
{
    logger_info("Flight Controller Initialized");
}

void flight_controller_update(const FlightData *data)
{
    if (data == NULL)
    {
        logger_info("Flight Controller Error: NULL data pointer");
        return;
    }

    logger_info("Flight Controller Update");
}
