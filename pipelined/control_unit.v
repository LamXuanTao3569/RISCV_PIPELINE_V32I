module control_unit (
    input [6:0] opcode,
    output reg mem_write, mem_read, reg_write,
    output reg [2:0] alu_op
);
    always @(*) begin
        case (opcode)
            7'h13: begin // I-type (addi, etc.)
                mem_write = 0; mem_read = 0; reg_write = 1; alu_op = 3'b000;
            end
            7'h33: begin // R-type (add, sub, etc.)
                mem_write = 0; mem_read = 0; reg_write = 1; alu_op = 3'b000; // Adjust based on funct3
            end
            7'h03: begin // lw
                mem_write = 0; mem_read = 1; reg_write = 1; alu_op = 3'b000;
            end
            7'h23: begin // sw
                mem_write = 1; mem_read = 0; reg_write = 0; alu_op = 3'b000;
            end
            default: begin
                mem_write = 0; mem_read = 0; reg_write = 0; alu_op = 3'b000;
            end
        endcase
    end
endmodule