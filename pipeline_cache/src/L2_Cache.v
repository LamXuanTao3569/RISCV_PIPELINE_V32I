`timescale 1ns / 1ps

module L2_Cache #(
    parameter CACHE_SIZE = 8192, // bytes
    parameter LINE_SIZE = 32     // bytes
)(
    input clk,
    input rst,
    input [31:0] addr,
    input [31:0] wdata,
    input we,
    input re,
    output reg [31:0] rdata,
    output reg hit,
    // Interface to next level (L3)
    output reg [31:0] l3_addr,
    output reg l3_req,
    input [31:0] l3_rdata,
    input l3_ready
);
    localparam NUM_LINES = CACHE_SIZE / LINE_SIZE;
    localparam INDEX_BITS = $clog2(NUM_LINES);
    localparam OFFSET_BITS = $clog2(LINE_SIZE);

    reg [31:0] data_array [0:NUM_LINES-1];
    reg [32-INDEX_BITS-OFFSET_BITS-1:0] tag_array [0:NUM_LINES-1];
    reg valid_array [0:NUM_LINES-1];
    reg [31:0] hit_count, miss_count;

    wire [INDEX_BITS-1:0] index = addr[OFFSET_BITS + INDEX_BITS - 1:OFFSET_BITS];
    wire [32-INDEX_BITS-OFFSET_BITS-1:0] tag = addr[31:OFFSET_BITS + INDEX_BITS];

    always @(posedge clk or posedge rst) begin: CACHE_LOGIC
        integer i;
        if (rst) begin
            // For synthesis, BRAMs initialize to 0, so explicit reset loop is removed.
            hit <= 0;
            rdata <= 0;
            l3_req <= 0;
            hit_count <= 0;
            miss_count <= 0;
        end else if (re) begin
            if (valid_array[index] && tag_array[index] == tag) begin
                hit <= 1;
                rdata <= data_array[index];
                l3_req <= 0;
                hit_count <= hit_count + 1;
            end else begin
                l3_addr <= addr;
                l3_req <= 1;
                miss_count <= miss_count + 1;
                if (l3_ready) begin
                    data_array[index] <= l3_rdata;
                    tag_array[index] <= tag;
                    valid_array[index] <= 1;
                    rdata <= l3_rdata;
                    l3_req <= 0;
                    hit <= 1; // Data is now valid
                end else begin
                    hit <= 0;
                end
            end
        end else if (we) begin
            if (valid_array[index] && tag_array[index] == tag) begin
                data_array[index] <= wdata;
            end
            l3_addr <= addr;
            l3_req <= 1;
            hit <= 0;
        end else begin
            hit <= 0;
        end
    end

    // Print hit/miss counters at end of simulation
    /* initial begin
        $monitor("L2 Cache Hits: %d, Misses: %d", hit_count, miss_count);
        #1000;
        $display("L2 Cache Final Hits: %d, Misses: %d", hit_count, miss_count);
    end */
endmodule 