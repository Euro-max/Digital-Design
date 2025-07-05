module VMtb;


  // Parameters
  parameter CLK_PERIOD = 20;         // 50 MHz clock (20ns period)
  parameter HALF_PERIOD = CLK_PERIOD / 2;
  parameter COINS_NEEDED = 5;

  // DUT signals
  reg clk, rst;
  reg coin_in, cancel, dispense;
  wire Item_out;

  // Instantiate the DUT
  VendingMachine dut (
    .clk(clk),
    .rst(rst),
    .coin_in(coin_in),
    .cancel(cancel),
    .dispense(dispense),
    .Item_out(Item_out)
  );

  // Clock generation
  initial begin
    clk = 1'b1;
    forever #(HALF_PERIOD) clk = ~clk;
  end

  // Stimulus block
  initial begin
    // Init
    rst = 0;
    coin_in = 0;
    cancel = 0;
    dispense = 0;

    $monitor("Time=%0t | rst=%b | coin_in=%b | cancel=%b | dispense=%b | Item_out=%b",
              $time, rst, coin_in, cancel, dispense, Item_out);

    // Apply reset
    $display("\n--- APPLY RESET ---");
    repeat (2) @(posedge clk);
    rst = 1;
    @(posedge clk);
    rst = 0;

    // Phase 1: Insert 3 coins then cancel
    $display("\n--- INSERTING 3 COINS THEN CANCEL ---");
    repeat (3) begin
      @(posedge clk);
      coin_in = 1;
      @(posedge clk);
      coin_in = 0;
    end

    @(posedge clk);
    cancel = 1;
    @(posedge clk);
    cancel = 0;

    // Phase 2: Insert 5 coins to reach READY
    $display("\n--- INSERTING 5 COINS TO REACH READY ---");
    repeat (COINS_NEEDED) begin
      @(posedge clk);
      coin_in = 1;
      @(posedge clk);
      coin_in = 0;
    end

    // Phase 3: Dispense item
    $display("\n--- DISPENSING ITEM ---");
    @(posedge clk);
    dispense = 1;
    @(posedge clk);
    dispense = 0;

    // Wait a few cycles
    repeat (3) @(posedge clk);

    // Phase 4: Insert 5 coins, then cancel before dispensing
    $display("\n--- INSERTING 5 COINS THEN CANCEL ---");
    repeat (COINS_NEEDED) begin
      @(posedge clk);
      coin_in = 1;
      @(posedge clk);
      coin_in = 0;
    end

    @(posedge clk);
    cancel = 1;
    @(posedge clk);
    cancel = 0;

    $display("\n--- TEST COMPLETED at time %0t ---", $time);
    $finish;
  end

endmodule
