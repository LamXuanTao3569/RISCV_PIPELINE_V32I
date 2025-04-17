module if_stage (
    input clk, reset, stall,
    output [31:0] pc,
    output [31:0] instr
);
    reg [31:0] pc_reg;
    imem imem_inst (.addr(pc_reg[9:2]), .data(instr));

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_reg <= 0;
        else if (stall)
            pc_reg <= pc_reg;
        else
            pc_reg <= pc_reg + 4;
    end

    assign pc = pc_reg;
endmodule