module PC_Module(
    input clk, rst_n, StallF,
    input [31:0] PC_Next,
    output reg [31:0] PC
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            PC <= 32'h0;
        else if (StallF)
            PC <= PC;
        else
            PC <= PC_Next;
    end
endmodule