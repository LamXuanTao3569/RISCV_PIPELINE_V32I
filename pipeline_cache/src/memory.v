module memory(
    input clk, rst,
    
    // from EX/MEM reg
    input RegWrite_in,
    input MemWrite_in,
    input [1:0] ResultSrc_in,
    input [31:0] ALU_Result_in,
    input [31:0] WriteData_in,
    input [4:0] rd_in,
    input [31:0] PCPlus4_in,
    input [1:0] MemOp_in, // Assuming MemOp is passed from EX

    // to MEM/WB reg
    output reg RegWrite_out,
    output reg [1:0] ResultSrc_out,
    output [31:0] ReadData_out,
    output reg [31:0] ALU_Result_out,
    output reg [4:0] rd_out,
    output reg [31:0] PCPlus4_out,

    // Main Memory Interface
    output wire mem_req_out,
    output wire mem_we_out,
    output wire [31:0] mem_addr_out,
    output wire [31:0] mem_wdata_out,
    input [31:0] mem_rdata_in,
    input mem_ready_in
);

    // Cache hierarchy signals
    wire [31:0] l1d_rdata, l1d_l2_addr, l2d_rdata, l2d_l3_addr, l3d_rdata;
    wire l1d_hit, l1d_l2_req, l2d_hit, l2d_l3_req, l3d_hit, l2d_l3_ready, l1d_l2_ready;
    wire l3d_mem_req;
    wire [31:0] l3d_mem_addr;
    
    // L1 D-Cache
    L1_Cache #(.CACHE_SIZE(1024), .LINE_SIZE(16)) l1_dcache (
        .clk(clk), .rst(rst),
        .addr(ALU_Result_in), .wdata(WriteData_in), .we(MemWrite_in), .re(~MemWrite_in),
        .rdata(l1d_rdata), .hit(l1d_hit),
        .l2_addr(l1d_l2_addr), .l2_req(l1d_l2_req),
        .l2_rdata(l2d_rdata), .l2_ready(l1d_l2_ready)
    );

    // L2 Cache
    L2_Cache #(.CACHE_SIZE(8192), .LINE_SIZE(16)) l2_dcache (
        .clk(clk), .rst(rst),
        .addr(l1d_l2_addr), .wdata(WriteData_in), .we(MemWrite_in & l1d_l2_req), .re(l1d_l2_req & ~MemWrite_in),
        .rdata(l2d_rdata), .hit(l2d_hit),
        .l3_addr(l2d_l3_addr), .l3_req(l2d_l3_req),
        .l3_rdata(l3d_rdata), .l3_ready(l2d_l3_ready)
    );

    // L3 Cache
    L3_Cache #(.CACHE_SIZE(32768), .LINE_SIZE(16)) l3_dcache (
        .clk(clk), .rst(rst),
        .addr(l2d_l3_addr), .wdata(WriteData_in), .we(MemWrite_in & l2d_l3_req), .re(l2d_l3_req & ~MemWrite_in),
        .rdata(l3d_rdata), .hit(l3d_hit),
        .mem_addr(l3d_mem_addr), .mem_req(l3d_mem_req), .mem_rdata(mem_rdata_in), .mem_ready(mem_ready_in)
    );

    assign mem_req_out = l3d_mem_req;
    assign mem_addr_out = l3d_mem_addr;
    assign mem_we_out = MemWrite_in & l3d_mem_req; // Write to main memory on L3 miss
    assign mem_wdata_out = WriteData_in;

    // Connect ready signals
    assign l1d_l2_ready = l2d_hit | l2d_l3_ready;
    assign l2d_l3_ready = l3d_hit | mem_ready_in;

    always @(*) begin
        RegWrite_out = RegWrite_in;
        ResultSrc_out = ResultSrc_in;
        ALU_Result_out = ALU_Result_in;
        rd_out = rd_in;
        PCPlus4_out = PCPlus4_in;
    end

    assign ReadData_out = l1d_rdata;

endmodule 