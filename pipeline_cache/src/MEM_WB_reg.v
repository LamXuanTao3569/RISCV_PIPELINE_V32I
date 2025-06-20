module MEM_WB_reg (
    input clk, rst,

    // Control signals from Memory
    input RegWrite_in,
    input [1:0] ResultSrc_in,

    // Data from Memory
    input [31:0] ReadData_in,
    input [31:0] ALU_Result_in,
    input [4:0] rd_in,
    input [31:0] PCPlus4_in,

    // Outputs to WriteBack
    output reg RegWrite_out,
    output reg [1:0] ResultSrc_out,
    output reg [31:0] ReadData_out,
    output reg [31:0] ALU_Result_out,
    output reg [4:0] rd_out,
    output reg [31:0] PCPlus4_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RegWrite_out <= 1'b0;
            ResultSrc_out <= 2'b0;
            ReadData_out <= 32'b0;
            ALU_Result_out <= 32'b0;
            rd_out <= 5'b0;
            PCPlus4_out <= 32'b0;
        end else begin
            RegWrite_out <= RegWrite_in;
            ResultSrc_out <= ResultSrc_in;
            ReadData_out <= ReadData_in;
            ALU_Result_out <= ALU_Result_in;
            rd_out <= rd_in;
            PCPlus4_out <= PCPlus4_in;
        end
    end
endmodule 