module fetch(
    input clk, rst,
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
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_reg <= 32'h0;
        end else if (pc_write_en) begin
            pc_reg <= pc_next;
        end
    end

    // PC + 4 adder
    assign pc_plus4 = pc_reg + 4;
    assign pc_out = pc_reg;
    assign pc_plus4_out = pc_plus4;

    // Branch Predictor (1-bit, 64-entry, indexed by PC[7:2])
    reg predictor_table [0:63];
    reg [31:0] predictor_correct, predictor_total;
    wire [5:0] predictor_index = pc_reg[7:2];

    // Predictor update logic (to be triggered by execute stage feedback)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            integer i;
            for (i = 0; i < 64; i = i + 1) predictor_table[i] <= 0;
            predictor_correct <= 0;
            predictor_total <= 0;
        end else if (predictor_update) begin
            predictor_table[predictor_update_index] <= predictor_outcome;
            predictor_total <= predictor_total + 1;
            if (predictor_table[predictor_update_index] == predictor_outcome)
                predictor_correct <= predictor_correct + 1;
        end
    end

    // Branch prediction output
    wire branch_pred = predictor_table[predictor_index];
    assign branch_predict_out = branch_pred;

    // PC selection logic
    wire is_branch = (if_instr[6:0] == 7'b1100011); // B-type opcode
    assign pc_next = (pc_src) ? pc_target : (is_branch && branch_pred ? pc_target : pc_plus4);

endmodule 