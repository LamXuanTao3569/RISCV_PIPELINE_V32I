module fetch(
    input clk, rst,
    input pc_write_en,
    input pc_src, // mux select for PC from EX stage (for branches/jumps)
    input [31:0] pc_target, // branch/jump target from EX stage

    output [31:0] pc_out,
    output [31:0] pc_plus4_out,
    output [31:0] instr_out,
    output wire l1i_cache_hit_out,
    output wire branch_predict_out, // new: branch prediction output

    // Main Memory Interface
    output wire mem_req_out,
    output wire [31:0] mem_addr_out,
    input [31:0] mem_rdata_in,
    input mem_ready_in
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
    reg predictor_update;
    reg predictor_outcome;
    reg [5:0] predictor_update_index;

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
    wire is_branch = (instr_out[6:0] == 7'b1100011); // B-type opcode
    assign pc_next = (pc_src) ? pc_target : (is_branch && branch_pred ? pc_target : pc_plus4);

    // Cache hierarchy signals
    wire [31:0] l1i_rdata, l1i_l2_addr, l2i_rdata, l2i_l3_addr, l3i_rdata, mem_rdata;
    wire l1i_hit, l1i_l2_req, l2i_hit, l2i_l3_req, l3i_hit, l2i_l3_ready, l1i_l2_ready, l3i_mem_ready;
    wire l3i_mem_req;
    wire [31:0] l3i_mem_addr;

    // L1 I-Cache
    L1_Cache #(.CACHE_SIZE(1024), .LINE_SIZE(16)) l1_icache (
        .clk(clk), .rst(rst),
        .addr(pc_reg), .wdata(32'b0), .we(1'b0), .re(1'b1),
        .rdata(l1i_rdata), .hit(l1i_hit),
        .l2_addr(l1i_l2_addr), .l2_req(l1i_l2_req),
        .l2_rdata(l2i_rdata), .l2_ready(l1i_l2_ready)
    );

    // L2 Cache
    L2_Cache #(.CACHE_SIZE(8192), .LINE_SIZE(16)) l2_icache (
        .clk(clk), .rst(rst),
        .addr(l1i_l2_addr), .wdata(32'b0), .we(1'b0), .re(l1i_l2_req),
        .rdata(l2i_rdata), .hit(l2i_hit),
        .l3_addr(l2i_l3_addr), .l3_req(l2i_l3_req),
        .l3_rdata(l3i_rdata), .l3_ready(l2i_l3_ready)
    );

    // L3 Cache
    L3_Cache #(.CACHE_SIZE(32768), .LINE_SIZE(16)) l3_icache (
        .clk(clk), .rst(rst),
        .addr(l2i_l3_addr), .wdata(32'b0), .we(1'b0), .re(l2i_l3_req),
        .rdata(l3i_rdata), .hit(l3i_hit),
        .mem_addr(l3i_mem_addr), .mem_req(l3i_mem_req), .mem_rdata(mem_rdata_in), .mem_ready(mem_ready_in)
    );

    assign mem_req_out = l3i_mem_req;
    assign mem_addr_out = l3i_mem_addr;

    // Connect ready signals
    assign l1i_l2_ready = l2i_hit | l2i_l3_ready;
    assign l2i_l3_ready = l3i_hit | mem_ready_in;

    // Output
    assign instr_out = l1i_rdata;
    assign l1i_cache_hit_out = l1i_hit;

endmodule 