`timescale 1ns / 1ps

module Main_Memory #(
    parameter MEM_SIZE = 4096 // 4K words, 16KB
)(
    input clk,
    input req,
    input we,
    input [31:0] addr,
    input [31:0] wdata,
    output reg [31:0] rdata,
    output reg ready
);

    reg [31:0] mem [0:MEM_SIZE-1];

    // Initialize memory from file
    initial begin
`ifdef quartus_synthesis
        // For synthesis, Quartus expects the file to be in the project directory
        $readmemh("instructions.mem", mem);
`else
        // For simulation, the path is relative to the simulation/questa directory
        $readmemh("/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/instructions.mem", mem);
        // Optionally load data memory from memfile.hex if it exists
        if ($fopen("/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/memfile.hex", "r")) begin
            $readmemh("/home/taolam/RISC-V-32I-5-stage-Pipeline-Core/src/memfile.hex", mem);
        end
`endif
    end

    // Memory access logic (1 cycle latency)
    always @(posedge clk) begin
        if (req) begin
            if (we) begin
                mem[addr[31:2]] <= wdata;
            end else begin
                rdata <= mem[addr[31:2]];
            end
        end
        ready <= req; // Respond in the next cycle
    end

endmodule 