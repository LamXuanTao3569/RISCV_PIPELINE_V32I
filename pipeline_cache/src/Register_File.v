module Register_File(
    input clk, rst_n, WE3,
    input [4:0] A1, A2, A3,
    input [31:0] WD3,
    output [31:0] RD1, RD2
);
    reg [31:0] registers [0:31];
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'h00000000;
        end
        else begin
            registers[0] <= 32'h0; // x0 is always 0
            if (WE3 && (A3 != 5'h00)) begin
                registers[A3] <= WD3;
            end
        end
    end

    // Asynchronous read
    assign RD1 = (A1 == 5'h00) ? 32'h0 : registers[A1];
    assign RD2 = (A2 == 5'h00) ? 32'h0 : registers[A2];
endmodule