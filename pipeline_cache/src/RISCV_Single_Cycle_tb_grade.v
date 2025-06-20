`timescale 1ns/1ps

module tb_RISCV_Single_Cycle;
    logic clk;
    logic rst_n;
    integer inst_cnt;
    integer timeout_cnt;
    integer err_count;
    integer fd;
    reg [8*128-1:0] line;  // Buffer for reading lines
    int addr, expected, actual;
    int code;

    RISCV_Single_Cycle dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Reset and simulation control
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_RISCV_Single_Cycle);

//      initial
//      begin
        $readmemh("./mem/imem.hex", dut.IMEM_inst.memory);

        $readmemh("./mem/dmem_init.hex", dut.DMEM_inst.memory);

//      end

        clk = 0;
        rst_n = 0;
        inst_cnt = 0;
        timeout_cnt = 0;
        err_count = 0;

        #20;
        rst_n = 1;

        // Wait until Instruction fetch stops (Instruction bus = xxxxxxxx)
        while (dut.Instruction_out_top !== 32'hxxxxxxxx) begin
            @(posedge clk);
            inst_cnt = inst_cnt + 1;
            timeout_cnt = timeout_cnt + 1;

            if (timeout_cnt > 10000) begin
                $display("❗ ERROR: Simulation timed out after 10000 cycles!");
                $finish;
            end
        end

        $display("✅ Program execution completed after %0d instructions.", inst_cnt);

        // Open and verify Data Memory
        $display("\n--- Verifying Data Memory ---");

        fd = $fopen("./mem/golden_output.txt", "r");
        if (fd == 0) begin
            $display("❌ ERROR: Cannot open ./golden_output.txt");
            $finish;
        end

        while (!$feof(fd)) begin
            line = "";
            code = $fgets(line, fd);

            if (code > 0) begin
                if ($sscanf(line, "Dmem[%d] = %d", addr, expected) == 2) begin
                    actual = dut.DMEM_inst.memory[addr >> 2];

                    if (actual !== expected) begin
                        $display("❌ Mismatch at Dmem[%0d]: expected %0d, got %0d", addr, expected, actual);
                        err_count++;
                    end else begin
                        $display("✅ Dmem[%0d] = %0d OK", addr, actual);
                    end
                end
            end
        end

        $fclose(fd);

        if (err_count == 0)
            $display("🎉 All memory contents match golden output! All tests passed.");
        else
            $display("❗ Found %0d mismatches in Data Memory.", err_count);

        $finish;
    end
endmodule
