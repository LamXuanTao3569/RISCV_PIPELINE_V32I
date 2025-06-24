module IMEM(
    input  logic [9:0] addr, // 1024 words
    output logic [31:0] data
);
    logic [31:0] memory [0:1023];
    initial $readmemh("mem/imem.hex", memory);
    assign data = memory[addr];
endmodule 