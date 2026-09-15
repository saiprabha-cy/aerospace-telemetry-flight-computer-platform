#include "telemetry_uart.h"
#include "main.h"
#include "logger.h"
#include <stddef.h>

extern UART_HandleTypeDef huart2;

void telemetry_uart_init(void)
{
    logger_info("Telemetry UART Initialized");
}

uint8_t telemetry_uart_send(const uint8_t *data, uint16_t length)
{
    if ((data == NULL) || (length == 0U))
    {
        logger_info("Telemetry UART Error: Invalid data");
        return 0U;
    }

    HAL_StatusTypeDef result =
        HAL_UART_Transmit(&huart2,
                          (uint8_t *)data,
                          length,
                          100U);

    if (result != HAL_OK)
    {
        logger_info("Telemetry UART Error: Transmission Failed");
        return 0U;
    }

    return 1U;
}
