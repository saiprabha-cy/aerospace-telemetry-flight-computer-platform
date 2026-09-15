#ifndef LOGGER_H
#define LOGGER_H

#include <stdint.h>

void logger_init(void);
void logger_info(const char *message);
void logger_log(const char *message);
void logger_hex_dump(const uint8_t *data, uint16_t length);

#endif
