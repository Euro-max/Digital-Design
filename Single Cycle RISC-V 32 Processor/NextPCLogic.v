module NextPCLogic (
    input [31:0] PC,         // Current program counter
    input [31:0] ImmExt,     // Sign-extended immediate (branch target offset)
    input PCSrc,             // Control signal for branch selection
    output [31:0] PCNext     // Next program counter value
);

// Internal signals
wire [31:0] PC_plus_4;
wire [31:0] PC_plus_offset;

// Calculate both possible next addresses
assign PC_plus_4 = PC + 32'd4;
assign PC_plus_offset = PC + ImmExt;

// Select appropriate next PC based on PCSrc
assign PCNext = (PCSrc) ? PC_plus_offset : PC_plus_4;

endmodule
