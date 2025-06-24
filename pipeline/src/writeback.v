module writeback(
    // from MEM/WB reg
    input RegWrite_in,
    input [1:0] ResultSrc_in,
    input [31:0] ReadData_in,
    input [31:0] ALU_Result_in,
    input [4:0] rd_in,
    input [31:0] PCPlus4_in,

    // to Decode stage for register file write
    output reg [31:0] result_wb,

    // to forwarding unit and register file
    output reg RegWrite_wb,
    output reg [4:0] rd_wb
);

    // Simple combinational logic for result selection
    always @(*) begin
        if (ResultSrc_in == 2'b00) begin
            result_wb = ALU_Result_in;
        end else if (ResultSrc_in == 2'b01) begin
            result_wb = ReadData_in;
        end else if (ResultSrc_in == 2'b10) begin
            result_wb = PCPlus4_in;
        end else begin
            result_wb = 32'hx;
        end
    end

    // Pass through control signals
    always @(*) begin
        RegWrite_wb = RegWrite_in;
        rd_wb = rd_in;
    end

endmodule 