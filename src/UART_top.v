`timescale 1ns/10ps

/* Keep these lines commented if you are using Vivado and simply adding 
the source & sim files without handling `include and `define separately */

//`include "defines.v"
//`include "baudRateGenerator.v"

//`ifdef UART_TX_ONLY
//`include "uart_tx_controller.v"

//`elsif UART_RX_ONLY
//`include "uart_rx_controller.v"

//`else
//`include "uart_tx_controller.v"
//`include "uart_rx_controller.v"

//`endif


module uart_controller #(
    parameter CLOCK_RATE = 25000000,
    parameter BAUD_RATE = 115200,
    parameter RX_OVERSAMPLE = 16)(

    input clk,
    input reset_n,

`ifdef UART_TX_ONLY
    input i_Tx_Ready,          // ready to transmit
    input [7:0] i_Tx_Byte,     // data byte to be transmitted
    output o_Tx_Active,        // goes high when data is transmitting
    output o_Tx_Data,          // serial output data from TX
    output o_Tx_Done,          // transmission done
   
`elsif UART_RX_ONLY   
    input i_Rx_Data,           // serial input data received by RX from TX
    output o_Rx_Done,          // data received
    output [7:0] o_Rx_Byte,    // serial to parallel 8-bit data received

`else  // both TX and RX
    input [7:0] i_Tx_Byte,     // data byte to be transmitted
    input i_Tx_Ready,          // ready to transmit
    output o_Rx_Done,          // data received (asserted for 1 clk cycle) 
    output [7:0] o_Rx_Byte     // serial to parallel 8-bit data received

`endif
    );
  
    wire  
        w_Rx_ClkTick,       // baud rate counter for RX
        w_Tx_ClkTick,       // baud rate counter for TX
        w_Tx_Data_to_Rx;    // connector b/w TX and RX
  
  
`ifdef UART_TX_ONLY
    assign o_Tx_Data = w_Tx_Data_to_Rx;  // serial output data from TX gets transmitted through TX-RX connector

`elsif UART_RX_ONLY
    assign w_Tx_Data_to_Rx = i_Rx_Data;  // serial input data received by RX from TX flows through TX-RX connector

`endif

    //Instantiate Baud Rate Generator 
    baudRateGenerator #(CLOCK_RATE, BAUD_RATE, RX_OVERSAMPLE) xbaudRateGenerator(
        .clk (clk), 
        .reset_n (reset_n), 
        .o_Rx_ClkTick (w_Rx_ClkTick), 
        .o_Tx_ClkTick (w_Tx_ClkTick)
    );
  

`ifdef UART_TX_ONLY

    //Instantiation of TX Controller 
    uart_tx_controller xUART_TX(
        .clk (w_Tx_ClkTick), 
        .reset_n (reset_n), 
        .i_Tx_Byte (i_Tx_Byte), 
        .i_Tx_Ready (i_Tx_Ready), 
        .o_Tx_Done (o_Tx_Done), 
        .o_Tx_Active (o_Tx_Active), 
        .o_Tx_Data (w_Tx_Data_to_Rx)
    );


`elsif UART_RX_ONLY
  
    //Instantiation of RX Controller  
    uart_rx_controller #(RX_OVERSAMPLE) xUART_RX(
        .clk (w_Rx_ClkTick), 
        .reset_n (reset_n), 
        .i_Rx_Data (w_Tx_Data_to_Rx), 
        .o_Rx_Done (o_Rx_Done), 
        .o_Rx_Byte (o_Rx_Byte)
    );
  
`else
  
    //Instantiation of TX Controller 
    uart_tx_controller xUART_TX(
        .clk (w_Tx_ClkTick), 
        .reset_n (reset_n), 
        .i_Tx_Byte (i_Tx_Byte), 
        .i_Tx_Ready (i_Tx_Ready), 
        .o_Tx_Done (),              // N/A in TX-RX mode
        .o_Tx_Active (),            // N/A in TX-RX mode
        .o_Tx_Data (w_Tx_Data_to_Rx)
    );
 
    //Instantiation of RX Controller   
    uart_rx_controller #(RX_OVERSAMPLE) xUART_RX(
        .clk (w_Rx_ClkTick), 
        .reset_n (reset_n), 
        .i_Rx_Data (w_Tx_Data_to_Rx), 
        .o_Rx_Done (o_Rx_Done), 
        .o_Rx_Byte (o_Rx_Byte)
    );
 
`endif
  
endmodule
