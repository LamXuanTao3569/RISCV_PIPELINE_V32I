module tb_riscv_single_cycle;
    reg clk, reset;
    wire [31:0] pc, alu_result;

    riscv_single dut (.clk(clk), .reset(reset), .pc(pc), .alu_result(alu_result));

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Chu kỳ 10ns
    end

    initial begin
        reset = 1;
        #10 reset = 0;
        #50 $display("x3 = %d", dut.rf.regs[3]);
        $finish;
    end

    initial $monitor("Time=%0t, PC=%h, ALU Result=%h", $time, pc, alu_result);
endmodule
