module decode(
    input clk, rst_n, flush,
    input ID_EX_Bubble_in, // Input for stall signal
    input [31:0] instr_in,
    
    // Inputs from ID/EX register
    input [31:0] rd1_in,
    input [31:0] rd2_in,

    // Outputs for ID/EX register
    output RegWrite_out,
    output ALUSrc_out,
    output MemWrite_out,
    output [1:0] ResultSrc_out,
    output Branch_out,
    output Jump_out,
    output [3:0] ALUControl_out,
    output [1:0] MemOp_out,
    output [2:0] funct3_out,
    output [31:0] rd1_out,
    output [31:0] rd2_out,
    output [31:0] imm_ext_out,
    output [4:0] rs1_out,
    output [4:0] rs2_out,
    output [4:0] rd_out,
    output exception_out,
    output [6:0] opcode_out,

    // Outputs for Register_File Read Ports
    output [4:0] A1,
    output [4:0] A2
);

    wire [2:0] imm_src;
    wire [6:0] funct7 = instr_in[31:25];
    wire funct7_5 = instr_in[30];
    wire [6:0] opcode = instr_in[6:0];
    wire [1:0] alu_op;
    reg exception_reg;

    // Internal wires for pre-bubble control signals
    wire pre_RegWrite, pre_ALUSrc, pre_MemWrite, pre_Branch, pre_Jump;
    wire [1:0] pre_ResultSrc, pre_MemOp;
    wire [3:0] pre_ALUControl;

    Main_Decoder control_unit (
        .Op(instr_in[6:0]),
        .funct3(instr_in[14:12]),
        .RegWrite(pre_RegWrite),
        .ImmSrc(imm_src),
        .ALUSrc(pre_ALUSrc),
        .MemWrite(pre_MemWrite),
        .ResultSrc(pre_ResultSrc),
        .Branch(pre_Branch),
        .Jump(pre_Jump),
        .ALUOp(alu_op),
        .MemOp(pre_MemOp)
    );

    // ALU Decoder to convert ALUOp to ALUControl
    ALU_Decoder alu_decoder (
        .ALUOp(alu_op),
        .funct3(instr_in[14:12]),
        .funct7_5(funct7_5),
        .ALUControl(pre_ALUControl)
    );

    Sign_Extend sign_extend (
        .In(instr_in),
        .Imm_Ext(imm_ext_out),
        .ImmSrc(imm_src)
    );

    assign rs1_out = instr_in[19:15];
    assign rs2_out = instr_in[24:20];
    assign rd_out = instr_in[11:7];
    assign funct3_out = instr_in[14:12];
    assign opcode_out = instr_in[6:0];

    // Exception detection: illegal instruction (opcode not recognized)
    always @(*) begin
        case (opcode)
            7'b0110011, 7'b0010011, 7'b0000011, 7'b0100011, 7'b1100011, 7'b1101111, 7'b1100111, 7'b0010111, 7'b0110111, 7'b1110011:
                exception_reg = 1'b0;
            default:
                exception_reg = 1'b1;
        endcase
    end
    assign exception_out = exception_reg & ~flush;

    // Mux control signals with bubble to create a NOP
    assign RegWrite_out = pre_RegWrite & ~ID_EX_Bubble_in;
    assign ALUSrc_out = pre_ALUSrc & ~ID_EX_Bubble_in;
    assign MemWrite_out = pre_MemWrite & ~ID_EX_Bubble_in;
    assign Branch_out = pre_Branch & ~ID_EX_Bubble_in;
    assign Jump_out = pre_Jump & ~ID_EX_Bubble_in;
    assign ResultSrc_out = ID_EX_Bubble_in ? 2'b0 : pre_ResultSrc;
    assign MemOp_out = ID_EX_Bubble_in ? 2'b0 : pre_MemOp;
    assign ALUControl_out = ID_EX_Bubble_in ? 4'b0 : pre_ALUControl;

    assign rd1_out = rd1_in;
    assign rd2_out = rd2_in;
    assign A1 = instr_in[19:15];
    assign A2 = instr_in[24:20];

endmodule 