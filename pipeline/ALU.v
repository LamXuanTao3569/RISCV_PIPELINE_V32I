module ALU(
    input [31:0] A, B,
    input [3:0] ALUControl,
    output reg [31:0] Result,
    output reg Zero
);

    wire [31:0] sum;
    wire [31:0] B_inverted;
    wire CarryIn;

    assign B_inverted = (ALUControl == 4'b0001) ? ~B : B;
    assign CarryIn = (ALUControl == 4'b0001) ? 1'b1 : 1'b0;
    assign sum = A + B_inverted + CarryIn;

    always @(*) begin
        case (ALUControl)
            4'b0000: Result = sum; // add, addi, auipc, lui, jal, jalr, load/store
            4'b0001: Result = sum; // sub (for branch)
            4'b0010: Result = A << B[4:0]; // sll, slli
            4'b0011: Result = $signed(A) >>> B[4:0]; // sra, srai
            4'b0100: Result = A ^ B; // xor, xori
            4'b0101: Result = A >> B[4:0]; // srl, srli
            4'b0110: Result = ($signed(A) < $signed(B)) ? 32'h1 : 32'h0; // slt, slti
            4'b0111: Result = (A < B) ? 32'h1 : 32'h0; // sltu, sltiu
            4'b1000: Result = A | B; // or, ori
            4'b1001: Result = A & B; // and, andi
            default: Result = 32'h0;
        endcase

        Zero = (Result == 32'h0);
    end
endmodule