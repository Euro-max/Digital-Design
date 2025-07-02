module RegFile(
    input wire clk,
    input RegWrite,
    input wire reset,
    input wire we3,                 // Write enable
    input wire [4:0] a1, a2, a3,    // Register addresses
    input wire [31:0] wd3,          // Write data
    output wire [31:0] rd1, rd2     // Read data
);
    reg [31:0] regs[0:31];

    // Read (asynchronous)
   
    
   reg [31:0] Regs [0:31];            
    
    
    assign rd1 = Regs[a1];
    assign rd2 = Regs[a2];
    
    integer i;
    always @(posedge clk or negedge reset) begin
        if (!reset)
            for ( i = 0; i < 32; i = i + 1)
                Regs[i] <= 32'b0;
        else if (RegWrite && a3 != 5'b00000)
            Regs[a3] <= wd3;
    end
    
    endmodule