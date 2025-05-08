module writeback_cycle(
    input clk, rst,
    input RegWriteW_in,
    input [1:0] ResultSrcW, 
    input [31:0] PCPlus4W, ALU_ResultW, ReadDataW,
    input [4:0] RD_W_in,
    output reg [31:0] ResultW,
    output reg RegWriteW,
    output reg [4:0] RD_W
);
    wire [31:0] ResultW_mux;  // Thêm wire để nhận giá trị từ Mux_3_by_1

    Mux_3_by_1 result_mux ( 
        .a(ALU_ResultW),
        .b(ReadDataW),
        .c(PCPlus4W),
        .s(ResultSrcW),
        .d(ResultW_mux)  // Kết nối cổng d với wire
    );

    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            ResultW <= 32'h0;
            RegWriteW <= 1'b0;
            RD_W <= 5'h0;
        end
        else begin
            ResultW <= ResultW_mux;  // Gán giá trị từ wire cho ResultW
            RegWriteW <= RegWriteW_in;
            RD_W <= RD_W_in;
        end
    end
endmodule