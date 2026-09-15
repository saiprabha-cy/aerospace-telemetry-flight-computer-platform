#ifndef FLIGHT_CONTROLLER_H
#define FLIGHT_CONTROLLER_H

#include "flight_data.h"

void flight_controller_init(void);
void flight_controller_update(const FlightData *data);

#endif /* FLIGHT_CONTROLLER_H */
