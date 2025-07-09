module ControlUnit(
    input  logic [31:0] instr,
    input  logic BrEq,
    input  logic BrLT,
    output logic pcSel,
    output logic regWEn,
    output logic aSel,
    output logic bSel,
    output logic [1:0] wbSel,
    output logic [3:0] aluSel,
    output logic [2:0] immSel,
    output logic memRW,
    output logic brUn
);
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    always @* begin
        // Default values
        pcSel   = 0;
        regWEn  = 0;
        aSel    = 0;
        bSel    = 0;
        wbSel   = 2'b00;
        aluSel  = 4'b0000;
        immSel  = 3'b000;
        memRW   = 0;
        brUn    = 0;

        case (opcode)
            7'b0110011: begin // R-type
                regWEn = 1;
                aSel = 0; bSel = 0; wbSel = 2'b00;
                case (funct3)
                    3'b000: aluSel = (funct7[5] ? 4'b0001 : 4'b0000); // SUB/ADD
                    3'b111: aluSel = 4'b0010; // AND
                    3'b110: aluSel = 4'b0011; // OR
                    3'b100: aluSel = 4'b0100; // XOR
                    3'b001: aluSel = 4'b0101; // SLL
                    3'b101: aluSel = (funct7[5] ? 4'b0111 : 4'b0110); // SRA/SRL
                    3'b010: aluSel = 4'b1000; // SLT
                    3'b011: aluSel = 4'b1001; // SLTU
                endcase
            end
            7'b0010011: begin // I-type ALU
                regWEn = 1; aSel = 0; bSel = 1; wbSel = 2'b00; immSel = 3'b000;
                case (funct3)
                    3'b000: aluSel = 4'b0000; // ADDI
                    3'b111: aluSel = 4'b0010; // ANDI
                    3'b110: aluSel = 4'b0011; // ORI
                    3'b100: aluSel = 4'b0100; // XORI
                    3'b001: aluSel = 4'b0101; // SLLI
                    3'b101: aluSel = (funct7[5] ? 4'b0111 : 4'b0110); // SRAI/SRLI
                    3'b010: aluSel = 4'b1000; // SLTI
                    3'b011: aluSel = 4'b1001; // SLTIU
                endcase
            end
            7'b0000011: begin // Load
                regWEn = 1; aSel = 0; bSel = 1; wbSel = 2'b01; aluSel = 4'b0000; immSel = 3'b000;
            end
            7'b0100011: begin // Store
                regWEn = 0; aSel = 0; bSel = 1; aluSel = 4'b0000; immSel = 3'b001; memRW = 1;
            end
            7'b1100011: begin // Branch
                regWEn = 0; aSel = 0; bSel = 0; aluSel = 4'b0001; immSel = 3'b010;
                brUn = (funct3 == 3'b110 || funct3 == 3'b111);
                case (funct3)
                    3'b000: pcSel = BrEq; // BEQ
                    3'b001: pcSel = ~BrEq; // BNE
                    3'b100: pcSel = BrLT; // BLT
                    3'b101: pcSel = ~BrLT; // BGE
                    3'b110: pcSel = BrLT; // BLTU
                    3'b111: pcSel = ~BrLT; // BGEU
                    default: pcSel = 0;
                endcase
            end
            7'b1101111: begin // JAL
                regWEn = 1; aSel = 0; bSel = 1; wbSel = 2'b10; aluSel = 4'b0000; immSel = 3'b100; pcSel = 1;
            end
            7'b1100111: begin // JALR
                regWEn = 1; aSel = 0; bSel = 1; wbSel = 2'b10; aluSel = 4'b0000; immSel = 3'b000; pcSel = 1;
            end
            7'b0110111: begin // LUI
                regWEn = 1; aSel = 0; bSel = 1; wbSel = 2'b00; aluSel = 4'b0000; immSel = 3'b011;
            end
            7'b0010111: begin // AUIPC
                regWEn = 1; aSel = 1; bSel = 1; wbSel = 2'b00; aluSel = 4'b0000; immSel = 3'b011;
            end
            default: begin
                // NOP
            end
        endcase
    end
endmodule 
//taolam