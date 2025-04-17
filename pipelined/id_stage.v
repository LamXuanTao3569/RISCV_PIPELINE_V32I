module id_stage (
    input clk, reset, stall,
    input [31:0] if_id_inst,
    input [4:0] mem_wb_rd,
    input [31:0] mem_wb_result,
    input mem_wb_reg_write,
    output reg [31:0] reg1, reg2, imm,
    output reg [4:0] rs1, rs2, rd,
    output reg [6:0] opcode,
    output reg reg_write, mem_write, mem_read,
    output reg [2:0] alu_op
);
    wire [31:0] reg1_out, reg2_out;
    wire mem_write_out, mem_read_out, reg_write_out;
    wire [2:0] alu_op_out;

    regfile regs (.clk(clk), .rs1(if_id_inst[19:15]), .rs2(if_id_inst[24:20]), .rd(mem_wb_rd),
                 .write_data(mem_wb_result), .we(mem_wb_reg_write),
                 .read_data1(reg1_out), .read_data2(reg2_out));
    control_unit ctrl (.opcode(if_id_inst[6:0]), .mem_write(mem_write_out), .mem_read(mem_read_out),
                      .reg_write(reg_write_out), .alu_op(alu_op_out));

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg1 <= 0; reg2 <= 0; imm <= 0;
            rs1 <= 0; rs2 <= 0; rd <= 0;
            opcode <= 0; reg_write <= 0; mem_write <= 0; mem_read <= 0;
            alu_op <= 0;
        end else if (stall) begin
            reg1 <= reg1; reg2 <= reg2; imm <= imm;
            rs1 <= rs1; rs2 <= rs2; rd <= rd;
            opcode <= opcode; reg_write <= reg_write; mem_write <= mem_write; mem_read <= mem_read;
            alu_op <= alu_op;
        end else begin
            reg1 <= reg1_out;
            reg2 <= reg2_out;
            imm <= (if_id_inst[6:0] == 7'h13 || if_id_inst[6:0] == 7'h03) ? 
                   {{20{if_id_inst[31]}}, if_id_inst[31:20]} :
                   (if_id_inst[6:0] == 7'h23) ? {{20{if_id_inst[31]}}, if_id_inst[31:25], if_id_inst[11:7]} : 0;
            rs1 <= if_id_inst[19:15];
            rs2 <= if_id_inst[24:20];
            rd <= if_id_inst[11:7];
            opcode <= if_id_inst[6:0];
            reg_write <= reg_write_out;
            mem_write <= mem_write_out;
            mem_read <= mem_read_out;
            alu_op <= alu_op_out;
        end
    end
endmodule