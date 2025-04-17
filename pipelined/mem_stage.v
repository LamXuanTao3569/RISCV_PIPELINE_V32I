module mem_stage (
    input clk, reset, stall,
    input [31:0] ex_mem_alu_result, ex_mem_reg2,
    input [4:0] ex_mem_rd,
    input ex_mem_reg_write, ex_mem_mem_write,
    output reg [31:0] mem_wb_result,
    output reg [4:0] mem_wb_rd,
    output reg mem_wb_reg_write
);
    wire [31:0] mem_data;

    dmem dmem_inst (.clk(clk), .addr(ex_mem_alu_result[9:2]), .data_in(ex_mem_reg2),
                    .we(ex_mem_mem_write), .data_out(mem_data));

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_wb_result <= 0;
            mem_wb_rd <= 0;
            mem_wb_reg_write <= 0;
        end else if (stall) begin
            mem_wb_result <= mem_wb_result;
            mem_wb_rd <= mem_wb_rd;
            mem_wb_reg_write <= mem_wb_reg_write;
        end else begin
            mem_wb_result <= (ex_mem_alu_result == 7'h03) ? mem_data : ex_mem_alu_result;
            mem_wb_rd <= ex_mem_rd;
            mem_wb_reg_write <= ex_mem_reg_write;
        end
    end
endmodule