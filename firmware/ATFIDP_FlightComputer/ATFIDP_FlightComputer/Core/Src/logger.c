#include <stdio.h>
#include <stddef.h>
#include "logger.h"

void logger_init(void)
{
    printf("Logger Initialized\n");
}

void logger_info(const char *message)
{
    printf("[INFO] %s\n", message);
}

void logger_log(const char *message)
{
    logger_info(message);
}

void logger_hex_dump(const uint8_t *data, uint16_t length)
{
    if (data == NULL)
    {
        logger_info("Hex Dump Error: NULL data pointer");
        return;
    }

    printf("[HEX] ");

    for (uint16_t i = 0U; i < length; i++)
    {
        printf("%02X ", data[i]);
    }

    printf("\n");
}
