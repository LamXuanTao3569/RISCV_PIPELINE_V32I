module ALU_Decoder(
    input [1:0] ALUOp,
    input [2:0] funct3,
    input funct7_5,
    output reg [3:0] ALUControl  // Tăng lên 4-bit để hỗ trợ nhiều phép toán hơn
);

    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0000; // add (for load/store, auipc, lui, jal, jalr)
            2'b01: begin // Branch
                case (funct3)
                    3'b000: ALUControl = 4'b0001; // beq (sub)
                    3'b001: ALUControl = 4'b0001; // bne (sub)
                    3'b100: ALUControl = 4'b0110; // blt (slt)
                    3'b101: ALUControl = 4'b0110; // bge (slt)
                    3'b110: ALUControl = 4'b0111; // bltu (sltu)
                    3'b111: ALUControl = 4'b0111; // bgeu (sltu)
                    default: ALUControl = 4'b0000;
                endcase
            end
            2'b10: begin // R-type and I-type
                case (funct3)
                    3'b000: begin
                        if (funct7_5)
                            ALUControl = 4'b0001; // sub
                        else
                            ALUControl = 4'b0000; // add, addi
                    end
                    3'b001: ALUControl = 4'b0010; // sll, slli
                    3'b010: ALUControl = 4'b0110; // slt, slti
                    3'b011: ALUControl = 4'b0111; // sltu, sltiu
                    3'b100: ALUControl = 4'b0100; // xor, xori
                    3'b101: begin
                        if (funct7_5)
                            ALUControl = 4'b0011; // sra, srai
                        else
                            ALUControl = 4'b0101; // srl, srli
                    end
                    3'b110: ALUControl = 4'b1000; // or, ori
                    3'b111: ALUControl = 4'b1001; // and, andi
                    default: ALUControl = 4'b0000;
                endcase
            end
            2'b11: ALUControl = 4'b0000; // auipc, lui (ALU just needs to pass immediate)
            default: ALUControl = 4'b0000;
        endcase
    end
endmodule