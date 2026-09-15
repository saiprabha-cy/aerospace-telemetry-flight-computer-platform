#ifndef SCHEDULER_H
#define SCHEDULER_H

#include "flight_data.h"

void scheduler_init(void);
void scheduler_run(FlightData *data);

#endif /* SCHEDULER_H */
