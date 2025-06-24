module EX_MEM_reg (
    input clk, rst_n,

    // Control signals from Execute
    input RegWrite_in,
    input MemWrite_in,
    input [1:0] ResultSrc_in,
    input [1:0] MemOp_in,

    // Data from Execute
    input [31:0] ALU_Result_in,
    input [31:0] WriteData_in, // Data to be written to memory for store
    input [4:0] rd_in,
    input [31:0] PCPlus4_in,
    input flush,
    input [2:0] funct3_in,

    // Outputs to Memory
    output reg RegWrite_out,
    output reg MemWrite_out,
    output reg [1:0] ResultSrc_out,
    output reg [1:0] MemOp_out,
    output reg [31:0] ALU_Result_out,
    output reg [31:0] WriteData_out,
    output reg [4:0] rd_out,
    output reg [31:0] PCPlus4_out,
    output reg [2:0] funct3_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            RegWrite_out <= 1'b0;
            MemWrite_out <= 1'b0;
            ResultSrc_out <= 2'b0;
            MemOp_out <= 2'b0;
            ALU_Result_out <= 32'b0;
            WriteData_out <= 32'b0;
            rd_out <= 5'b0;
            PCPlus4_out <= 32'b0;
            funct3_out <= 3'b0;
        end else begin
            RegWrite_out <= RegWrite_in;
            MemWrite_out <= MemWrite_in;
            ResultSrc_out <= ResultSrc_in;
            MemOp_out <= MemOp_in;
            ALU_Result_out <= ALU_Result_in;
            WriteData_out <= WriteData_in;
            rd_out <= rd_in;
            PCPlus4_out <= PCPlus4_in;
            funct3_out <= funct3_in;
        end
    end
endmodule 