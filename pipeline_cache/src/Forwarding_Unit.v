module Forwarding_Unit(
    input EX_MEM_RegWrite,
    input MEM_WB_RegWrite,
    input ID_EX_MemWrite,
    input [4:0] ID_EX_rs1,
    input [4:0] ID_EX_rs2,
    input [4:0] EX_MEM_rd,
    input [4:0] MEM_WB_rd,
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

    always @(*) begin
        // ForwardA Logic - prioritize EX/MEM hazard
        ForwardA = 2'b00; // Default
        if (MEM_WB_RegWrite && MEM_WB_rd != 0 && MEM_WB_rd == ID_EX_rs1) begin
            ForwardA = 2'b10;
        end
        if (EX_MEM_RegWrite && EX_MEM_rd != 0 && EX_MEM_rd == ID_EX_rs1) begin
            ForwardA = 2'b01;
        end

        // ForwardB Logic - prioritize EX/MEM hazard
        ForwardB = 2'b00; // Default
        if (MEM_WB_RegWrite && MEM_WB_rd != 0 && MEM_WB_rd == ID_EX_rs2) begin
           ForwardB = 2'b10;
        end
        if (EX_MEM_RegWrite && EX_MEM_rd != 0 && EX_MEM_rd == ID_EX_rs2) begin
            ForwardB = 2'b01;
        end
    end

endmodule 