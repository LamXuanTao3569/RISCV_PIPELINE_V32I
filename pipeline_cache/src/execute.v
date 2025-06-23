module execute(
    input clk, rst_n,
    // from ID/EX reg
    input RegWrite_in, ALUSrc_in, MemWrite_in, Branch_in, Jump_in,
    input [1:0] ResultSrc_in,
    input [1:0] MemOp_in,
    input [3:0] ALUControl_in,
    input [2:0] funct3_in,
    input [31:0] RD1_in, RD2_in, Imm_Ext_in, PC_in, PCPlus4_in,
    input [4:0] rd_in,
    input [6:0] opcode_in,

    // from forwarding unit
    input [1:0] ForwardA, ForwardB,

    // for forwarding path
    input [31:0] alu_result_mem,
    input [31:0] result_wb,

    // to EX/MEM reg
    output reg RegWrite_out, MemWrite_out,
    output reg [1:0] ResultSrc_out,
    output reg [1:0] MemOp_out,
    output reg [4:0] rd_out,
    output reg [31:0] PCPlus4_out, 
    output [31:0] WriteData_out,
    output reg [31:0] alu_result_out,
    
    // to fetch stage
    output pc_src_out,
    output [31:0] pc_target_out,
    output branch_feedback_valid,
    output [31:0] branch_feedback_pc,
    output branch_feedback_taken
);

    wire zero_flag;
    reg [31:0] src_a;
    wire [31:0] src_b, alu_result;
    reg [31:0] forwarded_rd2;

    // Mux for forwarding operand A
    always @(*) begin
        case (ForwardA)
            2'b00: src_a = RD1_in;
            2'b01: src_a = alu_result_mem;
            2'b10: src_a = result_wb;
            default: src_a = RD1_in;
        endcase
    end

    // Mux for forwarding operand B (ALU input)
    always @(*) begin
        case (ForwardB)
            2'b00: forwarded_rd2 = RD2_in;
            2'b01: forwarded_rd2 = alu_result_mem;
            2'b10: forwarded_rd2 = result_wb;
            default: forwarded_rd2 = RD2_in;
        endcase
    end
    
    assign WriteData_out = MemWrite_in ? forwarded_rd2 : 32'h0;

    // Mux for ALU operand B (RD2 or immediate)
    assign src_b = ALUSrc_in ? Imm_Ext_in : forwarded_rd2;

    ALU alu_unit (
        .A(src_a),
        .B(src_b),
        .ALUControl(ALUControl_in),
        .opcode(opcode_in),
        .Result(alu_result),
        .Zero(zero_flag)
    );

    // Branch logic from old execute_cycle.v
    reg branch_taken_reg;
    always @(*) begin
        case (funct3_in)
            3'b000: branch_taken_reg = zero_flag; // beq
            3'b001: branch_taken_reg = ~zero_flag; // bne
            3'b100: branch_taken_reg = alu_result[0]; // blt (slt result)
            3'b101: branch_taken_reg = ~alu_result[0]; // bge (slt result)
            3'b110: branch_taken_reg = alu_result[0]; // bltu (sltu result)
            3'b111: branch_taken_reg = ~alu_result[0]; // bgeu (sltu result)
            default: branch_taken_reg = 1'b0;
        endcase
    end

    wire branch_taken = Branch_in & branch_taken_reg;

    assign pc_src_out = branch_taken || Jump_in;
    // For JALR, the target is in the ALU result (rs1 + imm) with LSB cleared.
    // For JAL and branches, it's PC + imm.
    wire [31:0] jalr_target = alu_result & 32'hFFFFFFFE;
    assign pc_target_out = (Jump_in && ALUSrc_in) ? jalr_target : (PC_in + Imm_Ext_in);
    assign branch_feedback_valid = Branch_in;
    assign branch_feedback_pc = PC_in;
    assign branch_feedback_taken = branch_taken;

    always @(*) begin
        RegWrite_out = RegWrite_in;
        MemWrite_out = MemWrite_in;
        ResultSrc_out = ResultSrc_in;
        MemOp_out = MemOp_in;
        rd_out = rd_in;
        PCPlus4_out = PCPlus4_in;
        alu_result_out = alu_result;
    end

endmodule 