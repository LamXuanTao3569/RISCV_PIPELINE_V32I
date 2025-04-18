module forwarding_unit (
    input [4:0] ex_mem_rd, mem_wb_rd, id_ex_rs1, id_ex_rs2,
    input ex_mem_reg_write, mem_wb_reg_write,
    output reg [1:0] forward_a, forward_b
);
    always @(*) begin
        // Forward A
        if (ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs1)
            forward_a = 2'b01; // From EX/MEM
        else if (mem_wb_reg_write && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs1)
            forward_a = 2'b10; // From MEM/WB
        else
            forward_a = 2'b00; // No forwarding
        // Forward B
        if (ex_mem_reg_write && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs2)
            forward_b = 2'b01;
        else if (mem_wb_reg_write && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs2)
            forward_b = 2'b10;
        else
            forward_b = 2'b00;
    end
endmodule