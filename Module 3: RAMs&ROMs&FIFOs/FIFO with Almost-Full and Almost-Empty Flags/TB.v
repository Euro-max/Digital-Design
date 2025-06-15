module fifo_tb;

  // Parameters
  parameter clock = 10;
  parameter half = clock / 2;
  parameter cycles = 30;
  parameter DEPTH = 16;  // Match FIFO depth
parameter FILL_CYCLES = DEPTH + 2;  // Extra to test full
 parameter EMPTY_CYCLES = DEPTH + 2;
  // DUT signals
  reg clk, rst;
  reg wr_en, rd_en;
  reg [7:0] din;
  wire [7:0] dout;
  wire full, empty, almost_full, almost_empty;

  // Instantiate FIFO
  FIFO_f dut (
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .din(din),
    .dout(dout),
    .full(full),
    .empty(empty),
    .almost_full(almost_full),.almost_empty(almost_empty)
  );

  // Clock generator
  initial begin
    clk = 1'b1;
    forever #(half) clk = ~clk;
  end

  // Stimulus
  initial begin
       $srandom($time);
       rst = 1'b0;  // assert reset
       wr_en = 0;
       rd_en = 0;
       din = 0;
   
       $monitor("Time=%0t ns | clk=%b | rst=%b | wr=%b | rd=%b | din=%h | dout=%h | full=%b | empty=%b | almost_full=%b | almost_empty=%b",
                $time, clk, rst, wr_en, rd_en, din, dout, full, empty, almost_full, almost_empty);
   
       // Hold reset for 2 clocks
       repeat (2) @(posedge clk);
       rst = 1'b1;
   
       // Operation phase 1
       $display("\n--- FILLING FIFO ---");
          repeat (FILL_CYCLES) begin
            @(posedge clk);
            wr_en = !full;
            rd_en = 0;
            if (wr_en)
              din = $random;
          end
      
          // ----------- Phase 2: EMPTY FIFO -----------
          $display("\n--- EMPTYING FIFO ---");
          wr_en = 0;
          repeat (EMPTY_CYCLES) begin
            @(posedge clk);
            rd_en = !empty;
          end
      
          $display("\nSimulation completed at time %0t ns", $time);
          $finish;
        end
  endmodule
