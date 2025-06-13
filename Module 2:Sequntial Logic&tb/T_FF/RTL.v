module Combi #(parameter N=4)(
 input clk,         // Clock signal
   input T, 
   input reset,       // Active-HIGH inputs
   output  Q       // Output (registered)
);
reg current; wire next;
always@(posedge clk) begin 
if(!reset) begin 
current<=1'b0;
end else begin
current<=next; end
end
//Next state logic
assign next=T?~current:current;
assign Q=current;
endmodule
