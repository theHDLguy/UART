//  Baud Rage Generator : Divide Clock Frequency to UART RX/TX Baud Rates with 16x RX Oversampling

module baudRateGenerator #(
    parameter 
        CLOCK_RATE = 25000000,  // UART peripheral/system clock frequency --> 25 MHz (T = 4x10^-8 ns)
        BAUD_RATE = 115200,     // 115.2 kbps  --> required frequency of TX
        RX_OVERSAMPLE = 16)(    // RX oversampling by 16

    // Global Signals
    input clk,
    input reset_n,

    // RX and TX Baud Rates
    output reg o_Rx_ClkTick,
    output reg o_Tx_ClkTick
    );

    localparam 
        // UART_DIV value
        TX_CNT = CLOCK_RATE / (2*BAUD_RATE),                // = 108.5 = 108
        RX_CNT = CLOCK_RATE / (2*BAUD_RATE*RX_OVERSAMPLE),  // = 6.78 = 6

        // UART_DIV contanier width
        TX_CNT_WIDTH = $clog2(TX_CNT),                      // ceiling of log_2[TX_CNT] = ceil(6.76) = 7
        RX_CNT_WIDTH = $clog2(RX_CNT);                      // ceiling of log_2[RX_CNT] = ceil(2.76) = 3


    // counters to count till UART_DIV
    reg[TX_CNT_WIDTH - 1 : 0] r_Tx_Counter;                 // [6:0] r_Tx_Counter
    reg[RX_CNT_WIDTH - 1 : 0] r_Rx_Counter;                 // [2:0] r_Rx_Counter
    

    // RX Baud Rate 
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            o_Rx_ClkTick <= 1'b0;
            r_Rx_Counter <= 0;
        end

        else if(r_Rx_Counter == RX_CNT - 1) begin
            o_Rx_ClkTick <= ~o_Rx_ClkTick;
            r_Rx_Counter <= 0;
        end
        
        else begin
            r_Rx_Counter <= r_Rx_Counter + 1;
        end
    end
    

    // TX Baud Rate
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            o_Tx_ClkTick <= 1'b0;
            r_Tx_Counter <= 0;
        end

        else if(r_Tx_Counter == TX_CNT - 1) begin
            o_Tx_ClkTick <= ~o_Tx_ClkTick;
            r_Tx_Counter <= 0;
        end

        else begin
            r_Tx_Counter <= r_Tx_Counter + 1;
        end
    end

endmodule