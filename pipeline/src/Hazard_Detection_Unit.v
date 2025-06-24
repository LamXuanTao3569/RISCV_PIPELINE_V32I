module Hazard_Detection_Unit(
    // Inputs from ID/EX register to detect hazards
    input ID_EX_RegWrite,
    input [1:0] ID_EX_ResultSrc,
    input [4:0] ID_EX_rd,

    // Inputs from IF/ID register for dependency check
    input [4:0] IF_ID_rs1,
    input [4:0] IF_ID_rs2,

    // Outputs to control pipeline stalling
    output reg PCWrite,
    output reg IF_ID_Write,
    output reg ID_EX_Bubble
);

    wire load_use_hazard = (ID_EX_ResultSrc == 2'b01) && ID_EX_RegWrite && (ID_EX_rd != 5'b0) &&
                           ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2));

    always @(*) begin
        PCWrite = 1'b1;
        IF_ID_Write = 1'b1;
        ID_EX_Bubble = 1'b0;
        if (load_use_hazard) begin
            PCWrite = 1'b0;
            IF_ID_Write = 1'b0;
            ID_EX_Bubble = 1'b1;
        end
    end

endmodule 