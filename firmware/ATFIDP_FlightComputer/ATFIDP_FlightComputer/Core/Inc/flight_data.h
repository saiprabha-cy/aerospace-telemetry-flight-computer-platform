#ifndef FLIGHT_DATA_H
#define FLIGHT_DATA_H

#include <stdint.h>

typedef enum
{
    FLIGHT_STATUS_OK = 0,
    FLIGHT_STATUS_WARNING,
    FLIGHT_STATUS_CRITICAL
} FlightStatus;

typedef struct
{
    float temperature_c;
    float altitude_m;
    float velocity_mps;
    float battery_v;

    uint32_t timestamp_s;

    FlightStatus status;

} FlightData;

#endif /* FLIGHT_DATA_H */
