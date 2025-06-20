module Forwarding_Unit(
    input EX_MEM_RegWrite,
    input MEM_WB_RegWrite,
    input [4:0] ID_EX_rs1,
    input [4:0] ID_EX_rs2,
    input [4:0] EX_MEM_rd,
    input [4:0] MEM_WB_rd,
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

    always @(*) begin
        // Forwarding for ALU operand A
        if (EX_MEM_RegWrite && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs1)) begin
            ForwardA = 2'b01; // Forward from EX/MEM
        end else if (MEM_WB_RegWrite && (MEM_WB_rd != 5'b0) && (MEM_WB_rd == ID_EX_rs1)) begin
            ForwardA = 2'b10; // Forward from MEM/WB
        end else begin
            ForwardA = 2'b00; // No forwarding
        end

        // Forwarding for ALU operand B
        if (EX_MEM_RegWrite && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs2)) begin
            ForwardB = 2'b01; // Forward from EX/MEM
        end else if (MEM_WB_RegWrite && (MEM_WB_rd != 5'b0) && (MEM_WB_rd == ID_EX_rs2)) begin
            ForwardB = 2'b10; // Forward from MEM/WB
        end else begin
            ForwardB = 2'b00; // No forwarding
        end
    end

endmodule 