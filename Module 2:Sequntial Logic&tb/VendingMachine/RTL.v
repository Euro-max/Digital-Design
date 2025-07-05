`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/04/2025 05:01:04 PM
// Design Name: 
// Module Name: VendingMachine
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module VendingMachine(
input  wire clk,
    input  wire rst,
    input  wire coin_in,
    input  wire cancel,
    input  wire dispense,
    output reg  Item_out
);

    // Gray-encoded state definitions
    localparam [1:0]
        IDLE     = 2'b00,
        READY    = 2'b01,
        DISPENSE = 2'b11;

    reg [1:0] state, next_state;
    reg [2:0] coin_count; 

    // Sequential block: State and coin counter update
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            coin_count  <= 3'd0;
            Item_out    <= 1'b0;
        end else begin
            state <= next_state;

            
            if (state == READY && dispense) begin
                Item_out <= 1'b1;
            end else begin
                Item_out <= 1'b0;
            end

            // Coin counter logic
            case (state)
                IDLE: begin
                    if (coin_in && coin_count < 5)
                        coin_count <= coin_count + 1;
                    else if (cancel)
                        coin_count <= 0;
                end

                READY: begin
                    if (cancel || dispense)
                        coin_count <= 0;
                end

                DISPENSE: begin
                    coin_count <= 0;
                end
            endcase
        end
    end

    // Combinational block: Next state logic
    always @(*) begin
        case (state)
            IDLE: begin
                if (coin_count == 5)
                    next_state = READY;
                else
                    next_state = IDLE;
            end

            READY: begin
                if (dispense)
                    next_state = DISPENSE;
                else if (cancel)
                    next_state = IDLE;
                else
                    next_state = READY;
            end

            DISPENSE: begin
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule

