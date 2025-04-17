module dmem (
    input clk, we,
    input [7:0] addr,
    input [31:0] data_in,
    output [31:0] data_out
);
    reg [31:0] mem [0:255];
    always @(posedge clk) if (we) mem[addr] <= data_in;
    assign data_out = mem[addr];
endmodule