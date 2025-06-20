`timescale 1ns / 1ps

module L3_Cache #(
    parameter CACHE_SIZE = 32768, // bytes
    parameter LINE_SIZE = 64      // bytes
)(
    input clk,
    input rst,
    input [31:0] addr,
    input [31:0] wdata,
    input we,
    input re,
    output reg [31:0] rdata,
    output reg hit,
    // Interface to main memory
    output reg [31:0] mem_addr,
    output reg mem_req,
    input [31:0] mem_rdata,
    input mem_ready
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
            mem_req <= 0;
            hit_count <= 0;
            miss_count <= 0;
        end else if (re) begin
            if (valid_array[index] && tag_array[index] == tag) begin
                hit <= 1;
                rdata <= data_array[index];
                mem_req <= 0;
                hit_count <= hit_count + 1;
            end else begin
                mem_addr <= addr;
                mem_req <= 1;
                miss_count <= miss_count + 1;
                if (mem_ready) begin
                    data_array[index] <= mem_rdata;
                    tag_array[index] <= tag;
                    valid_array[index] <= 1;
                    rdata <= mem_rdata;
                    mem_req <= 0;
                    hit <= 1; // Data is now valid
                end else begin
                    hit <= 0;
                end
            end
        end else if (we) begin
            if (valid_array[index] && tag_array[index] == tag) begin
                data_array[index] <= wdata;
            end
            mem_addr <= addr;
            mem_req <= 1;
            hit <= 0;
        end else begin
            hit <= 0;
        end
    end

    // Print hit/miss counters at end of simulation
    /* initial begin
        $monitor("L3 Cache Hits: %d, Misses: %d", hit_count, miss_count);
        #1000;
        $display("L3 Cache Final Hits: %d, Misses: %d", hit_count, miss_count);
    end */
endmodule 