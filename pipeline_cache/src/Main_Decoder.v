module Main_Decoder(
    input [6:0] Op,
    input [2:0] funct3,  // Thêm funct3 để xác định MemOp
    output reg RegWrite, ALUSrc, MemWrite, Branch, Jump,
    output reg [1:0] ResultSrc, MemOp, 
    output reg [2:0] ImmSrc, 
    output reg [1:0] ALUOp
);
    always @(*) begin
        case (Op)
            7'b0110011: begin // R-type
                RegWrite = 1'b1;
                ALUSrc = 1'b0;
                MemWrite = 1'b0;
                ResultSrc = 2'b00;
                Branch = 1'b0;
                Jump = 1'b0;
                ImmSrc = 2'b00;
                MemOp = 2'b00;  // Không dùng
                ALUOp = 2'b10;
            end
            7'b0010011: begin // I-type (arithmetic)
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                MemWrite = 1'b0;
                ResultSrc = 2'b00;
                Branch = 1'b0;
                Jump = 1'b0;
                ImmSrc = 2'b00;
                MemOp = 2'b00;  // Không dùng
                ALUOp = 2'b10;
            end
            7'b0000011: begin // I-type (load)
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                MemWrite = 1'b0;
                ResultSrc = 2'b01;
                Branch = 1'b0;
                Jump = 1'b0;
                ImmSrc = 2'b00;
                case (funct3)
                    3'b000: MemOp = 2'b00; // lb
                    3'b001: MemOp = 2'b01; // lh
                    3'b010: MemOp = 2'b10; // lw
                    3'b100: MemOp = 2'b11; // lbu
                    3'b101: MemOp = 2'b11; // lhu
                    default: MemOp = 2'b10;
                endcase
                ALUOp = 2'b00;
            end
            7'b0100011: begin // S-type
                RegWrite = 1'b0;
                ALUSrc = 1'b1;
                MemWrite = 1'b1;
                ResultSrc = 2'b00;
                Branch = 1'b0;
                Jump = 1'b0;
                ImmSrc = 2'b01;
                case (funct3)
                    3'b000: MemOp = 2'b00; // sb
                    3'b001: MemOp = 2'b01; // sh
                    3'b010: MemOp = 2'b10; // sw
                    default: MemOp = 2'b10;
                endcase
                ALUOp = 2'b00;
            end
            7'b1100011: begin // B-type
                RegWrite = 1'b0;
                ALUSrc = 1'b0;
                MemWrite = 1'b0;
                ResultSrc = 2'b00;
                Branch = 1'b1;
                Jump = 1'b0;
                ImmSrc = 2'b10;
                MemOp = 2'b00;  // Không dùng
                ALUOp = 2'b01;
            end
            7'b1101111: begin // J-type (jal)
                RegWrite = 1'b1;
                ALUSrc = 1'b0;
                MemWrite = 1'b0;
                ResultSrc = 2'b10;
                Branch = 1'b0;
                Jump = 1'b1;
                ImmSrc = 2'b11;
                MemOp = 2'b00;  // Không dùng
                ALUOp = 2'b00;
            end
            7'b1100111: begin // I-type (jalr)
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                MemWrite = 1'b0;
                ResultSrc = 2'b10;
                Branch = 1'b0;
                Jump = 1'b1;
                ImmSrc = 2'b00;
                MemOp = 2'b00;  // Không dùng
                ALUOp = 2'b00;
            end
            7'b0010111: begin // U-type (auipc)
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                MemWrite = 1'b0;
                ResultSrc = 2'b00;
                Branch = 1'b0;
                Jump = 1'b0;
                ImmSrc = 2'b00;
                MemOp = 2'b00;  // Không dùng
                ALUOp = 2'b11;
            end
            7'b0110111: begin // U-type (lui)
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                MemWrite = 1'b0;
                ResultSrc = 2'b00;
                Branch = 1'b0;
                Jump = 1'b0;
                ImmSrc = 2'b00;
                MemOp = 2'b00;  // Không dùng
                ALUOp = 2'b11;
            end
            7'b1110011: begin // I-type (ebreak, ecall)
                RegWrite = 1'b0;
                ALUSrc = 1'b0;
                MemWrite = 1'b0;
                ResultSrc = 2'b00;
                Branch = 1'b0;
                Jump = 1'b0;
                ImmSrc = 2'b00;
                MemOp = 2'b00;  // Không dùng
                ALUOp = 2'b00;
            end
            default: begin
                RegWrite = 1'b0;
                ALUSrc = 1'b0;
                MemWrite = 1'b0;
                ResultSrc = 2'b00;
                Branch = 1'b0;
                Jump = 1'b0;
                ImmSrc = 2'b00;
                MemOp = 2'b00;
                ALUOp = 2'b00;
            end
        endcase
    end
endmodule