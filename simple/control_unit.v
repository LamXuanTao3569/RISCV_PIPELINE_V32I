module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    output wire       reg_write,
    output wire       mem_write,
    output wire       alu_src,
    output wire [1:0] result_src,
    output wire [2:0] alu_control
);
    reg r_reg_write, r_mem_write, r_alu_src;
    reg [1:0] r_result_src;
    reg [2:0] r_alu_control;

    always @(*) begin
        case (opcode)
            7'b0010011: begin // I-type (addi)
                r_reg_write   = 1;
                r_mem_write   = 0;
                r_alu_src     = 1;
                r_result_src  = 2'b00;
                r_alu_control = 3'b000;
            end
            7'b0110011: begin // R-type (add)
                r_reg_write   = 1;
                r_mem_write   = 0;
                r_alu_src     = 0;
                r_result_src  = 2'b00;
                r_alu_control = 3'b000;
            end
            default: begin
                r_reg_write   = 0;
                r_mem_write   = 0;
                r_alu_src     = 0;
                r_result_src  = 2'b00;
                r_alu_control = 3'b000;
            end
        endcase
    end

    assign reg_write = r_reg_write;
    assign mem_write = r_mem_write;
    assign alu_src = r_alu_src;
    assign result_src = r_result_src;
    assign alu_control = r_alu_control;
endmodule