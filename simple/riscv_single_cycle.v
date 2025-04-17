module riscv_single (
    input  wire        clk,
    input  wire        reset,
    output wire [31:0] pc,
    output wire [31:0] alu_result
);
    wire [31:0] instr, reg_data1, reg_data2, alu_out, imm, write_data, mem_data;
    wire [4:0]  rs1, rs2, rd;
    wire [6:0]  opcode;
    wire [2:0]  funct3;
    wire        reg_write, mem_write, alu_src;
    wire [1:0]  result_src;
    wire [2:0]  alu_control;

    reg [31:0] pc_reg; // Thay vì logic để tổng hợp được
    wire [31:0] pc_next;
    always @(posedge clk or posedge reset) begin
        if (reset) pc_reg <= 32'b0;
        else       pc_reg <= pc_next;
    end
    assign pc = pc_reg;
    assign pc_next = pc + 4;

    imem imem (.addr(pc), .instr(instr));
    assign opcode = instr[6:0];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign imm    = {{20{instr[31]}}, instr[31:20]};

    control_unit cu (
        .opcode(opcode), .funct3(funct3),
        .reg_write(reg_write), .mem_write(mem_write), .alu_src(alu_src),
        .result_src(result_src), .alu_control(alu_control)
    );

    regfile rf (
        .clk(clk), .we(reg_write), .rs1(rs1), .rs2(rs2), .rd(rd),
        .write_data(write_data), .read_data1(reg_data1), .read_data2(reg_data2)
    );

    wire [31:0] alu_in2 = alu_src ? imm : reg_data2;
    alu alu (.a(reg_data1), .b(alu_in2), .control(alu_control), .result(alu_out));

    dmem dmem (
        .clk(clk), .we(mem_write), .addr(alu_out), .write_data(reg_data2),
        .read_data(mem_data)
    );

    assign write_data = (result_src == 2'b00) ? alu_out :
                       (result_src == 2'b01) ? mem_data : pc + 4;
    assign alu_result = alu_out;
endmodule