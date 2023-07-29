`include "defines.v"
`include "baudRateGenerator.v"

`ifdef UART_TX_ONLY
    `include "uart_tx_controller.v"

`elsif UART_RX_ONLY
    `include "uart_rx_controller.v"

`else
    `include "uart_tx_controller.v"
    `include "uart_rx_controller.v"

`endif