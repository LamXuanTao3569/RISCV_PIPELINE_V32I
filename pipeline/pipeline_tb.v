module tb;
    reg clk = 0, rst;
    
    Pipeline_top dut (
        .clk(clk),
        .rst(rst)
    );
    
    always begin
        #50 clk = ~clk;
    end
    
    integer log_file;
    
    initial begin
        log_file = $fopen("pipeline_log.txt", "w");
        $fwrite(log_file, "Pipeline Execution Log\n");
        $fwrite(log_file, "=====================\n");

        rst = 1;
        $fwrite(log_file, "Time=%0t | Reset asserted\n", $time);
        #200 rst = 0;
        $fwrite(log_file, "Time=%0t | Reset deasserted\n", $time);

        // Chạy đủ lâu để thực thi tất cả các lệnh
        // Có 9 lệnh, mỗi lệnh mất 5 chu kỳ, nhưng do pipeline overlap, cần 9+4=13 chu kỳ = 1300ns
        #1300;

        // Kiểm tra giá trị thanh ghi
        if (dut.Decode.rf.Register[1] == 32'h0000000a &&  // x1 = 10
            dut.Decode.rf.Register[2] == 32'h00000014 &&  // x2 = 20
            dut.Decode.rf.Register[3] == 32'h0000001e) begin  // x3 = 30
            $display("Test PASS: x1=%h (%b), x2=%h (%b), x3=%h (%b)",
                     dut.Decode.rf.Register[1], dut.Decode.rf.Register[1],
                     dut.Decode.rf.Register[2], dut.Decode.rf.Register[2],
                     dut.Decode.rf.Register[3], dut.Decode.rf.Register[3]);
            $fwrite(log_file, "Test PASS: x1=%h (%b), x2=%h (%b), x3=%h (%b)\n",
                     dut.Decode.rf.Register[1], dut.Decode.rf.Register[1],
                     dut.Decode.rf.Register[2], dut.Decode.rf.Register[2],
                     dut.Decode.rf.Register[3], dut.Decode.rf.Register[3]);
        end else begin
            $display("Test FAIL: x1=%h (%b), x2=%h (%b), x3=%h (%b)",
                     dut.Decode.rf.Register[1], dut.Decode.rf.Register[1],
                     dut.Decode.rf.Register[2], dut.Decode.rf.Register[2],
                     dut.Decode.rf.Register[3], dut.Decode.rf.Register[3]);
            $fwrite(log_file, "Test FAIL: x1=%h (%b), x2=%h (%b), x3=%h (%b)\n",
                     dut.Decode.rf.Register[1], dut.Decode.rf.Register[1],
                     dut.Decode.rf.Register[2], dut.Decode.rf.Register[2],
                     dut.Decode.rf.Register[3], dut.Decode.rf.Register[3]);
        end

        $fclose(log_file);
        $finish;
    end
    
    initial begin
        $monitor("Time=%0t | Fetch: InstrD=%h (%b) PCD=%h | Decode: RegWriteE=%b ALUSrcE=%b MemWriteE=%b ResultSrcE=%b BranchE=%b Jump=%b RD1_E=%h RD2_E=%h Imm_Ext_E=%h | Execute: ALU_ResultE=%h PCSrcE=%b | Memory: ALU_ResultM=%h WriteDataM=%h ReadDataW=%h | Writeback: ResultW=%h x1=%h x2=%h x3=%h",
                 $time,
                 dut.InstrD, dut.InstrD, dut.PCD,
                 dut.RegWriteE, dut.ALUSrcE, dut.MemWriteE, dut.ResultSrcE, dut.BranchE, dut.Jump,
                 dut.RD1_E, dut.RD2_E, dut.Imm_Ext_E,
                 dut.Execute.ALU_ResultE, dut.PCSrcE,
                 dut.ALU_ResultM, dut.WriteDataM, dut.ReadDataW,
                 dut.ResultW,
                 dut.Decode.rf.Register[1],
                 dut.Decode.rf.Register[2],
                 dut.Decode.rf.Register[3]);
    end
    
    always @(posedge clk) begin
        $fwrite(log_file, "Time=%0t | Fetch: InstrD=%h (%b) PCD=%h | Decode: RegWriteE=%b ALUSrcE=%b MemWriteE=%b ResultSrcE=%b BranchE=%b Jump=%b RD1_E=%h RD2_E=%h Imm_Ext_E=%h | Execute: ALU_ResultE=%h PCSrcE=%b | Memory: ALU_ResultM=%h WriteDataM=%h ReadDataW=%h | Writeback: ResultW=%h x1=%h x2=%h x3=%h\n",
                 $time,
                 dut.InstrD, dut.InstrD, dut.PCD,
                 dut.RegWriteE, dut.ALUSrcE, dut.MemWriteE, dut.ResultSrcE, dut.BranchE, dut.Jump,
                 dut.RD1_E, dut.RD2_E, dut.Imm_Ext_E,
                 dut.Execute.ALU_ResultE, dut.PCSrcE,
                 dut.ALU_ResultM, dut.WriteDataM, dut.ReadDataW,
                 dut.ResultW,
                 dut.Decode.rf.Register[1],
                 dut.Decode.rf.Register[2],
                 dut.Decode.rf.Register[3]);
    end
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end
endmodule