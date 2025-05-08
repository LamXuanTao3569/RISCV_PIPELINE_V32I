module execute_cycle(
    input clk, rst, RegWriteE, ALUSrcE, MemWriteE, BranchE, JumpE, FlushE,
    input [1:0] ResultSrcE,
    input [3:0] ALUControlE,
    input [2:0] funct3E,
    input [31:0] RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E, ResultW,
    input [4:0] RD_E, RS1_E, RS2_E,
    input [1:0] ForwardA_E, ForwardB_E,
    output PCSrcE, RegWriteM, MemWriteM,
    output [1:0] ResultSrcM, MemOpM,
    output [4:0] RD_M,
    output [31:0] PCPlus4M, WriteDataM, ALU_ResultM, PCTargetE
);

    wire ZeroE;  // Chỉ giữ ZeroE
    wire [31:0] SrcA_E, SrcB_E, ALU_ResultE, WriteDataE;
    reg RegWriteE_r, MemWriteE_r;
    reg [1:0] ResultSrcE_r, MemOpE_r;
    reg [31:0] ALU_ResultE_r, WriteDataE_r;
    reg [4:0] RD_E_r;
    reg [31:0] PCPlus4E_r;

    Mux_3_by_1 SrcA_Mux (
        .a(RD1_E), .b(ResultW), .c(ALU_ResultM), .s(ForwardA_E), .d(SrcA_E)
    );

    Mux_3_by_1 SrcB_Mux (
        .a(RD2_E), .b(ResultW), .c(ALU_ResultM), .s(ForwardB_E), .d(WriteDataE)
    );

    Mux SrcB_Final_Mux (
        .a(WriteDataE), .b(Imm_Ext_E), .s(ALUSrcE), .c(SrcB_E)
    );

    ALU ALU (
        .A(SrcA_E), .B(SrcB_E), .ALUControl(ALUControlE), .Result(ALU_ResultE),
        .Zero(ZeroE)
    );

    PC_Adder PC_Plus_Imm (
        .a(PCE), .b(Imm_Ext_E), .c(PCTargetE)
    );

    reg [1:0] MemOpE;
    always @(*) begin
        case (funct3E)
            3'b000: MemOpE = 2'b00; // lb, lbu, sb
            3'b001: MemOpE = 2'b01; // lh, lhu, sh
            3'b010: MemOpE = 2'b10; // lw, sw
            3'b100: MemOpE = 2'b11; // lbu
            3'b101: MemOpE = 2'b11; // lhu
            default: MemOpE = 2'b10;
        endcase
    end

    reg BranchTaken;
    always @(*) begin
        case (funct3E)
            3'b000: BranchTaken = ZeroE; // beq
            3'b001: BranchTaken = ~ZeroE; // bne
            3'b100: BranchTaken = ALU_ResultE[0]; // blt (slt)
            3'b101: BranchTaken = ~ALU_ResultE[0]; // bge (slt)
            3'b110: BranchTaken = ALU_ResultE[0]; // bltu (sltu)
            3'b111: BranchTaken = ~ALU_ResultE[0]; // bgeu (sltu)
            default: BranchTaken = 1'b0;
        endcase
    end

    assign PCSrcE = (BranchE && BranchTaken) || JumpE;

    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            RegWriteE_r <= 1'b0;
            MemWriteE_r <= 1'b0;
            ResultSrcE_r <= 2'b00;
            MemOpE_r <= 2'b00;
            ALU_ResultE_r <= 32'h00000000;
            WriteDataE_r <= 32'h00000000;
            RD_E_r <= 5'h00;
            PCPlus4E_r <= 32'h00000000;
        end
        else begin
            RegWriteE_r <= FlushE ? 1'b0 : RegWriteE;
            MemWriteE_r <= FlushE ? 1'b0 : MemWriteE;
            ResultSrcE_r <= FlushE ? 2'b00 : ResultSrcE;
            MemOpE_r <= FlushE ? 2'b00 : MemOpE;
            ALU_ResultE_r <= FlushE ? 32'h00000000 : ALU_ResultE;
            WriteDataE_r <= FlushE ? 32'h00000000 : WriteDataE;
            RD_E_r <= FlushE ? 5'h00 : RD_E;
            PCPlus4E_r <= FlushE ? 32'h00000000 : PCPlus4E;
        end
    end

    assign RegWriteM = RegWriteE_r;
    assign MemWriteM = MemWriteE_r;
    assign ResultSrcM = ResultSrcE_r;
    assign MemOpM = MemOpE_r;
    assign ALU_ResultM = ALU_ResultE_r;
    assign WriteDataM = WriteDataE_r;
    assign RD_M = RD_E_r;
    assign PCPlus4M = PCPlus4E_r;
endmodule