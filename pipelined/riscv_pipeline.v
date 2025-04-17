module riscv_pipeline (
    input clk, reset,
    output [31:0] pc,
    output [31:0] alu_result
);
    // IF/ID pipeline registers
    wire [31:0] if_id_pc, if_id_inst;
    // ID/EX pipeline registers
    wire [31:0] id_ex_reg1, id_ex_reg2, id_ex_imm;
    wire [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
    wire [6:0] id_ex_opcode;
    wire id_ex_reg_write, id_ex_mem_write, id_ex_mem_read;
    wire [2:0] id_ex_alu_op;
    // EX/MEM pipeline registers
    wire [31:0] ex_mem_alu_result, ex_mem_reg2;
    wire [4:0] ex_mem_rd;
    wire ex_mem_reg_write, ex_mem_mem_write;
    // MEM/WB pipeline registers
    wire [31:0] mem_wb_result;
    wire [4:0] mem_wb_rd;
    wire mem_wb_reg_write;

    // Control signals
    wire stall;
    wire [31:0] alu_in1, alu_in2;
    wire [1:0] forward_a, forward_b;

    // Pipeline stages
    if_stage if_inst (.clk(clk), .reset(reset), .stall(stall), .pc(pc), .instr(if_id_inst));
    id_stage id_inst (.clk(clk), .reset(reset), .stall(stall), .if_id_inst(if_id_inst), 
                     .mem_wb_rd(mem_wb_rd), .mem_wb_result(mem_wb_result), .mem_wb_reg_write(mem_wb_reg_write),
                     .reg1(id_ex_reg1), .reg2(id_ex_reg2), .imm(id_ex_imm), 
                     .rs1(id_ex_rs1), .rs2(id_ex_rs2), .rd(id_ex_rd), .opcode(id_ex_opcode),
                     .reg_write(id_ex_reg_write), .mem_write(id_ex_mem_write), .mem_read(id_ex_mem_read),
                     .alu_op(id_ex_alu_op));
    ex_stage ex_inst (.clk(clk), .reset(reset), .stall(stall), .id_ex_reg1(id_ex_reg1), .id_ex_reg2(id_ex_reg2),
                     .id_ex_imm(id_ex_imm), .id_ex_rs1(id_ex_rs1), .id_ex_rs2(id_ex_rs2), .id_ex_rd(id_ex_rd),
                     .id_ex_opcode(id_ex_opcode), .id_ex_reg_write(id_ex_reg_write), .id_ex_mem_write(id_ex_mem_write),
                     .id_ex_mem_read(id_ex_mem_read), .id_ex_alu_op(id_ex_alu_op),
                     .ex_mem_alu_result(ex_mem_alu_result), .ex_mem_reg2(ex_mem_reg2), .ex_mem_rd(ex_mem_rd),
                     .ex_mem_reg_write(ex_mem_reg_write), .ex_mem_mem_write(ex_mem_mem_write),
                     .forward_a(forward_a), .forward_b(forward_b), .ex_mem_alu_result_in(ex_mem_alu_result),
                     .mem_wb_result(mem_wb_result));
    mem_stage mem_inst (.clk(clk), .reset(reset), .stall(stall), .ex_mem_alu_result(ex_mem_alu_result),
                       .ex_mem_reg2(ex_mem_reg2), .ex_mem_rd(ex_mem_rd), .ex_mem_reg_write(ex_mem_reg_write),
                       .ex_mem_mem_write(ex_mem_mem_write), .mem_wb_result(mem_wb_result), .mem_wb_rd(mem_wb_rd),
                       .mem_wb_reg_write(mem_wb_reg_write));
    wb_stage wb_inst (.clk(clk), .reset(reset), .stall(stall), .mem_wb_result_in(mem_wb_result),
                     .mem_wb_rd_in(mem_wb_rd), .mem_wb_reg_write_in(mem_wb_reg_write));

    // Forwarding and hazard detection
    forwarding_unit fwd (.ex_mem_rd(ex_mem_rd), .mem_wb_rd(mem_wb_rd), .id_ex_rs1(id_ex_rs1), .id_ex_rs2(id_ex_rs2),
                        .ex_mem_reg_write(ex_mem_reg_write), .mem_wb_reg_write(mem_wb_reg_write),
                        .forward_a(forward_a), .forward_b(forward_b));
    hazard_detection hazard (.id_ex_mem_read(id_ex_mem_read), .id_ex_rd(id_ex_rd), 
                            .if_id_rs1(id_ex_rs1), .if_id_rs2(id_ex_rs2), .stall(stall));

    assign alu_result = ex_mem_alu_result;
endmodule