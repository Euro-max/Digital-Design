module Control_Unit
( input  [6:0] opcode,
    output reg       RegWrite,
    output reg [1:0] ImmSrc,
    output reg       ALUSrc,
    output reg       MemWrite,
    output reg [1:0] ResultSrc,
    output reg       Branch,
    output reg [1:0] ALUOp
);

always @(*) begin
    case (opcode)
        7'b0000011: begin // load
            RegWrite   = 1;
            ImmSrc     = 2'b00;
            ALUSrc     = 1;
            MemWrite   = 0;
            ResultSrc  = 2'b01;
            Branch     = 0;
            ALUOp      = 2'b00;
        end
        7'b0100011: begin // store
            RegWrite   = 0;
            ImmSrc     = 2'b01;
            ALUSrc     = 1;
            MemWrite   = 1;
            ResultSrc  = 2'bxx;
            Branch     = 0;
            ALUOp      = 2'b00;
        end
        7'b0110011: begin // R-type
            RegWrite   = 1;
            ImmSrc     = 2'bxx;
            ALUSrc     = 0;
            MemWrite   = 0;
            ResultSrc  = 2'b00;
            Branch     = 0;
            ALUOp      = 2'b10;
        end
        7'b0010011: begin // I-type (immediate ALU ops)
            RegWrite   = 1;
            ImmSrc     = 2'b00;
            ALUSrc     = 1;
            MemWrite   = 0;
            ResultSrc  = 2'b00;
            Branch     = 0;
            ALUOp      = 2'b10;
        end
        7'b1100011: begin // branch
            RegWrite   = 0;
            ImmSrc     = 2'b10;
            ALUSrc     = 0;
            MemWrite   = 0;
            ResultSrc  = 2'bxx;
            Branch     = 1;
            ALUOp      = 2'b01;
        end
        default: begin
            RegWrite   = 0;
            ImmSrc     = 2'b00;
            ALUSrc     = 0;
            MemWrite   = 0;
            ResultSrc  = 2'b00;
            Branch     = 0;
            ALUOp      = 2'b00;
        end
    endcase
end

endmodule