`timescale 1ns / 1ps
module pipeline_tb;
    reg clk, rst;

    // Instantiate Pipeline_Top
    Pipeline_Top uut (
        .clk(clk),
        .rst(rst)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Reset sequence
    initial begin
        clk = 0;
        rst = 1;
        #20;
        rst = 0;
        // Do not reassert reset
    end

    // Program load for simulation (enable loader for both instructions and data memory)
    initial begin
        #5;
        $readmemh("instructions.mem", uut.main_mem.mem);
        $readmemh("memfile.hex", uut.main_mem.mem);
    end

    // Dump waveform
    initial begin
        $dumpfile("pipeline.vcd");
        $dumpvars(0, pipeline_tb);
    end

    // Monitor PC, instruction, key registers, and L1 I-Cache hit at fetch stage
    initial begin
        $display("Time\tPC\tInstr\tx3\tx4\tx6\tL1I_Hit");
        forever begin
            @(posedge clk);
            $display("%0t\t%h\t%h\t%h\t%h\t%h\t%b",
                $time,
                uut.if_pc,
                uut.if_instr,
                uut.decode_stage.reg_file.Register[3],
                uut.decode_stage.reg_file.Register[4],
                uut.decode_stage.reg_file.Register[6],
                uut.fetch_l1_hit
            );
        end
    end

    // Final state check for x6 == 42 and memory[0] == 42, memory[1] == 0x12345678, memory[2] == 0xdeadbeef
    initial begin
        #2000;
        if (uut.decode_stage.reg_file.Register[6] == 42)
            $display("PASS: x6 == 42");
        else
            $display("FAIL: x6 != 42, got %h", uut.decode_stage.reg_file.Register[6]);
        if (uut.main_mem.mem[0] == 42)
            $display("PASS: mem[0] == 42");
        else
            $display("FAIL: mem[0] != 42, got %h", uut.main_mem.mem[0]);
        if (uut.main_mem.mem[1] == 32'h12345678)
            $display("PASS: mem[1] == 0x12345678");
        else
            $display("FAIL: mem[1] != 0x12345678, got %h", uut.main_mem.mem[1]);
        if (uut.main_mem.mem[2] == 32'hdeadbeef)
            $display("PASS: mem[2] == 0xdeadbeef");
        else
            $display("FAIL: mem[2] != 0xdeadbeef, got %h", uut.main_mem.mem[2]);
        $finish;
    end

    // Print cache hit/miss statistics at end of simulation
    initial begin
        #2100;
        $display("L1 I-Cache Hits: %d, Misses: %d", uut.fetch_stage.l1_icache.hit_count, uut.fetch_stage.l1_icache.miss_count);
        $display("L1 D-Cache Hits: %d, Misses: %d", uut.memory_stage.l1_dcache.hit_count, uut.memory_stage.l1_dcache.miss_count);
        $display("Branch Predictor: correct = %d, total = %d, accuracy = %f", uut.fetch_stage.predictor_correct, uut.fetch_stage.predictor_total, uut.fetch_stage.predictor_total ? (1.0 * uut.fetch_stage.predictor_correct / uut.fetch_stage.predictor_total) : 0.0);
    end

    // Monitor pipeline state (requires exposing pipeline registers in Pipeline_top for simulation)
    /*
    initial begin
        $display("Time\tPCF\tInstrF\tPCD\tInstrD\tPCE\tInstrE\tPCM\tInstrM\tPCW\tInstrW");
        forever begin
            @(posedge clk);
            // expose these signals in Pipeline_top 
            $display("%0t\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h",
                $time,
                uut.PCF, uut.InstrF,
                uut.PCD, uut.InstrD,
                uut.PCE, uut.InstrE,
                uut.PCM, uut.InstrM,
                uut.PCW, uut.InstrW
            );
        end
    end
    */

    initial #1000 $finish;
endmodule