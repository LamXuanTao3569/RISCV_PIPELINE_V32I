module RISCV_Single_Cycle (
    input clk,
    input rst_n,
    output [31:0] PC_out_top,
    output [31:0] InstrF,
    output [31:0] DataMem0,
    output [31:0] DataMem1,
    output [31:0] DataMem2,
    output [31:0] Reg_inst_registers_0,
    output [31:0] Reg_inst_registers_1,
    output [31:0] Reg_inst_registers_2,
    output [31:0] Reg_inst_registers_3,
    output [31:0] Reg_inst_registers_4,
    output [31:0] Reg_inst_registers_5,
    output [31:0] Reg_inst_registers_6,
    output [31:0] Reg_inst_registers_7,
    output [31:0] Reg_inst_registers_8,
    output [31:0] Reg_inst_registers_9,
    output [31:0] Reg_inst_registers_10,
    output [31:0] Reg_inst_registers_11,
    output [31:0] Reg_inst_registers_12,
    output [31:0] Reg_inst_registers_13,
    output [31:0] Reg_inst_registers_14,
    output [31:0] Reg_inst_registers_15,
    output [31:0] Reg_inst_registers_16,
    output [31:0] Reg_inst_registers_17,
    output [31:0] Reg_inst_registers_18,
    output [31:0] Reg_inst_registers_19,
    output [31:0] Reg_inst_registers_20,
    output [31:0] Reg_inst_registers_21,
    output [31:0] Reg_inst_registers_22,
    output [31:0] Reg_inst_registers_23,
    output [31:0] Reg_inst_registers_24,
    output [31:0] Reg_inst_registers_25,
    output [31:0] Reg_inst_registers_26,
    output [31:0] Reg_inst_registers_27,
    output [31:0] Reg_inst_registers_28,
    output [31:0] Reg_inst_registers_29,
    output [31:0] Reg_inst_registers_30,
    output [31:0] Reg_inst_registers_31,
    output [31:0] DMEM_inst_memory_0,
    output [31:0] DMEM_inst_memory_1,
    output [31:0] DMEM_inst_memory_2,
    output [31:0] DMEM_inst_memory_3,
    output [31:0] IMEM_inst_memory_0,
    output [31:0] IMEM_inst_memory_1,
    output [31:0] IMEM_inst_memory_2,
    output [31:0] IMEM_inst_memory_3,
    output [31:0] Instruction_out_top
);

    //----------------------------------------------------------------
    // Wires Declaration
    //----------------------------------------------------------------

    // Hazard Unit -> Control signals
    wire pc_write_en, if_id_write_en, id_ex_bubble;
    assign pipeline_flush = exception && !startup_suppress;
    assign branch_flush = ex_pc_src && id_ex_branch && !exception;
    
    // Forwarding Unit -> Forwarding selectors
    wire [1:0] forward_a_ex, forward_b_ex;

    // WriteBack -> Decode (for register file write)
    wire wb_reg_write_en;
    wire [4:0] wb_rd;
    wire [31:0] wb_result;

    // Fetch Stage -> IF/ID Register
    wire [31:0] if_pc, if_pc_plus4, if_instr;
    
    // IF/ID Register -> Decode Stage
    wire [31:0] if_id_pc, if_id_pc_plus4, if_id_instr;

    // Decode Stage -> ID/EX Register
    wire id_reg_write, id_alu_src, id_mem_write, id_branch, id_jump;
    wire [1:0] id_result_src, id_mem_op;
    wire [3:0] id_alu_control;
    wire [2:0] id_funct3;
    wire [31:0] id_rd1, id_rd2, id_imm_ext;
    wire [4:0] id_rs1, id_rs2, id_rd;
    wire [6:0] id_opcode;

    // ID/EX Register -> Execute Stage
    wire id_ex_reg_write, id_ex_alu_src, id_ex_mem_write, id_ex_branch, id_ex_jump;
    wire [1:0] id_ex_result_src, id_ex_mem_op;
    wire [3:0] id_ex_alu_control;
    wire [2:0] id_ex_funct3;
    wire [31:0] id_ex_pc, id_ex_pc_plus4, id_ex_rd1, id_ex_rd2, id_ex_imm_ext;
    wire [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
    wire [6:0] id_ex_opcode;

    // Execute Stage -> EX/MEM Register & Fetch Stage
    wire ex_pc_src;
    wire [31:0] ex_pc_target;
    wire ex_reg_write, ex_mem_write;
    wire [1:0] ex_result_src, ex_mem_op;
    wire [31:0] ex_alu_result, ex_write_data;
    wire [4:0] ex_rd;
    wire [31:0] ex_pc_plus4;

    // EX/MEM Register -> Memory Stage
    wire ex_mem_reg_write, ex_mem_mem_write;
    wire [1:0] ex_mem_result_src, ex_mem_mem_op;
    wire [31:0] ex_mem_alu_result, ex_mem_write_data;
    wire [4:0] ex_mem_rd;
    wire [31:0] ex_mem_pc_plus4;

    // Memory Stage -> MEM/WB Register
    wire mem_reg_write;
    wire [1:0] mem_result_src;
    wire [31:0] mem_read_data, mem_alu_result;
    wire [4:0] mem_rd;
    wire [31:0] mem_pc_plus4;

    // MEM/WB Register -> Writeback Stage & Forwarding Unit
    wire mem_wb_reg_write;
    wire [1:0] mem_wb_result_src;
    wire [31:0] mem_wb_read_data, mem_wb_alu_result;
    wire [4:0] mem_wb_rd;
    wire [31:0] mem_wb_pc_plus4;

    // fetch stage debug
    wire fetch_branch_predict;

    // Exception signal
    wire exception;

    // Branch predictor feedback
    wire branch_feedback_valid;
    wire [31:0] branch_feedback_pc;
    wire branch_feedback_taken;

    // Suppress exception for one cycle at startup to ignore initial garbage
    reg [1:0] startup_suppress_cnt;
    wire startup_suppress = (startup_suppress_cnt != 2'b00);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) startup_suppress_cnt <= 2'b10;
        else if (startup_suppress_cnt != 2'b00) startup_suppress_cnt <= startup_suppress_cnt - 1'b1;
    end

    //----------------------------------------------------------------
    // Instruction and Data Memories
    //----------------------------------------------------------------
    Instruction_Memory IMEM_inst (
        .A(if_pc),
        .RD(if_instr)
    );
    assign IMEM_inst_memory_0 = IMEM_inst.memory[0];
    assign IMEM_inst_memory_1 = IMEM_inst.memory[1];
    assign IMEM_inst_memory_2 = IMEM_inst.memory[2];
    assign IMEM_inst_memory_3 = IMEM_inst.memory[3];

    Data_Memory DMEM_inst (
        .clk(clk),
        .rst_n(rst_n),
        .WE(ex_mem_mem_write),
        .MemOp(ex_mem_mem_op),
        .A(ex_mem_alu_result),
        .WD(ex_mem_write_data),
        .funct3(ex_mem_funct3),
        .RD(mem_read_data)
    );
    assign DMEM_inst_memory_0 = DMEM_inst.memory[0];
    assign DMEM_inst_memory_1 = DMEM_inst.memory[1];
    assign DMEM_inst_memory_2 = DMEM_inst.memory[2];
    assign DMEM_inst_memory_3 = DMEM_inst.memory[3];

    //----------------------------------------------------------------
    // Pipeline Stages
    //----------------------------------------------------------------

    // FETCH STAGE
    fetch fetch_stage (
        .clk(clk), .rst_n(rst_n),
        .pc_write_en(pc_write_en),
        .pc_src(exception ? 1'b1 : ex_pc_src),
        .pc_target(exception ? 32'h00000080 : ex_pc_target),
        .predictor_update(branch_feedback_valid),
        .predictor_update_index(branch_feedback_pc[7:2]),
        .predictor_outcome(branch_feedback_taken),
        .if_instr(if_instr),
        .pc_out(if_pc),
        .pc_plus4_out(if_pc_plus4),
        .branch_predict_out(fetch_branch_predict)
    );

    IF_ID_reg if_id_reg (
        .clk(clk), .rst_n(rst_n),
        .if_id_write(if_id_write_en),
        .if_id_flush(branch_flush),
        .pc_in(if_pc),
        .instr_in(if_instr),
        .pc_plus4_in(if_pc_plus4),
        .pc_out(if_id_pc),
        .instr_out(if_id_instr),
        .pc_plus4_out(if_id_pc_plus4)
    );

    // Register File instance for pipeline and testbench access
    wire [4:0] rf_A1, rf_A2, rf_A3;
    wire [31:0] rf_WD3, rf_RD1, rf_RD2;
    Register_File Reg_inst (
        .clk(clk),
        .rst_n(rst_n),
        .WE3(wb_reg_write_en),
        .A1(rf_A1),
        .A2(rf_A2),
        .A3(wb_rd),
        .WD3(wb_result),
        .RD1(rf_RD1),
        .RD2(rf_RD2)
    );

    // DECODE STAGE
    decode decode_stage (
        .clk(clk), .rst_n(rst_n), .flush(startup_suppress),
        .ID_EX_Bubble_in(id_ex_bubble),
        .instr_in(if_id_instr),
        .rd1_in(rf_RD1),
        .rd2_in(rf_RD2),
        .A1(rf_A1),
        .A2(rf_A2),
        .RegWrite_out(id_reg_write), .ALUSrc_out(id_alu_src), .MemWrite_out(id_mem_write),
        .ResultSrc_out(id_result_src), .Branch_out(id_branch), .Jump_out(id_jump),
        .ALUControl_out(id_alu_control), .MemOp_out(id_mem_op), .funct3_out(id_funct3),
        .rd1_out(id_rd1), .rd2_out(id_rd2), .imm_ext_out(id_imm_ext),
        .rs1_out(id_rs1), .rs2_out(id_rs2), .rd_out(id_rd),
        .exception_out(exception),
        .opcode_out(id_opcode)
    );

    ID_EX_reg id_ex_reg (
        .clk(clk), .rst_n(rst_n),
        .bubble(id_ex_bubble), .flush(pipeline_flush),
        .RegWrite_in(id_reg_write), .ALUSrc_in(id_alu_src), .MemWrite_in(id_mem_write),
        .ResultSrc_in(id_result_src), .Branch_in(id_branch), .Jump_in(id_jump),
        .ALUControl_in(id_alu_control), .MemOp_in(id_mem_op), .funct3_in(id_funct3),
        .PC_in(if_id_pc), .PCPlus4_in(if_id_pc_plus4), .RD1_in(id_rd1), .RD2_in(id_rd2),
        .Imm_Ext_in(id_imm_ext), .rs1_in(id_rs1), .rs2_in(id_rs2), .rd_in(id_rd),
        .opcode_in(id_opcode),
        .RegWrite_out(id_ex_reg_write), .ALUSrc_out(id_ex_alu_src), .MemWrite_out(id_ex_mem_write),
        .ResultSrc_out(id_ex_result_src), .Branch_out(id_ex_branch), .Jump_out(id_ex_jump),
        .ALUControl_out(id_ex_alu_control), .MemOp_out(id_ex_mem_op), .funct3_out(id_ex_funct3),
        .PC_out(id_ex_pc), .PCPlus4_out(id_ex_pc_plus4), .RD1_out(id_ex_rd1), .RD2_out(id_ex_rd2),
        .Imm_Ext_out(id_ex_imm_ext), .rs1_out(id_ex_rs1), .rs2_out(id_ex_rs2), .rd_out(id_ex_rd),
        .opcode_out(id_ex_opcode)
    );
    
    // EXECUTE STAGE
    execute execute_stage (
        .RegWrite_in(id_ex_reg_write), .ALUSrc_in(id_ex_alu_src), .MemWrite_in(id_ex_mem_write),
        .Branch_in(id_ex_branch), .Jump_in(id_ex_jump), .ResultSrc_in(id_ex_result_src),
        .MemOp_in(id_ex_mem_op), .ALUControl_in(id_ex_alu_control), .funct3_in(id_ex_funct3),
        .RD1_in(id_ex_rd1), .RD2_in(id_ex_rd2), .Imm_Ext_in(id_ex_imm_ext), .PC_in(id_ex_pc),
        .PCPlus4_in(id_ex_pc_plus4), .rd_in(id_ex_rd),
        .opcode_in(id_ex_opcode),
        .ForwardA(forward_a_ex), .ForwardB(forward_b_ex),
        .alu_result_mem(ex_mem_alu_result), .result_wb(wb_result),
        .RegWrite_out(ex_reg_write), .MemWrite_out(ex_mem_write), .ResultSrc_out(ex_result_src), 
        .MemOp_out(ex_mem_op), .rd_out(ex_rd), .PCPlus4_out(ex_pc_plus4), 
        .WriteData_out(ex_write_data), .alu_result_out(ex_alu_result),
        .pc_src_out(ex_pc_src), .pc_target_out(ex_pc_target),
        .branch_feedback_valid(branch_feedback_valid),
        .branch_feedback_pc(branch_feedback_pc),
        .branch_feedback_taken(branch_feedback_taken)
    );

    EX_MEM_reg ex_mem_reg (
        .clk(clk), .rst_n(rst_n),
        .flush(pipeline_flush),
        .RegWrite_in(ex_reg_write), .MemWrite_in(ex_mem_write), .ResultSrc_in(ex_result_src),
        .MemOp_in(ex_mem_op), .ALU_Result_in(ex_alu_result), .WriteData_in(ex_write_data), 
        .rd_in(ex_rd), .PCPlus4_in(ex_pc_plus4),
        .RegWrite_out(ex_mem_reg_write), .MemWrite_out(ex_mem_mem_write), .ResultSrc_out(ex_mem_result_src),
        .MemOp_out(ex_mem_mem_op), .ALU_Result_out(ex_mem_alu_result), .WriteData_out(ex_mem_write_data), 
        .rd_out(ex_mem_rd), .PCPlus4_out(ex_mem_pc_plus4)
    );

    // MEMORY STAGE
    assign mem_reg_write = ex_mem_reg_write;
    assign mem_result_src = ex_mem_result_src;
    assign mem_alu_result = ex_mem_alu_result;
    assign mem_rd = ex_mem_rd;
    assign mem_pc_plus4 = ex_mem_pc_plus4;

    MEM_WB_reg mem_wb_reg (
        .clk(clk), .rst_n(rst_n), .flush(pipeline_flush),
        .RegWrite_in(mem_reg_write), .ResultSrc_in(mem_result_src), .ReadData_in(mem_read_data),
        .ALU_Result_in(mem_alu_result), .rd_in(mem_rd), .PCPlus4_in(mem_pc_plus4),
        .RegWrite_out(mem_wb_reg_write), .ResultSrc_out(mem_wb_result_src), .ReadData_out(mem_wb_read_data),
        .ALU_Result_out(mem_wb_alu_result), .rd_out(mem_wb_rd), .PCPlus4_out(mem_wb_pc_plus4)
    );

    // WRITEBACK STAGE
    writeback writeback_stage (
        .RegWrite_in(mem_wb_reg_write), .ResultSrc_in(mem_wb_result_src),
        .ReadData_in(mem_wb_read_data), .ALU_Result_in(mem_wb_alu_result),
        .rd_in(mem_wb_rd), .PCPlus4_in(mem_wb_pc_plus4),
        .result_wb(wb_result), .RegWrite_wb(wb_reg_write_en), .rd_wb(wb_rd)
    );

    //----------------------------------------------------------------
    // Control Units
    //----------------------------------------------------------------

    Hazard_Detection_Unit hazard_unit (
        .ID_EX_RegWrite(id_ex_reg_write),
        .ID_EX_ResultSrc(id_ex_result_src),
        .ID_EX_rd(id_ex_rd),
        .IF_ID_rs1(id_rs1),
        .IF_ID_rs2(id_rs2),
        .PCWrite(pc_write_en),
        .IF_ID_Write(if_id_write_en),
        .ID_EX_Bubble(id_ex_bubble)
    );

    Forwarding_Unit forwarding_unit (
        .EX_MEM_RegWrite(ex_mem_reg_write),
        .MEM_WB_RegWrite(mem_wb_reg_write),
        .ID_EX_rs1(id_ex_rs1),
        .ID_EX_rs2(id_ex_rs2),
        .EX_MEM_rd(ex_mem_rd),
        .MEM_WB_rd(mem_wb_rd),
        .ForwardA(forward_a_ex),
        .ForwardB(forward_b_ex)
    );

    // Top-level outputs for debugging and grading
    assign PC_out_top = if_pc;
    assign Instruction_out_top = if_instr; // Use instruction from fetch
    assign DataMem0 = DMEM_inst.memory[0];
    assign DataMem1 = DMEM_inst.memory[1];
    assign DataMem2 = DMEM_inst.memory[2];

    assign Reg_inst_registers_0 = Reg_inst.registers[0];
    assign Reg_inst_registers_1 = Reg_inst.registers[1];
    assign Reg_inst_registers_2 = Reg_inst.registers[2];
    assign Reg_inst_registers_3 = Reg_inst.registers[3];
    assign Reg_inst_registers_4 = Reg_inst.registers[4];
    assign Reg_inst_registers_5 = Reg_inst.registers[5];
    assign Reg_inst_registers_6 = Reg_inst.registers[6];
    assign Reg_inst_registers_7 = Reg_inst.registers[7];
    assign Reg_inst_registers_8 = Reg_inst.registers[8];
    assign Reg_inst_registers_9 = Reg_inst.registers[9];
    assign Reg_inst_registers_10 = Reg_inst.registers[10];
    assign Reg_inst_registers_11 = Reg_inst.registers[11];
    assign Reg_inst_registers_12 = Reg_inst.registers[12];
    assign Reg_inst_registers_13 = Reg_inst.registers[13];
    assign Reg_inst_registers_14 = Reg_inst.registers[14];
    assign Reg_inst_registers_15 = Reg_inst.registers[15];
    assign Reg_inst_registers_16 = Reg_inst.registers[16];
    assign Reg_inst_registers_17 = Reg_inst.registers[17];
    assign Reg_inst_registers_18 = Reg_inst.registers[18];
    assign Reg_inst_registers_19 = Reg_inst.registers[19];
    assign Reg_inst_registers_20 = Reg_inst.registers[20];
    assign Reg_inst_registers_21 = Reg_inst.registers[21];
    assign Reg_inst_registers_22 = Reg_inst.registers[22];
    assign Reg_inst_registers_23 = Reg_inst.registers[23];
    assign Reg_inst_registers_24 = Reg_inst.registers[24];
    assign Reg_inst_registers_25 = Reg_inst.registers[25];
    assign Reg_inst_registers_26 = Reg_inst.registers[26];
    assign Reg_inst_registers_27 = Reg_inst.registers[27];
    assign Reg_inst_registers_28 = Reg_inst.registers[28];
    assign Reg_inst_registers_29 = Reg_inst.registers[29];
    assign Reg_inst_registers_30 = Reg_inst.registers[30];
    assign Reg_inst_registers_31 = Reg_inst.registers[31];

endmodule