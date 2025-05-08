module Pipeline_top(
    input clk, rst
);
// Internal wires for inter-module connections
wire [31:0] InstrD, RD1_E, RD2_E, ALU_ResultM, ReadDataW, ResultW;
wire RegWriteE, MemWriteE, PCSrcE;
wire [1:0] ForwardA_E, ForwardB_E;

    wire RegWriteW, RegWriteM, ALUSrcE, BranchE, JumpE;
    wire [1:0] ResultSrcE, ResultSrcM, ResultSrcW;
    wire [3:0] ALUControlE;
    wire [2:0] funct3E;
    wire [4:0] RD_E, RD_M, RDW, RS1D, RS2D;
    wire [31:0] PCTargetE, PCD, PCPlus4D, Imm_Ext_E, PCE, PCPlus4E, PCPlus4M, WriteDataM, RD1_D, Imm_Ext_D;
    wire [4:0] RS1_E, RS2_E;
    wire [1:0] MemOpM;
    wire StallF, StallD, FlushD, FlushE, FlushM;
    wire [31:0] PCPlus4W, ALU_ResultW;

    // Memory stage outputs
    wire RegWriteM_out;
    wire [4:0] RD_M_out;

    fetch_cycle Fetch (
        .clk(clk),
        .rst(rst),
        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE),
        .RD1_D(RD1_D),
        .Imm_Ext_D(Imm_Ext_D),
        .JumpE(JumpE),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .StallF(StallF),
        .FlushD(FlushD)
    );

    decode_cycle Decode (
        .clk(clk),
        .rst(rst),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .RegWriteW(RegWriteW),
        .RDW(RDW),
        .ResultW(ResultW),
        .RegWriteE(RegWriteE),
        .ALUSrcE(ALUSrcE),
        .MemWriteE(MemWriteE),
        .ResultSrcE(ResultSrcE),
        .BranchE(BranchE),
        .JumpE(JumpE),
        .ALUControlE(ALUControlE),
        .funct3E(funct3E),
        .RD1_E(RD1_E),
        .RD2_E(RD2_E),
        .Imm_Ext_E(Imm_Ext_E),
        .RD1_D(RD1_D),
        .Imm_Ext_D(Imm_Ext_D),
        .RD_E(RD_E),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),
        .RS1_E(RS1_E),
        .RS2_E(RS2_E),
        .StallD(StallD),
        .FlushD(FlushD)
    );

    execute_cycle Execute (
        .clk(clk),
        .rst(rst),
        .RegWriteE(RegWriteE),
        .ALUSrcE(ALUSrcE),
        .MemWriteE(MemWriteE),
        .ResultSrcE(ResultSrcE),
        .BranchE(BranchE),
        .JumpE(JumpE),
        .ALUControlE(ALUControlE),
        .funct3E(funct3E),
        .RD1_E(RD1_E),
        .RD2_E(RD2_E),
        .Imm_Ext_E(Imm_Ext_E),
        .RD_E(RD_E),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),
        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .ResultSrcM(ResultSrcM),
        .MemOpM(MemOpM),
        .RD_M(RD_M),
        .PCPlus4M(PCPlus4M),
        .WriteDataM(WriteDataM),
        .ALU_ResultM(ALU_ResultM),
        .ResultW(ResultW),
        .ForwardA_E(ForwardA_E),
        .ForwardB_E(ForwardB_E),
        .FlushE(FlushE),
        .RS1_E(RS1_E),
        .RS2_E(RS2_E)
    );

    memory_cycle Memory (
        .clk(clk),
        .rst(rst),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .ResultSrcM(ResultSrcM),
        .MemOpM(MemOpM),
        .RD_M(RD_M),
        .PCPlus4M(PCPlus4M),
        .WriteDataM(WriteDataM),
        .ALU_ResultM(ALU_ResultM),
        .FlushM(FlushM),
        .RegWriteW(RegWriteM_out),
        .ResultSrcW(ResultSrcW),
        .RD_W(RD_M_out),
        .PCPlus4W(PCPlus4W),
        .ALU_ResultW(ALU_ResultW),
        .ReadDataW(ReadDataW)
    );

    writeback_cycle WriteBack (
        .clk(clk),
        .rst(rst),
        .RegWriteW_in(RegWriteM_out),
        .ResultSrcW(ResultSrcW),
        .PCPlus4W(PCPlus4W),
        .ALU_ResultW(ALU_ResultW),
        .ReadDataW(ReadDataW),
        .RD_W_in(RD_M_out),
        .ResultW(ResultW),
        .RegWriteW(RegWriteW),
        .RD_W(RDW)
    );

    hazard_unit Forwarding_block (
        .clk(clk),
        .rst(rst),
        .RegWriteE_in(RegWriteE),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .RD_M(RD_M),
        .RD_W(RDW),
        .Rs1_E(RS1_E),
        .Rs2_E(RS2_E),
        .RS1D(InstrD[19:15]),
        .RS2D(InstrD[24:20]),
        .RDE(RD_E),
        .ResultSrcE_0(ResultSrcE[0]),
        .PCSrcE(PCSrcE),
        .ForwardA_E(ForwardA_E),
        .ForwardB_E(ForwardB_E),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE)
    );
endmodule