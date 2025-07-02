module ProgramCounter (
    input clk,               // Clock signal
    input areset,            // Asynchronous reset (active low)
    input load,              // Load control signal
    input [31:0] PCNext,     // Next address input
    output reg [31:0] PC     // Current program counter output
);

always @(posedge clk or negedge areset) begin
    if (areset==0) begin
       
        PC <= 32'b0;
    end
    else begin
        if (load) begin
            
            PC <= PCNext;
        end
       if(!load) begin
       PC<=PC;
       end 
    end
    
end

endmodule
