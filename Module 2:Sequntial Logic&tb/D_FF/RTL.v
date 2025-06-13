module D_FF (
 input wire clk,      // Clock input
   input wire rst_n,    // Asynchronous active-low reset
   input wire d_in,     // Data input
   output reg q_out     // Data output
);

   always @(posedge clk or negedge rst_n) begin
       if (!rst_n) begin // Asynchronous reset (active-low)
           q_out <= 1'b0;
       end else begin    // Synchronous data update on positive clock edge
           q_out <= d_in;
       end
   end

endmodule
