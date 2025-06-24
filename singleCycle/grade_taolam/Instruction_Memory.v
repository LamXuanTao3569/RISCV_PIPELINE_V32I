`timescale 1ns/1ps

module Instruction_Memory(
    input [31:0] A,
    output [31:0] RD
);
    reg [31:0] memory [0:1023];

    // Asynchronous read
    assign RD = memory[A[31:2]];

endmodule