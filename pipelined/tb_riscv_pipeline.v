module tb_riscv_pipeline;
    reg clk, reset;
    wire [31:0] pc, alu_result;

    riscv_pipeline dut (.clk(clk), .reset(reset), .pc(pc), .alu_result(alu_result));

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #10 reset = 0;
        #1000 $finish; // Tăng thời gian mô phỏng
    end

    initial begin
        $monitor("Time=%0t | PC=%h | IF/ID_Inst=%h | ID/EX_Reg1=%d | ID/EX_Reg2=%d | EX/MEM_ALU=%h | MEM/WB_Result=%h | x3=%d | x5=%d",
                 $time, pc, dut.if_inst.instr, dut.id_inst.reg1, dut.id_inst.reg2, 
                 dut.ex_inst.ex_mem_alu_result, dut.mem_inst.mem_wb_result, 
                 dut.id_inst.regs.regs[3], dut.id_inst.regs.regs[5]);
    end

    // Test từng giai đoạn độc lập
    initial begin
        // Test IF stage
        $display("Testing IF Stage...");
        #20;
        if (dut.if_inst.pc == 32'h00000004 && dut.if_inst.instr == 32'h00500093)
            $display("IF Stage PASS: PC=%h, Instr=%h", dut.if_inst.pc, dut.if_inst.instr);
        else
            $display("IF Stage FAIL: PC=%h, Instr=%h", dut.if_inst.pc, dut.if_inst.instr);

        // Test ID stage
        #20;
        if (dut.id_inst.reg1 == 0 && dut.id_inst.reg2 == 0 && dut.id_inst.opcode == 7'h13)
            $display("ID Stage PASS: Reg1=%d, Reg2=%d, Opcode=%h", dut.id_inst.reg1, dut.id_inst.reg2, dut.id_inst.opcode);
        else
            $display("ID Stage FAIL: Reg1=%d, Reg2=%d, Opcode=%h", dut.id_inst.reg1, dut.id_inst.reg2, dut.id_inst.opcode);

        // Test EX stage
        #20;
        if (dut.ex_inst.ex_mem_alu_result == 32'h00000005)
            $display("EX Stage PASS: ALU_Result=%h", dut.ex_inst.ex_mem_alu_result);
        else
            $display("EX Stage FAIL: ALU_Result=%h", dut.ex_inst.ex_mem_alu_result);

        // Test MEM stage
        #20;
        if (dut.mem_inst.mem_wb_result == 32'h00000005)
            $display("MEM Stage PASS: MEM_Result=%h", dut.mem_inst.mem_wb_result);
        else
            $display("MEM Stage FAIL: MEM_Result=%h", dut.mem_inst.mem_wb_result);

        // Test WB stage
        #20;
        if (dut.wb_inst.mem_wb_result_in == 32'h00000005 && dut.id_inst.regs.regs[1] == 5)
            $display("WB Stage PASS: WB_Result=%h, x1=%d", dut.wb_inst.mem_wb_result_in, dut.id_inst.regs.regs[1]);
        else
            $display("WB Stage FAIL: WB_Result=%h, x1=%d", dut.wb_inst.mem_wb_result_in, dut.id_inst.regs.regs[1]);
    end
endmodule