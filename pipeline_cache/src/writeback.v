module writeback(
    // from MEM/WB reg
    input RegWrite_in,
    input [1:0] ResultSrc_in,
    input [31:0] ReadData_in,
    input [31:0] ALU_Result_in,
    input [4:0] rd_in,
    input [31:0] PCPlus4_in,

    // to Decode stage for register file write
    output [31:0] result_wb,

    // to forwarding unit and register file
    output RegWrite_wb,
    output [4:0] rd_wb
);
    // Pass through control signal and destination register
    assign RegWrite_wb = RegWrite_in;
    assign rd_wb = rd_in;

    // Mux for the result to be written back
    assign result_wb = (ResultSrc_in == 2'b10) ? PCPlus4_in :
                       (ResultSrc_in == 2'b01) ? ReadData_in :
                       ALU_Result_in; // Default to ALU result

endmodule 