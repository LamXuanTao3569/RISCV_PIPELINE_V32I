module IF_ID_reg (
    input clk, rst,
    input if_id_write,
    input if_id_flush,
    input [31:0] pc_in,
    input [31:0] instr_in,
    input [31:0] pc_plus4_in,
    output reg [31:0] pc_out,
    output reg [31:0] instr_out,
    output reg [31:0] pc_plus4_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= 32'b0;
            instr_out <= 32'b0; // NOP (illegal instruction)
            pc_plus4_out <= 32'b0;
        end else if (if_id_flush) begin
            pc_out <= 32'b0;
            instr_out <= 32'b0;
            pc_plus4_out <= 32'b0;
        end else if (if_id_write) begin
            pc_out <= pc_in;
            instr_out <= instr_in;
            pc_plus4_out <= pc_plus4_in;
        end
        // else: hold previous value (stall)
    end
endmodule 