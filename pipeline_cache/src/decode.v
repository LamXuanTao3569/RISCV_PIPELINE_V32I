module decode(
    input clk, rst_n,
    input [31:0] instr_in,
    
    // Write-back signals for register file
    input reg_write_en_wb,
    input [4:0] rd_wb,
    input [31:0] result_wb,

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

    // Outputs for Register_File
    output [4:0] A1,
    output [4:0] A2,
    output [4:0] A3,
    output [31:0] WD3,
    output WE3
);

    wire [2:0] imm_src;
    wire [6:0] funct7 = instr_in[31:25];
    wire funct7_5 = instr_in[30];
    wire [6:0] opcode = instr_in[6:0];
    reg exception_reg;

    Control_Unit_Top control_unit (
        .Op(instr_in[6:0]),
        .funct3(instr_in[14:12]),
        .funct7_5(funct7_5),
        .funct7(funct7),
        .RegWrite(RegWrite_out),
        .ImmSrc(imm_src),
        .ALUSrc(ALUSrc_out),
        .MemWrite(MemWrite_out),
        .ResultSrc(ResultSrc_out),
        .Branch(Branch_out),
        .Jump(Jump_out),
        .ALUControl(ALUControl_out),
        .MemOp(MemOp_out)
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

    // Exception detection: illegal instruction (opcode not recognized)
    always @(*) begin
        case (opcode)
            7'b0110011, 7'b0010011, 7'b0000011, 7'b0100011, 7'b1100011, 7'b1101111, 7'b1100111, 7'b0010111, 7'b0110111, 7'b1110011:
                exception_reg = 1'b0;
            default:
                exception_reg = 1'b1;
        endcase
    end
    assign exception_out = exception_reg;

    assign rd1_out = rd1_in;
    assign rd2_out = rd2_in;
    assign A1 = instr_in[19:15];
    assign A2 = instr_in[24:20];
    assign A3 = rd_wb;
    assign WD3 = result_wb;
    assign WE3 = reg_write_en_wb;

endmodule 