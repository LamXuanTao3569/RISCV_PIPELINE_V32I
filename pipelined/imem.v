module imem (
    input [7:0] addr,
    output [31:0] data
);
    reg [31:0] mem [0:255];
    initial begin
        mem[0] = 32'h00500093; // addi x1, x0, 5
        mem[1] = 32'h00700113; // addi x2, x0, 7
        mem[2] = 32'h002081b3; // add x3, x1, x2
        mem[3] = 32'h00300113; // addi x2, x0, 3
        mem[4] = 32'h002082b3; // add x5, x1, x2
    end
    assign data = mem[addr];
endmodule