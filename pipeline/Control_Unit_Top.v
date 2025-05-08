module Control_Unit_Top(
    input [6:0] Op,
    input [2:0] funct3,
    input funct7_5,
    output RegWrite, ALUSrc, MemWrite, Branch, Jump,
    output [1:0] ResultSrc, MemOp,  // Thêm MemOp
    output [2:0] ImmSrc,            // Change to 3 bits
    output [3:0] ALUControl
);

    wire [1:0] ALUOp;

    Main_Decoder md (
        .Op(Op),
        .funct3(funct3),  // Thêm funct3
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .Jump(Jump),
        .ImmSrc(ImmSrc),
        .MemOp(MemOp),  // Thêm MemOp
        .ALUOp(ALUOp)
    );

    ALU_Decoder ad (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .ALUControl(ALUControl)
    );
endmodule