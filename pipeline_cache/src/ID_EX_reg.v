module ID_EX_reg (
    input clk, rst_n,
    input bubble, // To insert a NOP from Hazard Unit
    input flush,  // To clear the register

    // Control signals from Decode
    input RegWrite_in,
    input ALUSrc_in,
    input MemWrite_in,
    input [1:0] ResultSrc_in,
    input Branch_in,
    input Jump_in,
    input [3:0] ALUControl_in,
    input [1:0] MemOp_in,
    input [2:0] funct3_in,

    // Data from Decode
    input [31:0] PC_in,
    input [31:0] PCPlus4_in,
    input [31:0] RD1_in,
    input [31:0] RD2_in,
    input [31:0] Imm_Ext_in,
    input [4:0] rs1_in,
    input [4:0] rs2_in,
    input [4:0] rd_in,
    input [6:0] opcode_in,

    // Outputs to Execute
    output reg RegWrite_out,
    output reg ALUSrc_out,
    output reg MemWrite_out,
    output reg [1:0] ResultSrc_out,
    output reg Branch_out,
    output reg Jump_out,
    output reg [3:0] ALUControl_out,
    output reg [1:0] MemOp_out,
    output reg [2:0] funct3_out,
    output reg [31:0] PC_out,
    output reg [31:0] PCPlus4_out,
    output reg [31:0] RD1_out,
    output reg [31:0] RD2_out,
    output reg [31:0] Imm_Ext_out,
    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,
    output reg [4:0] rd_out,
    output reg [6:0] opcode_out
);

    reg [31:0] src_a;
    wire [31:0] src_b, alu_result;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush || bubble) begin
            RegWrite_out <= 1'b0;
            ALUSrc_out <= 1'b0;
            MemWrite_out <= 1'b0;
            ResultSrc_out <= 2'b0;
            Branch_out <= 1'b0;
            Jump_out <= 1'b0;
            ALUControl_out <= 4'b0;
            MemOp_out <= 2'b0;
            funct3_out <= 3'b0;
            PC_out <= 32'b0;
            PCPlus4_out <= 32'b0;
            RD1_out <= 32'b0;
            RD2_out <= 32'b0;
            Imm_Ext_out <= 32'b0;
            rs1_out <= 5'b0;
            rs2_out <= 5'b0;
            rd_out <= 5'b0;
            opcode_out <= 7'b0;
        end else begin
            RegWrite_out <= RegWrite_in;
            ALUSrc_out <= ALUSrc_in;
            MemWrite_out <= MemWrite_in;
            ResultSrc_out <= ResultSrc_in;
            Branch_out <= Branch_in;
            Jump_out <= Jump_in;
            ALUControl_out <= ALUControl_in;
            MemOp_out <= MemOp_in;
            funct3_out <= funct3_in;
            PC_out <= PC_in;
            PCPlus4_out <= PCPlus4_in;
            RD1_out <= RD1_in;
            RD2_out <= RD2_in;
            Imm_Ext_out <= Imm_Ext_in;
            rs1_out <= rs1_in;
            rs2_out <= rs2_in;
            rd_out <= rd_in;
            opcode_out <= opcode_in;
        end
    end

endmodule