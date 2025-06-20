module Instruction_Memory(rst, A, RD);
    input rst;
    input [31:0] A;
    output [31:0] RD;

    reg [31:0] memory [0:1023];
  
    assign RD = (rst == 1'b0) ? {32{1'b0}} : memory[A[31:2]];

    // initial begin
    //     $readmemh("instructions.mem", memory);
    // end
endmodule