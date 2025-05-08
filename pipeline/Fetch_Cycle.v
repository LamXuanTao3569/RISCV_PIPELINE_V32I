module fetch_cycle(
    input clk, rst, PCSrcE, StallF, FlushD,
    input [31:0] PCTargetE, RD1_D, Imm_Ext_D,  // Thay ALU_ResultE bằng RD1_D, Imm_Ext_D
    input JumpE,
    output [31:0] InstrD, PCD, PCPlus4D
);

    wire [31:0] PC_F, PCF, PCPlus4F, InstrF;
    reg [31:0] InstrF_reg, PCF_reg, PCPlus4F_reg;

    wire [31:0] PCTarget_JALR;
    PC_Adder jalr_adder (
        .a(RD1_D), .b(Imm_Ext_D), .c(PCTarget_JALR)
    );

    wire [31:0] PC_Next;
    assign PC_Next = PCSrcE ? (JumpE ? PCTarget_JALR : PCTargetE) : PCPlus4F;

    Mux PC_MUX (
        .a(PCPlus4F),
        .b(PC_Next),
        .s(PCSrcE),
        .c(PC_F)
    );

    PC_Module Program_Counter (
        .clk(clk), .rst(rst), .PC(PCF), .PC_Next(PC_F), .StallF(StallF)
    );

    Instruction_Memory IMEM (
        .rst(rst), .A(PCF), .RD(InstrF)
    );

    PC_Adder PC_adder (
        .a(PCF), .b(32'h00000004), .c(PCPlus4F)
    );

    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            InstrF_reg <= 32'h00000000;
            PCF_reg <= 32'h00000000;
            PCPlus4F_reg <= 32'h00000000;
        end
        else if (StallF) begin
            InstrF_reg <= InstrF_reg;
            PCF_reg <= PCF_reg;
            PCPlus4F_reg <= PCPlus4F_reg;
        end
        else begin
            InstrF_reg <= FlushD ? 32'h00000000 : InstrF;
            PCF_reg <= FlushD ? 32'h00000000 : PCF;
            PCPlus4F_reg <= FlushD ? 32'h00000000 : PCPlus4F;
        end
    end

    assign InstrD = (rst == 1'b0) ? 32'h00000000 : InstrF_reg;
    assign PCD = (rst == 1'b0) ? 32'h00000000 : PCF_reg;
    assign PCPlus4D = (rst == 1'b0) ? 32'h00000000 : PCPlus4F_reg;
endmodule