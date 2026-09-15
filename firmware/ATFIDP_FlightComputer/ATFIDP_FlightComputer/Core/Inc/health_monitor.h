#ifndef HEALTH_MONITOR_H
#define HEALTH_MONITOR_H

#include "flight_data.h"

void health_monitor_init(void);
void health_monitor_update(FlightData *data);

#endif
