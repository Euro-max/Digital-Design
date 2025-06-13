`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/11/2025 02:32:39 AM
// Design Name: 
// Module Name: Combi_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for Combi module
// 
// Dependencies: Combi.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module D_FF_tb;

    // 1. Declare inputs as regs and outputs as wires
    reg clk;
    reg rst_n;
    reg d_in;
    wire q_out;

    // 2. Parameters
    parameter clock = 10;
    parameter half = clock / 2;
    parameter cycles = 80;

    // 3. Instantiate the Device Under Test (DUT)
    D_FF DUT (
        .clk(clk),
        .rst_n(rst_n),
        .d_in(d_in),
        .q_out(q_out)
    );

    // 4. Clock Generation
    initial begin
        clk = 0;
        forever #(half) clk = ~clk;
    end

    // 5. Test Stimulus
    initial begin
        $srandom($time);

        // Initialize signals
        d_in = 1'b0;
        rst_n = 1'b0; // Apply reset (active low)

        // Monitor signals
        $monitor("Time=%0t ns | clk=%b | rst_n=%b | d_in=%b | q_out=%b", $time, clk, rst_n, d_in, q_out);

        // Hold reset for 2 clock cycles
        #(2 * clock);
        rst_n = 1'b1; // Release reset

        // Apply random data input for a number of cycles
        repeat (cycles) begin
            #(clock); // wait one full clock period
            d_in = $random % 2; // random 0 or 1
        end

        // Assert asynchronous reset during operation
        #(clock / 2); 
        rst_n = 1'b0; 
        #(2 * clock);
        rst_n = 1'b1;

        // Observe for a few more cycles
        #(2 * clock);

        $display("\nSimulation finished at time %0t ns", $time);
        $finish;
    end

endmodule
