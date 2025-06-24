module ALU(
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [3:0] ALUSel,
    output logic [31:0] Y
);
    always_comb begin
        case (ALUSel)
            4'b0000: Y = A + B; // ADD
            4'b0001: Y = A - B; // SUB
            4'b0010: Y = A & B; // AND
            4'b0011: Y = A | B; // OR
            4'b0100: Y = A ^ B; // XOR
            4'b0101: Y = A << B[4:0]; // SLL
            4'b0110: Y = A >> B[4:0]; // SRL
            4'b0111: Y = $signed(A) >>> B[4:0]; // SRA
            4'b1000: Y = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; // SLT
            4'b1001: Y = (A < B) ? 32'b1 : 32'b0; // SLTU
            default: Y = 32'b0;
        endcase
    end
endmodule 