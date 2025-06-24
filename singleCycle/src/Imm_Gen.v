module Imm_Gen(
    input  logic [31:0] instr,
    input  logic [2:0] immSel, // 0: I, 1: S, 2: B, 3: U, 4: J
    output logic [31:0] imm
);
    wire [31:0] immI = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] immS = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [31:0] immB = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    wire [31:0] immU = {instr[31:12], 12'b0};
    wire [31:0] immJ = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

    always @* begin
        case (immSel)
            3'b000: imm = immI;
            3'b001: imm = immS;
            3'b010: imm = immB;
            3'b011: imm = immU;
            3'b100: imm = immJ;
            default: imm = 32'b0;
        endcase
    end
endmodule 