timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/11/2025 04:46:34 AM
// Design Name: 
// Module Name: FSM
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

module FSM(
    input clk,
    input rst_n,
    input x,
    output y
);

    reg [2:0] current_state, next_state; // Need 3 bits for 6 states (0-5)

    // State definitions
    localparam S_IDLE    = 3'b000; // No match
    localparam S_0       = 3'b001; // Matched '0'
    localparam S_01      = 3'b010; // Matched '01'
    localparam S_010     = 3'b011; // Matched '010'
    localparam S_0101    = 3'b100; // Matched '0101'
    localparam S_01010   = 3'b101; // Matched '01010' - Output asserted here

    // State Register
    always @(posedge clk or negedge rst_n) begin // Active-low reset
        if (!rst_n) begin // Asynchronous reset
            current_state <= S_IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Next State Logic
    always @(*) begin
        next_state = current_state; // Default to staying in current state
        case (current_state)
            S_IDLE: begin
                if (x == 1'b0) next_state = S_0;
                else          next_state = S_IDLE; // Stays in IDLE if x is 1
            end
            S_0: begin // Matched "0"
                if (x == 1'b1) next_state = S_01;
                else          next_state = S_0;    // Overlap: "00" -> still matched "0"
            end
            S_01: begin // Matched "01"
                if (x == 1'b0) next_state = S_010;
                else          next_state = S_IDLE; // "011" -> no match, go to IDLE
            end
            S_010: begin // Matched "010"
                if (x == 1'b1) next_state = S_0101;
                else          next_state = S_0;     // "0100" -> matched "0", go to S_0
            end
            S_0101: begin // Matched "0101"
                if (x == 1'b0) next_state = S_01010; // Matched "01010" - sequence complete!
                else          next_state = S_01;    // "01011" -> matched "01", go to S_01
            end
            S_01010: begin // Matched "01010" (output asserted here)
                if (x == 1'b0) next_state = S_0;     // "010100" -> matched "0", go to S_0
                else          next_state = S_01;    // "010101" -> matched "01", go to S_01
            end
            default: next_state = S_IDLE; // Should not happen
        endcase
    end
// Output Logic (Moore Machine: output depends only on current state)
    assign y = (current_state == S_01010) ? 1'b1 : 1'b0;

endmodule
