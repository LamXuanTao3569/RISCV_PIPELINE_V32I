module DMEM(
    input  logic clk,
    input  logic [9:0] addr,
    input  logic [31:0] wdata,
    input  logic wen,
    output logic [31:0] rdata
);
    logic [31:0] memory [0:255];
    initial $readmemh("mem/dmem_init.hex", memory);
    assign rdata = memory[addr];
    always_ff @(posedge clk) begin
        if (wen)
            memory[addr] <= wdata;
    end
endmodule 