module FIFO_f#(
  parameter DATA_WIDTH = 8,
  parameter DEPTH = 16,
  parameter ADDR_WIDTH = 4  // log2(DEPTH)
)(
  input wire clk,
  input wire rst,
  input wire wr_en,
  input wire rd_en,
  input wire [DATA_WIDTH-1:0] din,
  output reg [DATA_WIDTH-1:0] dout,
  output wire full,
  output wire empty,
  output wire almost_full,almost_empty
);

  // Internal storage
  reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  // Read and write pointers
  reg [ADDR_WIDTH:0] wptr = 0; // Extra bit to distinguish wraparound
  reg [ADDR_WIDTH:0] rptr = 0;

  wire [ADDR_WIDTH-1:0] waddr = wptr[ADDR_WIDTH-1:0];
  wire [ADDR_WIDTH-1:0] raddr = rptr[ADDR_WIDTH-1:0];

  wire [ADDR_WIDTH:0] diff = wptr - rptr;

  assign full = (diff == DEPTH);
  assign empty = (diff == 0);
  assign almost_full = (diff >= DEPTH - 2);
  assign almost_empty=(diff<=2);
  // WRITE
  always @(posedge clk) begin
    if (!rst) begin
      wptr <= 0;
    end else if (wr_en && !full) begin
      mem[waddr] <= din;
      wptr <= wptr + 1;
    end
  end

  // READ
  always @(posedge clk) begin
    if (!rst) begin
      rptr <= 0;
      dout <= 0;
    end else if (rd_en && !empty) begin
      dout <= mem[raddr];
      rptr <= rptr + 1;
    end
  end

endmodule
