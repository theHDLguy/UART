module uart_tx_controller(
  
    input clk,
    input reset_n,
    input [7:0] i_Tx_Byte,
    input i_Tx_Ready,
    output o_Tx_Done,
    output o_Tx_Active,         // Asserted for 1 clk cycle after receiving one byte of data 
    output o_Tx_Data
    );
    
    // FSM states
    localparam 
        UART_TX_IDLE = 3'b000,
        UART_TX_START = 3'b001,
        UART_TX_DATA =  3'b010,
        UART_TX_STOP = 3'b011;
  
    // internal variables
    reg [2:0] r_Bit_Index;      // keeps track of transferred bits
    reg r_Tx_Done;              // "transmission done" signal
    reg r_Tx_Data;              // serial data bit
    reg [2:0] r_State;          // state transition variable
    reg r_Tx_Active;            // "ready to transmit" signal


    // output wires  -->  output is declared wire and hence can't be used inside always block. So they are driven by reg variables
    assign o_Tx_Done = r_Tx_Done;
    assign o_Tx_Data = r_Tx_Data;
    assign o_Tx_Active = r_Tx_Active;
   

    //UART TX Logic Implementation 
    always @(posedge clk or negedge reset_n) begin
        if(~reset_n) begin
            r_State <= UART_TX_IDLE;          
            r_Bit_Index <= 0;
            r_Tx_Done <= 1'b0;
            r_Tx_Data <= 1'b1;  
            r_Tx_Active <= 1'b0;
        end

        else begin
            case(r_State)
                UART_TX_IDLE: begin       
                    r_Bit_Index <= 0;
                    r_Tx_Done <= 1'b0;
                    r_Tx_Data <= 1'b1;

                    if(i_Tx_Ready == 1'b1) begin
                        r_State <= UART_TX_START;
                        r_Tx_Active <= 1'b1;
                    end
                    else begin
                        r_State <= UART_TX_IDLE;
                    end
                end

                UART_TX_START: begin
                    r_Tx_Data <= 1'b0;          // pulling the data line to low to indicate "START BIT"
                    r_State <= UART_TX_DATA;    
                end          

                UART_TX_DATA: begin
                    r_Tx_Data <= i_Tx_Byte[r_Bit_Index]; 

                    if(r_Bit_Index < 7 ) begin
                        r_Bit_Index <= r_Bit_Index + 1;
                        r_State <= UART_TX_DATA;
                    end
                    else begin
                        r_Bit_Index <= 0;
                        r_State <= UART_TX_STOP;
                    end
                end        

                UART_TX_STOP: begin          
                    r_State <= UART_TX_IDLE;            
                    r_Tx_Done <= 1'b1;
                    r_Tx_Active <= 1'b0;
                    r_Tx_Data <= 1'b1;
                end

                default: r_State <= UART_TX_IDLE;
            endcase
        end
    end

endmodule