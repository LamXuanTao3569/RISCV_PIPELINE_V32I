module writeback_cycle(clk, rst, ResultSrcW, PCPlus4W, ALU_ResultW, ReadDataW, ResultW);
    // Declaration of IOs
    input clk, rst;
    input [1:0] ResultSrcW; // Mở rộng thành [1:0]
    input [31:0] PCPlus4W, ALU_ResultW, ReadDataW;
    output [31:0] ResultW;

    // Declaration of Module
    Mux_3_by_1 result_mux ( // Thay Mux bằng Mux_3_by_1
        .a(ALU_ResultW),    // 00: ALU result
        .b(ReadDataW),      // 01: Memory data
        .c(PCPlus4W),       // 10: PC+4 (for JAL, JALR)
        .s(ResultSrcW),
        .d(ResultW)
    );
endmodule