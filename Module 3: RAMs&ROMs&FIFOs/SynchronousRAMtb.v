module RAM3tb;

    
    parameter DATA_W = 16;
    parameter ADDR_W = 4;
    parameter CLK_PERIOD = 10; 

   
    reg clk;
    reg rst;
    reg we_a, we_b;
    reg [ADDR_W-1:0] aadr, badr;
    reg [DATA_W-1:0] din_a, din_b;
    wire [DATA_W-1:0] dout_a_dut, dout_b_dut;
    wire collision_dut;
    wire [DATA_W-1:0] dout_a_gold, dout_b_gold;
    wire collision_gold;

   
    integer correct_compares = 0;
    integer false_compares = 0;
    integer test_step = 0;

   
    RAM3 #(
        .DATA_W(DATA_W),
        .ADDR_W(ADDR_W)
    ) DUT (
        .clk(clk),
        .rst(rst),
        .we_a(we_a),
        .we_b(we_b),
        .aadr(aadr),
        .badr(badr),
        .din_a(din_a),
        .din_b(din_b),
        .dout_a(dout_a_dut),
        .collision(collision_dut),
        .dout_b(dout_b_dut)
    );

    RAM3 #(
        .DATA_W(DATA_W),
        .ADDR_W(ADDR_W)
    ) Gold (
        .clk(clk),
        .rst(rst),
        .we_a(we_a),
        .we_b(we_b),
        .aadr(aadr),
        .badr(badr),
        .din_a(din_a),
        .din_b(din_b),
        .dout_a(dout_a_gold),
        .collision(collision_gold),
        .dout_b(dout_b_gold)
    );

    // Clock Generation
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Verification Task: Compare DUT outputs with Golden Model outputs
    always @(posedge clk) begin
        if (!rst) begin // Only compare when not in reset
            if (dout_a_dut === dout_a_gold &&
                dout_b_dut === dout_b_gold &&
                collision_dut === collision_gold) begin
                correct_compares = correct_compares + 1;
                $display("Time %0t: Test Step %0d - PASS (DUT vs Gold Match)", $time, test_step);
            end else begin
                false_compares = false_compares + 1;
                $display("Time %0t: Test Step %0d - FAIL (DUT vs Gold Mismatch)", $time, test_step);
                $display("  DUT: dout_a=%h, dout_b=%h, collision=%b", dout_a_dut, dout_b_dut, collision_dut);
                $display("  Gold: dout_a=%h, dout_b=%h, collision=%b", dout_a_gold, dout_b_gold, collision_gold);
                // Optional: $stop; to halt simulation on first mismatch
            end
        end
    end

    // Main Test Sequence
    initial begin
        $srandom($time); // Seed random number generator

        
        $display("\n--- Test Scenario 1: Initial Reset (RAMs self-initialized at simulation start) ---");
        rst = 1'b1; 
        we_a = 1'b0; we_b = 1'b0;
        aadr = {ADDR_W{1'b0}}; badr = {ADDR_W{1'b0}};
        din_a = {DATA_W{1'b0}}; din_b = {DATA_W{1'b0}};
        #(CLK_PERIOD * 2); 
        rst = 1'b0; 
        #(CLK_PERIOD/2); 

        
        $display("\n--- Test Scenario 2: RAMs are already initialized from init_ram.mem during simulation start ---");
        $display("Confirming initial content by reading from address 0");
        aadr = {4'h0}; badr = {4'h0}; // Set addresses to 0
        we_a = 1'b0; we_b = 1'b0;
        #(CLK_PERIOD); // Wait for output to reflect init_ram.mem data for address 0
        $display("Time %0t: Read from Addr 0: dout_a=%h (should be 0001), dout_b=%h (should be 0001)", $time, dout_a_dut, dout_b_dut);


        
        $display("\n--- Test Scenario 3: Independent Writes and Reads ---");
        test_step = 1;

        
        we_a = 1'b1; we_b = 1'b0;
        aadr = {4'h5}; din_a = {16'hAAAA};
        badr = {4'h0}; 
        #(CLK_PERIOD); 
        $display("Time %0t: Write A: Addr=%h, Data=%h. Read B: Addr=%h.", $time, aadr, din_a, badr);

        test_step = 2; 
        #(CLK_PERIOD); 
        $display("Time %0t: dout_a (from aadr_reg) reflects data at Addr=%h from *before* write. dout_b (from badr_reg) reflects data at Addr=%h.", $time, aadr, badr);

        // Port B writes, Port A reads (different addresses)
        test_step = 3;
        we_a = 1'b0; we_b = 1'b1;
        aadr = {4'h5}; // Read from 5
        badr = {4'h9}; din_b = {16'hBBBB};
        #(CLK_PERIOD);
        $display("Time %0t: Write B: Addr=%h, Data=%h. Read A: Addr=%h.", $time, badr, din_b, aadr);

        test_step = 4;
        #(CLK_PERIOD);
        $display("Time %0t: dout_a (from aadr_reg) should be %h. dout_b (from badr_reg) should be old value from Addr=%h", $time, 16'hAAAA, badr);


        // --- Test Scenario 4: Simultaneous Writes to Different Addresses (No Collision) ---
        $display("\n--- Test Scenario 4: Simultaneous Writes to Different Addresses (No Collision) ---");
        test_step = 5;
        we_a = 1'b1; we_b = 1'b1; // Both ports write
        aadr = {4'h2}; din_a = {16'h1111};
        badr = {4'hC}; din_b = {16'h2222};
        #(CLK_PERIOD);
        $display("Time %0t: Write A: Addr=%h, Data=%h. Write B: Addr=%h, Data=%h. Collision expected: 0", $time, aadr, din_a, badr, din_b);
        $display("Collision flag (current cycle): %b (should be 0)", collision_dut);

        test_step = 6;
        #(CLK_PERIOD); // Wait for writes to complete and outputs to register (read values from previous cycle)
        // Now read back from these addresses to confirm writes
        we_a = 1'b0; we_b = 1'b0; // Disable writes for reading
        aadr = {4'h2}; badr = {4'hC}; // Set addresses for reading
        $display("Time %0t: Reading from Addr=%h (expect %h) and Addr=%h (expect %h).", $time, aadr, 16'h1111, badr, 16'h2222);

        test_step = 7;
        #(CLK_PERIOD);
        $display("Time %0t: Read A: dout_a=%h (should be 1111)", $time, dout_a_dut);
        $display("Time %0t: Read B: dout_b=%h (should be 2222)", $time, dout_b_dut);
        $display("Collision flag: %b (should be 0 now as no current collision)", collision_dut);


        // --- Test Scenario 5: Simultaneous Writes to Same Address (Collision) ---
        $display("\n--- Test Scenario 5: Simultaneous Writes to Same Address (Collision) ---");
        test_step = 8;
        we_a = 1'b1; we_b = 1'b1;
        aadr = {4'hF}; din_a = {16'hAAAA}; // Port A writes AAAA
        badr = {4'hF}; din_b = {16'hBBBB}; // Port B writes BBBB
        #(CLK_PERIOD);
        $display("Time %0t: Write A: Addr=%h, Data=%h. Write B: Addr=%h, Data=%h. Collision expected: 1", $time, aadr, din_a, badr, din_b);
        $display("Collision flag (current cycle): %b (should be 1)", collision_dut); // Check collision immediately

        test_step = 9;
        #(CLK_PERIOD); // Wait for writes to complete and outputs to register
        // Now read back from this address to confirm priority (Port A's data should be there)
        we_a = 1'b0; we_b = 1'b0;
        aadr = {4'hF}; badr = {4'hF};
        $display("Time %0t: Reading from Addr=%h (expect %h due to Port A priority).", $time, aadr, 16'hAAAA);

        test_step = 10;
        #(CLK_PERIOD);
        $display("Time %0t: Read A: dout_a=%h (should be AAAA)", $time, dout_a_dut);
        $display("Time %0t: Read B: dout_b=%h (should be AAAA)", $time, dout_b_dut);
        $display("Collision flag: %b (should be 0 now as no current collision)", collision_dut);


        // 
        $display("\n--- Test Scenario 6: Random Reads/Writes (10 cycles) ---");
        repeat (10) begin
            test_step = test_step + 1;
            we_a = $random % 2;
            we_b = $random % 2;
            aadr = $random % (1<<ADDR_W);
            badr = $random % (1<<ADDR_W);
            din_a = $random;
            din_b = $random;
            #(CLK_PERIOD);
            
        end


        $display("\n--- Simulation Summary ---");
        $display("Total Correct Comparisons: %0d", correct_compares);
        $display("Total False Comparisons:   %0d", false_compares);
        $display("--- End of Simulation ---");
        $finish; // End simulation
    end

endmodule
