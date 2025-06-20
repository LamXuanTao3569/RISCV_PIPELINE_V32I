module Instruction_Memory(rst, A, RD, memory_out);
    input rst;
    input [31:0] A;
    output [31:0] RD;
    output [31:0] memory_out [0:1023];

    reg [31:0] mem [1023:0];
  
    assign RD = (rst == 1'b0) ? {32{1'b0}} : mem[A[31:2]];

    genvar idx;
    generate
        for (idx = 0; idx < 1024; idx = idx + 1) begin : expose_mem
            assign memory_out[idx] = mem[idx];
        end
    endgenerate

    initial begin
        // Nạp từ file bên ngoài (cho simulation)
        $readmemh("instructions.mem", mem);
    end
endmodule