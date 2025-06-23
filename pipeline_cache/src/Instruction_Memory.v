`timescale 1ns/1ps

module Instruction_Memory(
    input [31:0] A,
    output [31:0] RD
);
    reg [31:0] memory [0:1023];
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            memory[i] = 32'b0;
        end
        $readmemh("mem/imem2.hex", memory);
    end
    // Task to load instructions (for simulation)
    task load_instructions;
        input [31:0] instr_array [0:1023];
        integer j;
        begin
            for (j = 0; j < 1024; j = j + 1) begin
                memory[j] = instr_array[j];
            end
        end
    endtask

    // Asynchronous read with address check
    assign RD = (A[31:2] < 1024) ? memory[A[31:2]] : 32'h00000013;

endmodule