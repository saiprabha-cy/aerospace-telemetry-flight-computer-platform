#ifndef TELEMETRY_H
#define TELEMETRY_H

#include <stdint.h>
#include "flight_data.h"

#define TELEMETRY_SYNC        0xAA55U
#define TELEMETRY_VERSION     0x01U
#define TELEMETRY_MAX_PACKET  32U

void telemetry_init(void);

uint16_t telemetry_build_packet(const FlightData *data,
                                uint32_t sequence,
                                uint8_t *buffer,
                                uint16_t buffer_size);
uint8_t telemetry_verify_packet(const uint8_t *buffer,uint16_t length);
#endif /* TELEMETRY_H */
