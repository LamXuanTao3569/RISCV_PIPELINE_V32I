`timescale 1ns / 1ps
module tb;
    reg clk, rst;
    wire [31:0] InstrD, RD1_E, RD2_E, ALU_ResultM, ReadDataW, ResultW;
    wire RegWriteE, MemWriteE, PCSrcE;
    wire [1:0] ForwardA_E, ForwardB_E;

    // Instantiate Pipeline_Top
    Pipeline_top uut (
        .clk(clk),
        .rst(rst)
    );

    // Clock generation
    always begin
        clk = 0;
        #5;
        clk = 1;
        #5;
    end

    // Test sequence
    initial begin
        // Initialize waveform dump
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);

        // Reset sequence
        rst = 0;
        #20;  // Hold reset for 4 clock cycles

        // Release reset
        rst = 1;
        #1000;  // Run simulation for 1000ns

        // End simulation
        $finish;
    end

    // Monitor key signals
    initial begin
        $monitor("Time=%0t rst=%b InstrD=%h RD1_E=%h RD2_E=%h ALU_ResultM=%h ReadDataW=%h ResultW=%h RegWriteE=%b MemWriteE=%b PCSrcE=%b ForwardA_E=%b ForwardB_E=%b",
                 $time, rst, uut.InstrD, uut.RD1_E, uut.RD2_E, uut.ALU_ResultM, uut.ReadDataW, uut.ResultW, 
                 uut.RegWriteE, uut.MemWriteE, uut.PCSrcE, uut.ForwardA_E, uut.ForwardB_E);
    end
endmodule