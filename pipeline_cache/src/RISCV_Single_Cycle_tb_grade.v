`timescale 1ns/1ps

module tb_RISCV_Single_Cycle;
    logic clk;
    logic rst_n;
    integer inst_cnt;
    integer timeout_cnt;
    integer err_count;
    integer fd;
    integer fd_dump;
    integer i;
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

        $readmemh("./mem/imem.hex", dut.IMEM_inst.memory);
        $readmemh("./mem/dmem_init.hex", dut.DMEM_inst.memory);

        clk = 0;
        rst_n = 0;
        inst_cnt = 0;
        timeout_cnt = 0;
        err_count = 0;

        #20;
        rst_n = 1;

        // Wait until the infinite loop is reached (Instruction = 00000063)
        while (dut.Instruction_out_top !== 32'h00000063) begin
            @(posedge clk);
            inst_cnt = inst_cnt + 1;
            timeout_cnt = timeout_cnt + 1;

            if (timeout_cnt > 10000) begin
                $display("❗ ERROR: Simulation timed out after 10000 cycles!");
                $finish;
            end
        end

        $display("✅ Program execution completed after %0d instructions.", inst_cnt);

        // Check if golden_output.txt exists for comparison
        fd = $fopen("./mem/golden_output.txt", "r");
        if (fd != 0) begin
            $display("\n--- Verifying Data Memory ---");
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
        end else begin
            $display("No golden_output.txt found. Generating golden output only.");
        end

        // Dump golden output for future reference
        fd_dump = $fopen("mem/golden_output.txt", "w");
        if (fd_dump == 0) begin
            $display("ERROR: Cannot open mem/golden_output.txt for writing.");
        end else begin
            $fwrite(fd_dump, "PC = %h", dut.PC_out_top);
            for (i = 0; i < 32; i = i + 1)
                $fwrite(fd_dump, ", x%0d = %h", i, dut.Reg_inst.registers[i]);
            for (i = 0; i < 256; i = i + 1)
                $fwrite(fd_dump, ", Dmem[%0d] = %h", i, dut.DMEM_inst.memory[i]);
            $fwrite(fd_dump, "\n");
            $fclose(fd_dump);
            $display("Golden output dumped to mem/golden_output.txt");
        end

        if (err_count == 0)
            $display("🎉 All memory contents match golden output! All tests passed.");
        else
            $display("❗ Found %0d mismatches in Data Memory.", err_count);

        $finish;
    end
endmodule