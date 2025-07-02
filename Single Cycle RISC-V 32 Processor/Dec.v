`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2025 08:00:21 AM
// Design Name: 
// Module Name: Dec
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


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2025 07:52:32 AM
// Design Name: 
// Module Name: ALUDecoder
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


module Dec (
    input  [1:0] ALUOp,
    input  [2:0] funct3,
    input        funct7_5,
    output reg [2:0] ALUControl
);

always @(*) begin
    case (ALUOp)
        2'b00: ALUControl = 3'b000; // load/store ? ADD
        2'b01: begin                // branch
            case (funct3)
                3'b000: ALUControl = 3'b010; // BEQ ? SUB
                3'b001: ALUControl = 3'b010; // BNE ? SUB
                3'b100: ALUControl = 3'b010; // BLT ? SUB
                default: ALUControl = 3'b000;
            endcase
        end
        2'b10: begin                // R-type or I-type ALU
            case (funct3)
                3'b000: ALUControl = funct7_5 ? 3'b010 : 3'b000; // SUB or ADD
                3'b001: ALUControl = 3'b001; // SHL
                3'b100: ALUControl = 3'b100; // XOR
                3'b101: ALUControl = 3'b101; // SHR
                3'b110: ALUControl = 3'b110; // OR
                3'b111: ALUControl = 3'b111; // AND
                default: ALUControl = 3'b000;
            endcase
        end
        default: ALUControl = 3'b000;
    endcase
    end
endmodule