module Pipeline_top(clk, rst);

    // Declaration of I/O
    input clk, rst;

    // Declaration of Interim Wires
    wire PCSrcE, RegWriteW, RegWriteE, ALUSrcE, MemWriteE, BranchE, RegWriteM, MemWriteM, Jump;
	 wire [1:0] ResultSrcE, ResultSrcM, ResultSrcW; // Mở rộng ResultSrc
    wire [2:0] ALUControlE;
    wire [4:0] RD_E, RD_M, RDW, RS1D, RS2D;
    wire [31:0] PCTargetE, InstrD, PCD, PCPlus4D, ResultW, RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E, PCPlus4M, WriteDataM, ALU_ResultM;
    wire [31:0] PCPlus4W, ALU_ResultW, ReadDataW;
    wire [4:0] RS1_E, RS2_E;
    wire [1:0] ForwardB_E, ForwardA_E;
	 wire StallF, StallD, FlushD, FlushE; // Thêm tín hiệu hazard
    

    // Module Initiation
    // Fetch Stage
    fetch_cycle Fetch (
                        .clk(clk), 
                        .rst(rst), 
                        .PCSrcE(PCSrcE), 
                        .PCTargetE(PCTargetE), 
                        .InstrD(InstrD), 
                        .PCD(PCD), 
                        .PCPlus4D(PCPlus4D),
								.StallF(StallF), // Thêm StallF
								.FlushD(FlushD)  // Thêm FlushD
                    );

    // Decode Stage
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
								.Jump(Jump), // Thêm Jump
                        .ALUControlE(ALUControlE), 
                        .RD1_E(RD1_E), 
                        .RD2_E(RD2_E), 
                        .Imm_Ext_E(Imm_Ext_E), 
                        .RD_E(RD_E), 
                        .PCE(PCE), 
                        .PCPlus4E(PCPlus4E),
                        .RS1_E(RS1_E),
                        .RS2_E(RS2_E),
								.StallD(StallD), // Thêm StallD
								.FlushD(FlushD)  // Thêm FlushD
                    );

    // Execute Stage
    execute_cycle Execute (
                        .clk(clk), 
                        .rst(rst), 
                        .RegWriteE(RegWriteE), 
                        .ALUSrcE(ALUSrcE), 
                        .MemWriteE(MemWriteE), 
                        .ResultSrcE(ResultSrcE), 
                        .BranchE(BranchE), 
								.Jump(Jump), // Thêm Jump
                        .ALUControlE(ALUControlE), 
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
                        .RD_M(RD_M), 
                        .PCPlus4M(PCPlus4M), 
                        .WriteDataM(WriteDataM), 
                        .ALU_ResultM(ALU_ResultM),
                        .ResultW(ResultW),
                        .ForwardA_E(ForwardA_E),
                        .ForwardB_E(ForwardB_E),
								.FlushE(FlushE) // Thêm FlushE
                    );
    
    // Memory Stage
    memory_cycle Memory (
                        .clk(clk), 
                        .rst(rst), 
                        .RegWriteM(RegWriteM), 
                        .MemWriteM(MemWriteM), 
                        .ResultSrcM(ResultSrcM), 
                        .RD_M(RD_M), 
                        .PCPlus4M(PCPlus4M), 
                        .WriteDataM(WriteDataM), 
                        .ALU_ResultM(ALU_ResultM), 
                        .RegWriteW(RegWriteW), 
                        .ResultSrcW(ResultSrcW), 
                        .RD_W(RDW), 
                        .PCPlus4W(PCPlus4W), 
                        .ALU_ResultW(ALU_ResultW), 
                        .ReadDataW(ReadDataW)
                    );

    // Write Back Stage
    writeback_cycle WriteBack (
                        .clk(clk), 
                        .rst(rst), 
                        .ResultSrcW(ResultSrcW), 
                        .PCPlus4W(PCPlus4W), 
                        .ALU_ResultW(ALU_ResultW), 
                        .ReadDataW(ReadDataW), 
                        .ResultW(ResultW)
                    );

    // Hazard Unit
    hazard_unit Forwarding_block (
                        .rst(rst), 
                        .RegWriteM(RegWriteM), 
                        .RegWriteW(RegWriteW), 
                        .RD_M(RD_M), 
                        .RD_W(RDW), 
                        .Rs1_E(RS1_E), 
                        .Rs2_E(RS2_E),
								.RS1D(InstrD[19:15]), // Thêm RS1D
								.RS2D(InstrD[24:20]), // Thêm RS2D
                        .RDE(RD_E), 
							   .ResultSrcE_0(ResultSrcE[0]),
							   .PCSrcE(PCSrcE),
							   .ForwardAE(ForwardAE), 
							   .ForwardBE(ForwardBE),
							   .StallF(StallF), 
							   .StallD(StallD), 
							   .FlushD(FlushD), 
							   .FlushE(FlushE)
                        );
endmodule
