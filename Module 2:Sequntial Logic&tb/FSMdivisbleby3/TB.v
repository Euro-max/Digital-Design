module FSM3tb;
reg clk;
reg rst;
reg x;
wire y,y_golden;
parameter clock=10;
parameter cycles=100;
FSM3 DUT(.clk(clk),.rst(rst),.x(x),.y(y));
FSM3 Gold(clk,rst,x,y_golden);
integer correct=0;
integer false=0;
integer current_cycle = 0;
// --- Clock Generation ---
   initial begin
clk=1'b1;
forever #(clock/2)clk=~clk;
end
    initial begin
   $srandom($time); // Seed the random number generator
            
            // Display Header
            $display("--------------------------------------------------------------------------------------------------------------------");
            $display("Time  | clk | rst | x | DUT_y | Gold_y | Status | Correct | False | Comment");
            $display("--------------------------------------------------------------------------------------------------------------------");
    
            // Initial Reset Phase
            rst = 1'b1; // Assert active-HIGH reset
            x = 1'b0;   
    
            current_cycle = 0;
            #(2 * clock); // Hold reset for 2 full clock periods to ensure proper reset
    
            // Verification after reset assertion (should ideally be in reset state)
            if (y === y_golden) begin
                correct = correct + 1;
                $display("%0tns | %b   | %b   | %b | %b     | %b      | PASS   | %0d      | %0d     | After Reset (ASSERTED)",
                         $time, clk, rst, x, y, y_golden, correct, false);
            end else begin
                false = false + 1;
                $display("%0tns | %b   | %b   | %b | %b     | %b      | FAIL   | %0d      | %0d     | After Reset (ASSERTED)",
                         $time, clk, rst, x, y, y_golden, correct, false);
                $error("Verification Mismatch during initial reset at time %0tns", $time);
            end
    
    
            rst = 1'b0; // Deassert active-HIGHreset (release)
    
            // Give a few cycles for stability after reset release, if needed (optional)
            #(clock); 
            current_cycle = current_cycle + 1;
            // Verification after reset release
            if (y === y_golden) begin
                correct = correct + 1;
                $display("%0tns | %b   | %b   | %b | %b     | %b      | PASS   | %0d      | %0d     | After Reset (RELEASED) Cycle %0d",
                         $time, clk, rst, x, y, y_golden, correct, false, current_cycle);
            end else begin
                false = false + 1;
                $display("%0tns | %b   | %b   | %b | %b     | %b      | FAIL   | %0d      | %0d     | After Reset (RELEASED) Cycle %0d",
                         $time, clk, rst, x, y, y_golden, correct, false, current_cycle);
                $error("Verification Mismatch after reset release at time %0tns", $time);
            end
    
    
            // Apply random data input for a number of cycles with continuous verification
            $display("\n--- Applying Random Data Stream (Total %0d cycles) ---", cycles);
            repeat (cycles) begin
                #(clock); // Wait for one full clock period (new state is stable on posedge clk)
                x = $random % 2; // Generate random 0 or 1 for input 'x'
                current_cycle = current_cycle + 1;
    
                
                if (y === y_golden) begin
                    correct = correct + 1;
                    $display("%0tns | %b   | %b   | %b | %b     | %b      | PASS   | %0d      | %0d     | Random Data Cycle %0d",
                             $time, clk, rst, x, y, y_golden, correct, false, current_cycle);
                end else begin
                    false = false + 1;
                    $display("%0tns | %b   | %b   | %b | %b     | %b      | FAIL   | %0d      | %0d     | Random Data Cycle %0d",
                             $time, clk, rst, x, y, y_golden, correct, false, current_cycle);
                    $error("Verification Mismatch at time %0tns, Cycle %0d. x=%b, DUT_y=%b, Gold_y=%b",
                           $time, current_cycle, x, y, y_golden);
                end
            end
            
            // Assert asynchronous reset during operation (example of mid-operation reset)
            $display("\n--- Asserting Async Reset During Operation ---");
            #(clock / 2); // Apply reset mid-cycle (asynchronous nature)
            rst = 1'b1;   // Assert active-HIGH reset
            
            // Verification after mid-operation reset assertion
            if (y === y_golden) begin
                correct = correct + 1;
                $display("%0tns | %b   | %b   | %b | %b     | %b      | PASS   | %0d      | %0d     | Mid-Op Reset (ASSERTED)",
                         $time, clk, rst, x, y, y_golden, correct, false);
            end else begin
                false = false + 1;
                $display("%0tns | %b   | %b   | %b | %b     | %b      | FAIL   | %0d      | %0d     | Mid-Op Reset (ASSERTED)",
                         $time, clk, rst, x, y, y_golden, correct, false);
                $error("Verification Mismatch during mid-operation reset assertion at time %0tns", $time);
            end
    
            #(2 * clock); // Hold reset for 2 full clock periods
    
            rst = 1'b0;   // Deassert active-HIGH reset
    
            // Verification after mid-operation reset release
            #(clock); // Wait for at least one clock cycle after reset release
            current_cycle = current_cycle + 1;
            if (y === y_golden) begin
                correct = correct + 1;
                $display("%0tns | %b   | %b   | %b | %b     | %b      | PASS   | %0d      | %0d     | Mid-Op Reset (RELEASED) Cycle %0d",
                         $time, clk, rst, x, y, y_golden, correct, false, current_cycle);
            end else begin
                false = false + 1;
                $display("%0tns | %b   | %b   | %b | %b     | %b      | FAIL   | %0d      | %0d     | Mid-Op Reset (RELEASED) Cycle %0d",
                         $time, clk, rst, x, y, y_golden, correct, false, current_cycle);
                $error("Verification Mismatch after mid-operation reset release at time %0tns", $time);
            end
            
            // Observe for a few more cycles after the second reset
            $display("\n--- Final Observation Cycles ---");
            repeat (5) begin // Observe for 5 cycles
                #(clock);
                x = $random % 2; // Still generating random input
                current_cycle = current_cycle + 1;
                if (y === y_golden) begin
                    correct = correct + 1;
                    $display("%0tns | %b   | %b   | %b | %b     | %b      | PASS   | %0d      | %0d     | Observation Cycle %0d",
                             $time, clk, rst, x, y, y_golden, correct, false, current_cycle);
                end else begin
                    false = false + 1;
                    $display("%0tns | %b   | %b   | %b | %b     | %b      | FAIL   | %0d      | %0d     | Observation Cycle %0d",
                             $time, clk, rst, x, y, y_golden, correct, false, current_cycle);
                    $error("Verification Mismatch during final observation at time %0tns", $time);
                end
            end
    
            $display("\n--------------------------------------------------------------------------------------------------------------------");
            $display("Simulation finished at time %0t ns", $time);
            $display("Total Correct Comparisons: %0d", correct);
            $display("Total False Comparisons:   %0d", false);
            $display("--------------------------------------------------------------------------------------------------------------------");
            
            $finish; // End simulation
        end
