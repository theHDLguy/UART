/* RUN for 756700 ns 

This testbench uses only one aspect of SystenVerilog in line 43, ie. assigning a packed type to an unpacked type. 
This can be done in verilog as well by consuming 16 extra lines. Refer to this for more - electronics.stackexchange.com/q/674926/332744 */

`timescale 1ns/10ps
`include "defines.v"
`include "UART_top.v"

// CLKS_PER_BITS = (Input Frequency {i_clk}/ UART Frequency {Baud Rate} 
// Example : CLKS_PER_BITS = (25 MHz / 115200) = 217 

module UART_TB ();

    // testbench parameters 
    parameter c_CLOCK_PERIOD_NS = 40;   // testbench uses a 25 MHz clock --> time period = 40 ns
    parameter c_CLKS_PER_BIT = 217;     // want to interface to 115200 baud UART --> 25000000 / 115200 = 217 clocks per bit
    parameter c_BIT_PERIOD = 8680;      // (40 ns) x (217 clks/bit)
    

    // declare & initialize common input variables  
    reg Clock = 0;
    reg reset_n = 0;


`ifdef UART_TX_ONLY
    wire Tx_Done;
    reg Tx_Ready = 0;
    wire Tx_Active;   
    wire Tx_Data;
    reg [7:0] Tx_Byte = 0;
  
`elsif UART_RX_ONLY
    wire [7:0] Rx_Byte;
    reg UART_Rx = 0;
    wire Rx_Done;

`else
    wire Rx_Done;
    wire [7:0] Rx_Byte;
    reg [7:0] Tx_Byte = 0;
    reg Tx_Ready = 0;
    reg [7:0] DataToSend [0:7] = {8'h01, 8'h10, 8'h22, 8'h32, 8'h55, 8'hAA, 8'hAB, 8'h88};
    reg [7:0] DataReceived [0:7];
    integer ii;
  
`endif
  

`ifdef UART_TX_ONLY  
    uart_controller #(.CLOCK_RATE(25000000), .BAUD_RATE(115200)) xUART_TX(
        .clk (Clock),
        .reset_n (reset_n),
        .i_Tx_Ready (Tx_Ready),
        .i_Tx_Byte (Tx_Byte),
        .o_Tx_Active (Tx_Active),
        .o_Tx_Data (Tx_Data),
        .o_Tx_Done (Tx_Done)
    );
 
`elsif UART_RX_ONLY
    uart_controller #(.CLOCK_RATE(25000000), .BAUD_RATE(115200), .RX_OVERSAMPLE(16)) xUART_RX(
        .clk (Clock),
        .reset_n (reset_n),
        .i_Rx_Data (UART_Rx),
        .o_Rx_Done (Rx_Done),
        .o_Rx_Byte (Rx_Byte)
    );
  
`else
    uart_controller #(.CLOCK_RATE(25000000), .BAUD_RATE(115200), .RX_OVERSAMPLE(16)) xUART(
        .clk (Clock),
        .reset_n (reset_n),
        .i_Tx_Byte (Tx_Byte),
        .i_Tx_Ready (Tx_Ready),
        .o_Rx_Done (Rx_Done),
        .o_Rx_Byte (Rx_Byte)
    );
  
`endif

    // clock generation
    always #(c_CLOCK_PERIOD_NS/2) Clock <= ~Clock;
  
`ifdef UART_TX_ONLY  // UART TX Controller TB 
      
    reg[7:0] dataToSend_TX = 8'b01010101;
    
    initial begin
        #5 reset_n = 1;     
        @(posedge Clock);
        @(posedge Clock);

        Tx_Ready   = 1'b1;
        @(posedge Clock); Tx_Byte = DataToSend_TX;   

        #100000 $finish();
    end
  
`elsif UART_RX_ONLY // UART RX Controller TB 

    reg[7:0] DataToSend_RX = 8'b01010101;
    integer i;

    initial begin
        #5 reset_n = 1;
        @(posedge Clock); UART_Rx = 0;
    
        for(i=0; i < 8 ; i = i+1) begin  
            #(217*40);
            @(posedge Clock); 
            UART_Rx = DataToSend_RX[i];          
        end
    
        #85000 $finish();
    end
  
`else // UART TX + RX Controller Test
  
    initial begin

        #5 reset_n = 1;     
        @(posedge Clock);
        
        @(posedge Clock)
            Tx_Ready <= 1'b1;      

        for (ii = 0; ii < 8; ii = ii + 1) begin
            Tx_Byte = DataToSend[ii];

            @(posedge Rx_Done) 
                DataReceived[ii] = Rx_Byte; 
            
            if (DataToSend[ii] == DataReceived[ii])
                $display("Test Passed - Correct Byte Received. TX Data Byte = %h, RX Data Byte = %h", DataToSend[ii] , DataReceived[ii]);
            else
                $display("Test Failed - Incorrect Byte Received. TX Data Byte = %h, RX Data Byte = %h", DataToSend[ii] , DataReceived[ii]);
        end

        #800000 $finish();
    end

`endif
  
    initial begin
        // Required to dump signals to EPWave
        $dumpfile("uart.vcd");
        $dumpvars(0);
    end
endmodule
