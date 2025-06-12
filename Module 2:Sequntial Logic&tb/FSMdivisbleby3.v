module FSM3(
input clk,rst,x,
output y
    );
    reg[1:0]current,next;
    localparam Sr=2'b00; //rst
    localparam S0=2'b01;//1
    localparam S1=2'b10;//11
    always@(posedge clk or posedge rst)begin
    if(rst)
    current<=2'b00;
    else
    current<=next;
    end
    always@(*)begin
    case(current)
    Sr:if(x) next=S0;else next=Sr;
    S0:if(x) next=S1;else next=S0;
    S1:if(x) next=S0;else next=S1;
    endcase
    end
endmodule
