module regfile (
    input  wire        clk,
    input  wire        we,
    input  wire [4:0]  rs1, rs2, rd,
    input  wire [31:0] write_data,
    output wire [31:0] read_data1, read_data2
);
    reg [31:0] regs [0:31];
    initial regs[0] = 32'h0;

    always @(posedge clk) begin
        if (we && rd != 0) regs[rd] <= write_data;
    end

    assign read_data1 = (rs1 == 0) ? 32'h0 : regs[rs1];
    assign read_data2 = (rs2 == 0) ? 32'h0 : regs[rs2];
endmodule