module FSM_tb;
//1 Testbench signals
reg clk,rst_n,x;
wire y;
parameter clock=10;
parameter half=clock/2;
parameter cycles=50;
//2 Instiantiate DUT
FSM DUT(.clk(clk),.rst_n(rst_n),.x(x),.y(y));
//3 Clock Generation
initial begin
clk=1'b1;
forever #(half)clk=~clk;
end
//4 Test Stimuli
initial begin
$srandom($time); //time
rst_n=1'b0;
x=1'b0;
$monitor("Time=%0t ns | clk=%b | rst_n=%b | x=%b | y=%b", $time, clk, rst_n, x, y);
    #(2 * clock);
    rst_n = 1'b1; // Release reset

    // Apply random data input for a number of cycles
    repeat (cycles) begin
        #(clock); // wait one full clock period
        x = $random % 2; // random 0 or 1
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
