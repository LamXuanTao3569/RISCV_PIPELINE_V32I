module RISCV_Single_Cycle(
    input  logic clk,
    input  logic rst_n,
    output logic [31:0] PC_out_top,
    output logic [31:0] Instruction_out_top
);
    // PC
    logic [31:0] PC, next_PC;
    assign PC_out_top = PC;

    // Instruction
    logic [31:0] instr;
    assign Instruction_out_top = instr;

    // Register file
    logic [4:0] rs1, rs2, rd;
    logic [31:0] regA, regB, regW;
    logic regWEn;

    // Immediate
    logic [31:0] imm;

    // ALU
    logic [31:0] aluA, aluB, aluOut;
    logic [3:0] aluSel;

    // Data memory
    logic [31:0] dmemR, dmemW;
    logic memRW;

    // Control signals
    logic pcSel, aSel, bSel;
    logic [1:0] wbSel;
    logic [2:0] immSel;
    logic brUn, brEq, brLT;

    // Instruction fetch
    IMEM IMEM_inst(
        .addr(PC[11:2]), // word address
        .data(instr)
    );

    // Register file
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd  = instr[11:7];

    RegFile Reg_inst(
        .clk(clk),
        .rst_n(rst_n),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .rd_data(regW),
        .regWEn(regWEn),
        .rs1_data(regA),
        .rs2_data(regB)
    );

    // Immediate generator
    Imm_Gen ImmGen_inst(
        .instr(instr),
        .immSel(immSel),
        .imm(imm)
    );

    // ALU input muxes
    assign aluA = aSel ? PC : regA;
    assign aluB = bSel ? imm : regB;

    // ALU
    ALU ALU_inst(
        .A(aluA),
        .B(aluB),
        .ALUSel(aluSel),
        .Y(aluOut)
    );

    // Branch comparator
    BranchComp BranchComp_inst(
        .A(regA),
        .B(regB),
        .BrUn(brUn),
        .BrEq(brEq),
        .BrLT(brLT)
    );

    // Data memory
    assign dmemW = regB;
    DMEM DMEM_inst(
        .clk(clk),
        .addr(aluOut[11:2]), // word address
        .wdata(dmemW),
        .wen(memRW),
        .rdata(dmemR)
    );

    // Write-back mux
    logic [31:0] wb_data;
    always_comb begin
        case (wbSel)
            2'b00: wb_data = aluOut;
            2'b01: wb_data = dmemR;
            2'b10: wb_data = PC + 4;
            default: wb_data = 32'b0;
        endcase
    end
    assign regW = wb_data;

    // PC selection
    always_comb begin
        if (pcSel)
            next_PC = aluOut;
        else
            next_PC = PC + 4;
    end

    // PC register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            PC <= 32'h0;
        else
            PC <= next_PC;
    end

    // Control unit
    ControlUnit CU(
        .instr(instr),
        .BrEq(brEq),
        .BrLT(brLT),
        .pcSel(pcSel),
        .regWEn(regWEn),
        .aSel(aSel),
        .bSel(bSel),
        .wbSel(wbSel),
        .aluSel(aluSel),
        .immSel(immSel),
        .memRW(memRW),
        .brUn(brUn)
    );

endmodule 
//taolam