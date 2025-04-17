module ex_stage (
    input clk, reset, stall,
    input [31:0] id_ex_reg1, id_ex_reg2, id_ex_imm,
    input [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd,
    input [6:0] id_ex_opcode,
    input id_ex_reg_write, id_ex_mem_write, id_ex_mem_read,
    input [2:0] id_ex_alu_op,
    output reg [31:0] ex_mem_alu_result, ex_mem_reg2,
    output reg [4:0] ex_mem_rd,
    output reg ex_mem_reg_write, ex_mem_mem_write,
    input [1:0] forward_a, forward_b,
    input [31:0] ex_mem_alu_result_in, mem_wb_result
);
    wire [31:0] alu_out, alu_in1, alu_in2;

    assign alu_in1 = (forward_a == 2'b01) ? ex_mem_alu_result_in :
                     (forward_a == 2'b10) ? mem_wb_result : id_ex_reg1;
    assign alu_in2 = (forward_b == 2'b01) ? ex_mem_alu_result_in :
                     (forward_b == 2'b10) ? mem_wb_result :
                     (id_ex_opcode == 7'h13 || id_ex_opcode == 7'h03) ? id_ex_imm : id_ex_reg2;

    alu alu_inst (.a(alu_in1), .b(alu_in2), .op(id_ex_alu_op), .result(alu_out));

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_mem_alu_result <= 0;
            ex_mem_reg2 <= 0;
            ex_mem_rd <= 0;
            ex_mem_reg_write <= 0;
            ex_mem_mem_write <= 0;
        end else if (stall) begin
            ex_mem_alu_result <= ex_mem_alu_result;
            ex_mem_reg2 <= ex_mem_reg2;
            ex_mem_rd <= ex_mem_rd;
            ex_mem_reg_write <= ex_mem_reg_write;
            ex_mem_mem_write <= ex_mem_mem_write;
        end else begin
            ex_mem_alu_result <= alu_out;
            ex_mem_reg2 <= id_ex_reg2;
            ex_mem_rd <= id_ex_rd;
            ex_mem_reg_write <= id_ex_reg_write;
            ex_mem_mem_write <= id_ex_mem_write;
        end
    end
endmodule