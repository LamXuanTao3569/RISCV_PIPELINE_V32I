module Hazard_Detection_Unit(
    input ID_EX_MemRead,
    input BranchTaken, // From EX stage, indicates a branch is taken
    input [4:0] ID_EX_rd,
    input [4:0] IF_ID_rs1,
    input [4:0] IF_ID_rs2,
    output reg PCWrite,
    output reg IF_ID_Write,
    output reg ID_EX_Bubble,
    output reg IF_ID_Flush
);

    wire load_use_hazard;
    assign load_use_hazard = ID_EX_MemRead && ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2));

    always @(*) begin
        PCWrite = 1;
        IF_ID_Write = 1;
        ID_EX_Bubble = 0;
        IF_ID_Flush = 0;

        if (load_use_hazard) begin
            PCWrite = 0;
            IF_ID_Write = 0;
            ID_EX_Bubble = 1;
        end

        if (BranchTaken) begin
            IF_ID_Flush = 1;
        end
    end

endmodule 