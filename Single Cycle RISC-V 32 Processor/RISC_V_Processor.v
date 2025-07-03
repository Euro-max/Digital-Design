`timescale 1ns/1ps

module RISC_V_Processor(
    input clk,
    input reset,
    output[31:0]no
);


    wire [31:0] PC;
    wire PCSrc;
    wire [31:0] DataMemory_out;
    wire [31:0] ImmExt;
    wire [31:0] RD1, RD2, WD3;
    wire [31:0] ALUResult, ALUOut;
    wire [31:0] ReadData;
        wire [31:0] instruction_out;
    wire Zero, Sign;
    
    // Control signals
    wire RegWrite,ALUSrc, MemWrite,Branch;
    wire [1:0]ResultSrc;
    wire [1:0] ImmSrc, ALUOp;
    wire [2:0] ALUControl;
    
    // Instruction fields
   
    
    // Extract instruction fields

    wire[31:0]PCNext_from_PCNext_Calc;
    // ControlUnit
   Control_Unit main_dec (
        .opcode(instruction_out[6:0]),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .ALUOp(ALUOp)
    );
        // Sign Extend
          SignExt sign_ext(
              .Instr(instruction_out),
              .ImmSrc(ImmSrc),
              .ImmExt(ImmExt)
          );
 NextPCLogic PC_Next (
            .PC(PC),
            .ImmExt(ImmExt), 
            .PCSrc(PCSrc), 
            .PCNext(PCNext_from_PCNext_Calc) 
        );
        
        ProgramCounter P_C (
            .clk(clk),
            .areset(~reset),
            .load(1'b1), 
            .PCNext(PCNext_from_PCNext_Calc), 
            .PC(PC)
        );
    
   // Instruction Memory (ROM)
ROM imem(
    .addr(PC),      
    .instr(instruction_out)        
);
    
    // Register File
    RegFile reg_file(
        .clk(clk),
        .reset(reset),
        .RegWrite(RegWrite),
        .a1(instruction_out[19:15]),
        .a2(instruction_out[24:20]),
        .a3(instruction_out[11:7]),
        .wd3(WD3),
        .rd1(RD1),
        .rd2(RD2)
    );
    
    // ALU Decoder
    Dec alu_dec (
        .ALUOp(ALUOp),
        .funct3(instruction_out[14:12]),
        .funct7_5(instruction_out[30]),
        .ALUControl(ALUControl)
    );

   
    
   
    wire overflowflag;
    
    // ALU
    ALU32 alu(
        .A(RD1),
        .B(ALUSrc ? ImmExt : RD2),
        .operation(ALUControl),
        .ALUResult(ALUResult),
        .zeroflag(Zero),
        .signflag(Sign),
        .overflowflag(overflowflag)
    );
    
     //DATA Memory
   DataMemory dmem(
     .clk(clk),
          .addr(ALUResult), 
          .din(RD2), 
          .WE(MemWrite), 
          .dout(DataMemory_out) 
);
    
 
   
 
    assign PCSrc = Branch && (
    (instruction_out[14:12] == 3'b000 && Zero)   || 
    (instruction_out[14:12] == 3'b001 && ~Zero)  || 
    (instruction_out[14:12] == 3'b100 && Sign)      
);

    
   assign WD3 = (ResultSrc == 2'b00) ? ALUResult :
             (ResultSrc == 2'b01) ? DataMemory_out :
             32'b0;
    
    // ALU Control
    assign no=ALUResult;
    
    
   
    
   

endmodule
