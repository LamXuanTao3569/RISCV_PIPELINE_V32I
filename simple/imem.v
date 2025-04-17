module imem (
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:31];
    initial begin
        mem[0] = 32'h00500093; // addi x1, x0, 5
        mem[1] = 32'h00700113; // addi x2, x0, 7
        mem[2] = 32'h002081b3; // add  x3, x1, x2
    end
    assign instr = mem[addr[31:2]];
endmodule