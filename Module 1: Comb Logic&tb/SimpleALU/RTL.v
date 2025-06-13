module Logic(
input [3:0] A, B,
input [1:0] opcode,
output reg [3:0] Out,
output reg Cout

    );
    always@(*) begin
    case(opcode)
    2'b00:
    {Cout,Out}=A+B;
    2'b01:
    {Cout,Out}=A-B;
    2'b10:
    {Cout,Out}=A^B;
    2'b11:
    {Cout,Out}=~A;
    default:
    {Cout,Out}=4'b0000;
    endcase
    end
endmodule
