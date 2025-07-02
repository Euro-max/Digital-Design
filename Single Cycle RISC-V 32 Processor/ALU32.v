module ALU32(
input [31:0]A,B,
input [2:0] operation,
output reg[31:0] ALUResult,
output reg zeroflag,
output reg signflag,
output reg overflowflag
    );
     reg [32:0]sum_result;
     reg[31:0]negB;
    always@(*)begin
    signflag=1'b0;
    overflowflag=1'b0;
    zeroflag=1'b0;
    case(operation)
    3'b000: begin 
    sum_result=A+B;
    ALUResult=sum_result[31:0];
    if ((A[31] == B[31]) && (A[31] != ALUResult[31])) begin
                        overflowflag = 1'b1;
                    end else begin
                        overflowflag = 1'b0;
                    end
                    end
    3'b001:ALUResult=A<<B; 
    3'b010:begin 
   negB = ~B + 1;
                   sum_result = A + negB;
                   ALUResult = sum_result[31:0];
   
                  
                   if ((A[31] != B[31]) && (A[31] != ALUResult[31])) begin
                       overflowflag = 1'b1;
                   end else begin
                       overflowflag = 1'b0;
                   end
                  
               end
    
   
    3'b100:ALUResult=A^B;
    3'b101:ALUResult=A>>B;
    3'b110:ALUResult=A|B;
    3'b111:ALUResult=A&B;
    default:ALUResult=32'b0;
    endcase
     signflag=ALUResult[31]; 
    if(ALUResult==32'b0) zeroflag=1'b1;
    else zeroflag=1'b0;
    end
   
endmodule