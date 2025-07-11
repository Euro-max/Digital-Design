module ROM(
    input [31:0] addr,
    output  [31:0] instr
);
    reg [31:0] memory [0:63];
    initial begin
        $readmemh("program.txt", memory);
    end
    
        assign instr = memory[addr[31:2]];
   
endmodule
