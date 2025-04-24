module execute_cycle(clk, rst, RegWriteE, ALUSrcE, MemWriteE, ResultSrcE, BranchE, Jump, ALUControlE, RD1_E, RD2_E, 
    Imm_Ext_E, RD_E, PCE, PCPlus4E, ForwardA_E, ForwardB_E, RS1_E, RS2_E, ResultW, RegWriteM, MemWriteM, ResultSrcM, 
    RD_M, PCPlus4M, WriteDataM, ALU_ResultM, PCSrcE, PCTargetE, FlushE);

    // Declaration of I/Os
    input clk, rst, RegWriteE, ALUSrcE, MemWriteE, BranchE, Jump, FlushE;
    input [1:0] ResultSrcE;
    input [2:0] ALUControlE;
    input [31:0] RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E, ResultW;  // Thêm ResultW
    input [4:0] RD_E;
    input [4:0] RS1_E, RS2_E;  // Giữ nguyên RS1_E, RS2_E là input
    input [1:0] ForwardA_E, ForwardB_E;  // Đổi tên ForwardAE, ForwardBE thành ForwardA_E, ForwardB_E

    output PCSrcE, RegWriteM, MemWriteM;
    output [1:0] ResultSrcM;
    output [4:0] RD_M;
    output [31:0] PCPlus4M, WriteDataM, ALU_ResultM, PCTargetE;

    // Declaration of Interim Wires
    wire ZeroE, OverFlowE, CarryE, NegativeE;
    wire [31:0] SrcA_E, SrcB_E, ALU_ResultE;
    wire [31:0] WriteDataE;

    // Declaration of Interim Registers
    reg RegWriteE_r, MemWriteE_r;
    reg [1:0] ResultSrcE_r;
    reg [31:0] ALU_ResultE_r, WriteDataE_r;
    reg [4:0] RD_E_r;
    reg [31:0] PCE_r, PCPlus4E_r;

    // Declaration of Module Initiation
    Mux_3_by_1 SrcA_Mux (
        .a(RD1_E),
        .b(ResultW),
        .c(ALU_ResultM),
        .s(ForwardA_E),  // Đổi tên ForwardAE thành ForwardA_E
        .d(SrcA_E)
    );

    Mux_3_by_1 SrcB_Mux (
        .a(RD2_E),
        .b(ResultW),
        .c(ALU_ResultM),
        .s(ForwardB_E),  // Đổi tên ForwardBE thành ForwardB_E
        .d(WriteDataE)
    );

    Mux SrcB_Final_Mux (
        .a(WriteDataE),
        .b(Imm_Ext_E),
        .s(ALUSrcE),
        .c(SrcB_E)
    );

    ALU ALU (
        .A(SrcA_E),
        .B(SrcB_E),
        .ALUControl(ALUControlE),
        .Result(ALU_ResultE),
        .OverFlow(OverFlowE),
        .Carry(CarryE),
        .Zero(ZeroE),
        .Negative(NegativeE)
    );

    PC_Adder PC_Plus_Imm (
        .a(PCE),
        .b(Imm_Ext_E),
        .c(PCTargetE)
    );

    PC_Adder PC_Plus_4 (
        .a(PCE),
        .b(32'h00000004),
        .c(PCPlus_E)
    );

    assign PCSrcE = (BranchE & ZeroE) | (Jump === 1'bz ? 1'b0 : Jump);

    // Declaring Register Logic
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            RegWriteE_r <= 1'b0;
            MemWriteE_r <= 1'b0;
            ResultSrcE_r <= 2'b00;
            ALU_ResultE_r <= 32'h00000000;
            WriteDataE_r <= 32'h00000000;
            RD_E_r <= 5'h00;
            PCE_r <= 32'h00000000;
            PCPlus4E_r <= 32'h00000000;
        end
        else begin
            RegWriteE_r <= FlushE ? 1'b0 : RegWriteE;
            MemWriteE_r <= FlushE ? 1'b0 : MemWriteE;
            ResultSrcE_r <= FlushE ? 2'b00 : ResultSrcE;
            ALU_ResultE_r <= FlushE ? 32'h00000000 : ALU_ResultE;
            WriteDataE_r <= FlushE ? 32'h00000000 : WriteDataE;
            RD_E_r <= FlushE ? 5'h00 : RD_E;
            PCE_r <= FlushE ? 32'h00000000 : PCE;
            PCPlus4E_r <= FlushE ? 32'h00000000 : PCPlus4E;
        end
    end

    // Declaration of Output Assignments
    assign RegWriteM = RegWriteE_r;
    assign MemWriteM = MemWriteE_r;
    assign ResultSrcM = ResultSrcE_r;
    assign ALU_ResultM = ALU_ResultE_r;
    assign WriteDataM = WriteDataE_r;
    assign RD_M = RD_E_r;
    assign PCPlus4M = PCPlus4E_r;
endmodule