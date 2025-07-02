module DataMemory(
    input wire clk,
    input wire reset,
    input wire WE,                   // Write Enable
    input wire [31:0] addr,          
    input wire [31:0] din,           // Data input (write)
    output wire [31:0] dout           // Data output (read)
);

    // 64 words of 32-bit memory
    reg [31:0] memory [0:63];

    
    
    // Write operation (synchronous)
   integer i;
    
    always @(posedge clk)
    begin
       
         if (WE == 1) begin
            memory[addr[31:2]] <= din;
        end
    end
    
    assign dout = (reset == 0) ? {32{1'b0}} : memory[addr[31:2]];
    
    endmodule
