module fetch(
    input clk, rst_n,
    input pc_write_en,
    input pc_src, // mux select for PC from EX stage (for branches/jumps)
    input [31:0] pc_target, // branch/jump target from EX stage
    input predictor_update,
    input [5:0] predictor_update_index,
    input predictor_outcome,
    input [31:0] if_instr, // Instruction from top module

    output [31:0] pc_out,
    output [31:0] pc_plus4_out,
    output wire branch_predict_out // new: branch prediction output
);
    reg [31:0] pc_reg;
    wire [31:0] pc_next;
    wire [31:0] pc_plus4;
    
    // PC register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_reg <= 32'h0;
        end else if (pc_write_en) begin
            pc_reg <= pc_next;
        end
    end

    // PC + 4 adder
    assign pc_plus4 = pc_reg + 4;
    assign pc_out = pc_reg;
    assign pc_plus4_out = pc_plus4;

    // PC selection logic - disable branch prediction for now
    wire is_branch = (if_instr[6:0] == 7'b1100011); // B-type opcode
    assign pc_next = (pc_src) ? pc_target : pc_plus4;

endmodule 