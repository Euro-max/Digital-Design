module RAM3 #(
    parameter DATA_W = 16,  
    parameter ADDR_W = 4   
) (
    input clk,
    input rst,     
    input we_a,     
    input we_b,     
    input [ADDR_W-1:0] aadr,   
    input [ADDR_W-1:0] badr,    
    input [DATA_W-1:0] din_a,   
    input [DATA_W-1:0] din_b,  
    output reg [DATA_W-1:0] dout_a,  
    output reg [DATA_W-1:0] dout_b, 
    output reg collision    
);

   reg[DATA_W-1:0]ram[0:2**ADDR_W-1];
   always@(posedge clk)begin
   if(rst)begin
   ram[aadr]<=16'b0;
   ram[aadr]<=16'b0;
   collision<=1'b0;
   end else begin
   if(we_a&&we_b&&(aadr==badr))begin
   collision<=1'b1;
   ram[aadr]<=din_a;
   end
   else if(we_a)begin collision<=1'b0; ram[aadr]<=din_a;end
   else if(we_b)begin collision<=1'b0; ram[badr]<=din_b;end
   end
   end
   always@(posedge clk) begin
   dout_a<=ram[aadr];
   dout_b<=ram[badr];
   end

