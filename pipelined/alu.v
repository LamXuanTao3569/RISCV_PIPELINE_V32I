module alu (
    input [31:0] a, b,
    input [2:0] op,
    output reg [31:0] result
);
    always @(*) begin
        case (op)
            3'b000: result = a + b;        // add, addi
            3'b001: result = a - b;        // sub
            3'b010: result = a & b;        // and
            3'b011: result = a | b;        // or
            3'b100: result = a ^ b;        // xor
            3'b101: result = a << b[4:0];  // sll
            3'b110: result = a >> b[4:0];  // srl
            3'b111: result = $signed(a) >>> b[4:0]; // sra
            default: result = 0;
        endcase
    end
endmodule