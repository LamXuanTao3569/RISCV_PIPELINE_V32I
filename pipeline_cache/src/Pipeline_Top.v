module RISCV_Single_Cycle (
    input clk,
    input rst_n,
    output [31:0] PC_out_top,
    output [31:0] InstrF,
    output [31:0] DataMem0,
    output [31:0] DataMem1,
    output [31:0] DataMem2,
    output [31:0] Reg_inst_registers [0:31],
    output [31:0] DMEM_inst_memory [0:1023],
    output [31:0] IMEM_inst_memory [0:1023],
    output [31:0] Instruction_out_top
);

    //----------------------------------------------------------------
    // Wires Declaration
    //----------------------------------------------------------------

    // Hazard Unit -> Control signals
    wire pc_write_en, if_id_write_en, id_ex_bubble;
    wire pipeline_flush; // Combined flush signal
    
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

    // ID/EX Register -> Execute Stage
    wire id_ex_reg_write, id_ex_alu_src, id_ex_mem_write, id_ex_branch, id_ex_jump;
    wire [1:0] id_ex_result_src, id_ex_mem_op;
    wire [3:0] id_ex_alu_control;
    wire [2:0] id_ex_funct3;
    wire [31:0] id_ex_pc, id_ex_pc_plus4, id_ex_rd1, id_ex_rd2, id_ex_imm_ext;
    wire [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd;

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

    // Flush pipeline on taken branches and for the first few cycles on startup
    reg [2:0] startup_counter = 3'd0;
    wire startup_flush;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            startup_counter <= 3'd0;
        end else if (startup_counter < 3'd4) begin
            startup_counter <= startup_counter + 1;
        end
    end
    assign startup_flush = (startup_counter < 3'd4);
    assign pipeline_flush = ex_pc_src || startup_flush;

    //----------------------------------------------------------------
    // Instruction and Data Memories
    //----------------------------------------------------------------
    Instruction_Memory IMEM_inst (
        .A(if_pc),
        .RD(if_instr)
    );
    assign IMEM_inst_memory = IMEM_inst.memory;

    Data_Memory DMEM_inst (
        .clk(clk),
        .rst(rst_n),
        .WE(ex_mem_mem_write),
        .MemOp(ex_mem_mem_op),
        .A(ex_mem_alu_result),
        .WD(ex_mem_write_data),
        .RD(mem_read_data)
    );
    assign DMEM_inst_memory = DMEM_inst.memory;

    //----------------------------------------------------------------
    // Pipeline Stages
    //----------------------------------------------------------------

    // FETCH STAGE
    fetch fetch_stage (
        .clk(clk), .rst_n(rst_n),
        .pc_write_en(pc_write_en),
        .pc_src(exception ? 1'b1 : ex_pc_src),
        .pc_target(exception ? 32'h00000080 : ex_pc_target),
        .if_instr(if_instr),
        .pc_out(if_pc),
        .pc_plus4_out(if_pc_plus4),
        .branch_predict_out(fetch_branch_predict),
        .predictor_update(branch_feedback_valid),
        .predictor_update_index(branch_feedback_pc[7:2]),
        .predictor_outcome(branch_feedback_taken)
    );

    IF_ID_reg if_id_reg (
        .clk(clk), .rst_n(rst_n),
        .if_id_write(if_id_write_en),
        .if_id_flush(pipeline_flush),
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
    wire rf_WE3;
    Register_File Reg_inst (
        .clk(clk),
        .rst_n(rst_n),
        .WE3(rf_WE3),
        .A1(rf_A1),
        .A2(rf_A2),
        .A3(rf_A3),
        .WD3(rf_WD3),
        .RD1(rf_RD1),
        .RD2(rf_RD2)
    );

    // DECODE STAGE
    decode decode_stage (
        .clk(clk), .rst_n(rst_n),
        .instr_in(if_id_instr),
        .reg_write_en_wb(wb_reg_write_en),
        .rd_wb(wb_rd),
        .result_wb(wb_result),
        .rd1_in(rf_RD1),
        .rd2_in(rf_RD2),
        .A1(rf_A1),
        .A2(rf_A2),
        .A3(rf_A3),
        .WD3(rf_WD3),
        .WE3(rf_WE3),
        .RegWrite_out(id_reg_write), .ALUSrc_out(id_alu_src), .MemWrite_out(id_mem_write),
        .ResultSrc_out(id_result_src), .Branch_out(id_branch), .Jump_out(id_jump),
        .ALUControl_out(id_alu_control), .MemOp_out(id_mem_op), .funct3_out(id_funct3),
        .rd1_out(id_rd1), .rd2_out(id_rd2), .imm_ext_out(id_imm_ext),
        .rs1_out(id_rs1), .rs2_out(id_rs2), .rd_out(id_rd),
        .exception_out(exception)
    );

    ID_EX_reg id_ex_reg (
        .clk(clk), .rst_n(rst_n),
        .bubble(id_ex_bubble), .flush(pipeline_flush),
        .RegWrite_in(id_reg_write), .ALUSrc_in(id_alu_src), .MemWrite_in(id_mem_write),
        .ResultSrc_in(id_result_src), .Branch_in(id_branch), .Jump_in(id_jump),
        .ALUControl_in(id_alu_control), .MemOp_in(id_mem_op), .funct3_in(id_funct3),
        .PC_in(if_id_pc), .PCPlus4_in(if_id_pc_plus4), .RD1_in(id_rd1), .RD2_in(id_rd2),
        .Imm_Ext_in(id_imm_ext), .rs1_in(id_rs1), .rs2_in(id_rs2), .rd_in(id_rd),
        .RegWrite_out(id_ex_reg_write), .ALUSrc_out(id_ex_alu_src), .MemWrite_out(id_ex_mem_write),
        .ResultSrc_out(id_ex_result_src), .Branch_out(id_ex_branch), .Jump_out(id_ex_jump),
        .ALUControl_out(id_ex_alu_control), .MemOp_out(id_ex_mem_op), .funct3_out(id_ex_funct3),
        .PC_out(id_ex_pc), .PCPlus4_out(id_ex_pc_plus4), .RD1_out(id_ex_rd1), .RD2_out(id_ex_rd2),
        .Imm_Ext_out(id_ex_imm_ext), .rs1_out(id_ex_rs1), .rs2_out(id_ex_rs2), .rd_out(id_ex_rd)
    );
    
    // EXECUTE STAGE
    execute execute_stage (
        .RegWrite_in(id_ex_reg_write), .ALUSrc_in(id_ex_alu_src), .MemWrite_in(id_ex_mem_write),
        .Branch_in(id_ex_branch), .Jump_in(id_ex_jump), .ResultSrc_in(id_ex_result_src),
        .MemOp_in(id_ex_mem_op), .ALUControl_in(id_ex_alu_control), .funct3_in(id_ex_funct3),
        .RD1_in(id_ex_rd1), .RD2_in(id_ex_rd2), .Imm_Ext_in(id_ex_imm_ext), .PC_in(id_ex_pc),
        .PCPlus4_in(id_ex_pc_plus4), .rd_in(id_ex_rd),
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
        .rd_in(mem_wb_rd), .PCPlus4_in(mem_pc_plus4),
        .result_wb(wb_result), .RegWrite_wb(wb_reg_write_en), .rd_wb(wb_rd)
    );

    //----------------------------------------------------------------
    // Control Units
    //----------------------------------------------------------------

    Hazard_Detection_Unit hazard_unit (
        .ID_EX_MemRead(id_ex_result_src == 2'b01), // Load instruction
        .BranchTaken(ex_pc_src),
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
        .ID_EX_MemWrite(id_ex_mem_write),
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

    assign Reg_inst_registers = Reg_inst.registers;

endmodule