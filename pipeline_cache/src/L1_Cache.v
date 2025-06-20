`timescale 1ns / 1ps

module L1_Cache #(
    parameter CACHE_SIZE = 1024, // bytes
    parameter LINE_SIZE = 16     // bytes
)(
    input clk,
    input rst,
    input [31:0] addr,
    input [31:0] wdata,
    input we, // write enable
    input re, // read enable
    output reg [31:0] rdata,
    output reg hit,
    // Interface to next level (L2)
    output reg [31:0] l2_addr,
    output reg l2_req,
    input [31:0] l2_rdata,
    input l2_ready
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
            l2_req <= 0;
            hit_count <= 0;
            miss_count <= 0;
        end else if (re) begin
            if (valid_array[index] && tag_array[index] == tag) begin
                // HIT
                hit <= 1;
                rdata <= data_array[index];
                l2_req <= 0;
                hit_count <= hit_count + 1;
            end else begin
                // MISS
                l2_addr <= addr; // Request whole line from L2
                l2_req <= 1;
                miss_count <= miss_count + 1;
                if (l2_ready) begin
                    data_array[index] <= l2_rdata; // Simplified line fill
                    tag_array[index] <= tag;
                    valid_array[index] <= 1;
                    rdata <= l2_rdata; // Forward data to CPU
                    l2_req <= 0;
                    hit <= 1; // Data is now valid
                end else begin
                    hit <= 0;
                end
            end
        end else if (we) begin
            // Simplified write-through, no-write-allocate
            if (valid_array[index] && tag_array[index] == tag) begin
                data_array[index] <= wdata;
            end
            // For I-cache, write is not expected, but handle for completeness
            l2_addr <= addr;
            l2_req <= 1; // Propagate write to L2
            hit <= 0;
        end else begin
            hit <= 0;
        end
    end

    // Print hit/miss counters at end of simulation
    /* initial begin
        $monitor("L1 I-Cache Hits: %d, Misses: %d", hit_count, miss_count);
        #1000;
        $display("L1 I-Cache Final Hits: %d, Misses: %d", hit_count, miss_count);
    end */
endmodule 