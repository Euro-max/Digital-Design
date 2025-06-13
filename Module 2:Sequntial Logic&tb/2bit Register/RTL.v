module Combi(
input clk,
input D,
output reg P1,P2
    );
    always@(posedge clk) begin
    P1<=D;
    P2<=P1;
    end
endmodule
