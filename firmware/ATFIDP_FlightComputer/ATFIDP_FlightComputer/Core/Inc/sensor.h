#ifndef SENSOR_H
#define SENSOR_H

#include "flight_data.h"

void sensor_init(void);

void sensor_update(FlightData *data);

#endif /* SENSOR_H */
