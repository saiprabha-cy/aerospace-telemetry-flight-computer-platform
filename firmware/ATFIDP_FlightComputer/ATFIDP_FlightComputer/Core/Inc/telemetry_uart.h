#ifndef TELEMETRY_UART_H
#define TELEMETRY_UART_H

#include <stdint.h>

void telemetry_uart_init(void);

uint8_t telemetry_uart_send(const uint8_t *data, uint16_t length);

#endif /* TELEMETRY_UART_H */
