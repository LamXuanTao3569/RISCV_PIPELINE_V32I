`timescale 1ns/1ps

module tb_RISCV_sc2;

    localparam  NUMBER_OF_CYCLES = 112;
    reg clk;
    reg rst_n;
    integer inst_cnt;
    integer timeout_cnt;
    integer err_count;
    integer fd;
    reg [8*10000-1:0] line;  // Buffer for reading lines
    integer addr, expected, actual;
    integer code;
    integer k, j;

    integer golden_file, status;
    reg [31:0] golden_pc[0:NUMBER_OF_CYCLES-1];
    reg [31:0] golden_x[0:31][0:NUMBER_OF_CYCLES-1];
    reg [31:0] golden_dmem[0:255][0:NUMBER_OF_CYCLES-1];

    reg [31:0] golden_pc_temp;
    reg [31:0] golden_x_temp[0:31];
    reg [31:0] golden_dmem_temp[0:255];

    integer i;
    integer flag = 0;
    integer dummy;

    RISCV_Single_Cycle dut (
        .clk(clk),
        .rst_n(rst_n)
    );
	
    // Clock generation
    always #5 clk = ~clk;

    always @(posedge clk) begin
            if (dut.PC_out_top !== golden_pc[flag]) begin
                $display("❗ PC mismatch at cycle %0d: DUT = %h, Golden = %h", flag, dut.PC_out_top, golden_pc[flag]);
                err_count = err_count + 1;
            end

            for (k = 0; k < 32; k = k + 1) begin
                if (dut.Reg_inst.registers[k] !== golden_x[k][flag]) begin
                    $display("❗ x%0d mismatch at cycle %0d: DUT = %h, Golden = %h", k, flag, dut.Reg_inst.registers[k], golden_x[k][flag]);
                    err_count = err_count + 1;
                end
            end

            for (k = 0; k < 256; k = k + 1) begin
                if ( dut.DMEM_inst.memory[k] !== golden_dmem[k][flag]) begin
                    $display("❗ Dmem[%0d] mismatch at cycle %0d: DUT = %h, Golden = %h", k, flag, dut.DMEM_inst.memory[k], golden_dmem[k][flag]);
                    err_count = err_count + 1;
                end
            end
            flag = flag + 1;
    end

    initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_RISCV_sc2);
    $readmemh("./mem/imem2.hex", dut.IMEM_inst.memory);
    $readmemh("./mem/dmem_init2.hex", dut.DMEM_inst.memory);

    clk = 0;
    rst_n = 0;
    inst_cnt = 0;
    timeout_cnt = 0;
    err_count = 0;
    flag = 0;

    // Open and verify Data Memory
    $display("\n--- Verifying Data Memory ---");
    fd = $fopen("./mem/golden_output2.txt", "r");
    if (fd == 0) begin
        $display("❌ ERROR: Cannot open golden_output2.txt");
        $finish;
    end

    while (!$feof(fd)) begin
        line = "";
        status = $fgets(line, fd);
        dummy = $sscanf(line, "PC = %h, x0 = %h, x1 = %h, x2 = %h, x3 = %h, x4 = %h, x5 = %h, x6 = %h, x7 = %h, x8 = %h, x9 = %h, x10 = %h, x11 = %h, x12 = %h, x13 = %h, x14 = %h, x15 = %h, x16 = %h, x17 = %h, x18 = %h, x19 = %h, x20 = %h, x21 = %h, x22 = %h, x23 = %h, x24 = %h, x25 = %h, x26 = %h, x27 = %h, x28 = %h, x29 = %h, x30 = %h, x31 = %h, Dmem[0] = %h, Dmem[1] = %h, Dmem[2] = %h, Dmem[3] = %h, Dmem[4] = %h, Dmem[5] = %h, Dmem[6] = %h, Dmem[7] = %h, Dmem[8] = %h, Dmem[9] = %h, Dmem[10] = %h, Dmem[11] = %h, Dmem[12] = %h, Dmem[13] = %h, Dmem[14] = %h, Dmem[15] = %h, Dmem[16] = %h, Dmem[17] = %h, Dmem[18] = %h, Dmem[19] = %h, Dmem[20] = %h, Dmem[21] = %h, Dmem[22] = %h, Dmem[23] = %h, Dmem[24] = %h, Dmem[25] = %h, Dmem[26] = %h, Dmem[27] = %h, Dmem[28] = %h, Dmem[29] = %h, Dmem[30] = %h, Dmem[31] = %h, Dmem[32] = %h, Dmem[33] = %h, Dmem[34] = %h, Dmem[35] = %h, Dmem[36] = %h, Dmem[37] = %h, Dmem[38] = %h, Dmem[39] = %h, Dmem[40] = %h, Dmem[41] = %h, Dmem[42] = %h, Dmem[43] = %h, Dmem[44] = %h, Dmem[45] = %h, Dmem[46] = %h, Dmem[47] = %h, Dmem[48] = %h, Dmem[49] = %h, Dmem[50] = %h, Dmem[51] = %h, Dmem[52] = %h, Dmem[53] = %h, Dmem[54] = %h, Dmem[55] = %h, Dmem[56] = %h, Dmem[57] = %h, Dmem[58] = %h, Dmem[59] = %h, Dmem[60] = %h, Dmem[61] = %h, Dmem[62] = %h, Dmem[63] = %h, Dmem[64] = %h, Dmem[65] = %h, Dmem[66] = %h, Dmem[67] = %h, Dmem[68] = %h, Dmem[69] = %h, Dmem[70] = %h, Dmem[71] = %h, Dmem[72] = %h, Dmem[73] = %h, Dmem[74] = %h, Dmem[75] = %h, Dmem[76] = %h, Dmem[77] = %h, Dmem[78] = %h, Dmem[79] = %h, Dmem[80] = %h, Dmem[81] = %h, Dmem[82] = %h, Dmem[83] = %h, Dmem[84] = %h, Dmem[85] = %h, Dmem[86] = %h, Dmem[87] = %h, Dmem[88] = %h, Dmem[89] = %h, Dmem[90] = %h, Dmem[91] = %h, Dmem[92] = %h, Dmem[93] = %h, Dmem[94] = %h, Dmem[95] = %h, Dmem[96] = %h, Dmem[97] = %h, Dmem[98] = %h, Dmem[99] = %h, Dmem[100] = %h, Dmem[101] = %h, Dmem[102] = %h, Dmem[103] = %h, Dmem[104] = %h, Dmem[105] = %h, Dmem[106] = %h, Dmem[107] = %h, Dmem[108] = %h, Dmem[109] = %h, Dmem[110] = %h, Dmem[111] = %h, Dmem[112] = %h, Dmem[113] = %h, Dmem[114] = %h, Dmem[115] = %h, Dmem[116] = %h, Dmem[117] = %h, Dmem[118] = %h, Dmem[119] = %h, Dmem[120] = %h, Dmem[121] = %h, Dmem[122] = %h, Dmem[123] = %h, Dmem[124] = %h, Dmem[125] = %h, Dmem[126] = %h, Dmem[127] = %h, Dmem[128] = %h, Dmem[129] = %h, Dmem[130] = %h, Dmem[131] = %h, Dmem[132] = %h, Dmem[133] = %h, Dmem[134] = %h, Dmem[135] = %h, Dmem[136] = %h, Dmem[137] = %h, Dmem[138] = %h, Dmem[139] = %h, Dmem[140] = %h, Dmem[141] = %h, Dmem[142] = %h, Dmem[143] = %h, Dmem[144] = %h, Dmem[145] = %h, Dmem[146] = %h, Dmem[147] = %h, Dmem[148] = %h, Dmem[149] = %h, Dmem[150] = %h, Dmem[151] = %h, Dmem[152] = %h, Dmem[153] = %h, Dmem[154] = %h, Dmem[155] = %h, Dmem[156] = %h, Dmem[157] = %h, Dmem[158] = %h, Dmem[159] = %h, Dmem[160] = %h, Dmem[161] = %h, Dmem[162] = %h, Dmem[163] = %h, Dmem[164] = %h, Dmem[165] = %h, Dmem[166] = %h, Dmem[167] = %h, Dmem[168] = %h, Dmem[169] = %h, Dmem[170] = %h, Dmem[171] = %h, Dmem[172] = %h, Dmem[173] = %h, Dmem[174] = %h, Dmem[175] = %h, Dmem[176] = %h, Dmem[177] = %h, Dmem[178] = %h, Dmem[179] = %h, Dmem[180] = %h, Dmem[181] = %h, Dmem[182] = %h, Dmem[183] = %h, Dmem[184] = %h, Dmem[185] = %h, Dmem[186] = %h, Dmem[187] = %h, Dmem[188] = %h, Dmem[189] = %h, Dmem[190] = %h, Dmem[191] = %h, Dmem[192] = %h, Dmem[193] = %h, Dmem[194] = %h, Dmem[195] = %h, Dmem[196] = %h, Dmem[197] = %h, Dmem[198] = %h, Dmem[199] = %h, Dmem[200] = %h, Dmem[201] = %h, Dmem[202] = %h, Dmem[203] = %h, Dmem[204] = %h, Dmem[205] = %h, Dmem[206] = %h, Dmem[207] = %h, Dmem[208] = %h, Dmem[209] = %h, Dmem[210] = %h, Dmem[211] = %h, Dmem[212] = %h, Dmem[213] = %h, Dmem[214] = %h, Dmem[215] = %h, Dmem[216] = %h, Dmem[217] = %h, Dmem[218] = %h, Dmem[219] = %h, Dmem[220] = %h, Dmem[221] = %h, Dmem[222] = %h, Dmem[223] = %h, Dmem[224] = %h, Dmem[225] = %h, Dmem[226] = %h, Dmem[227] = %h, Dmem[228] = %h, Dmem[229] = %h, Dmem[230] = %h, Dmem[231] = %h, Dmem[232] = %h, Dmem[233] = %h, Dmem[234] = %h, Dmem[235] = %h, Dmem[236] = %h, Dmem[237] = %h, Dmem[238] = %h, Dmem[239] = %h, Dmem[240] = %h, Dmem[241] = %h, Dmem[242] = %h, Dmem[243] = %h, Dmem[244] = %h, Dmem[245] = %h, Dmem[246] = %h, Dmem[247] = %h, Dmem[248] = %h, Dmem[249] = %h, Dmem[250] = %h, Dmem[251] = %h, Dmem[252] = %h, Dmem[253] = %h, Dmem[254] = %h, Dmem[255] = %h",
            golden_pc_temp, golden_x_temp[0], golden_x_temp[1], golden_x_temp[2], golden_x_temp[3], golden_x_temp[4], golden_x_temp[5],
            golden_x_temp[6], golden_x_temp[7], golden_x_temp[8], golden_x_temp[9], golden_x_temp[10], golden_x_temp[11],
            golden_x_temp[12], golden_x_temp[13], golden_x_temp[14], golden_x_temp[15], golden_x_temp[16], golden_x_temp[17],
            golden_x_temp[18], golden_x_temp[19], golden_x_temp[20], golden_x_temp[21], golden_x_temp[22], golden_x_temp[23],
            golden_x_temp[24], golden_x_temp[25], golden_x_temp[26], golden_x_temp[27], golden_x_temp[28], golden_x_temp[29],
            golden_x_temp[30], golden_x_temp[31],
            golden_dmem_temp[0], golden_dmem_temp[1], golden_dmem_temp[2], golden_dmem_temp[3], golden_dmem_temp[4],
            golden_dmem_temp[5], golden_dmem_temp[6], golden_dmem_temp[7], golden_dmem_temp[8], golden_dmem_temp[9],
            golden_dmem_temp[10], golden_dmem_temp[11], golden_dmem_temp[12], golden_dmem_temp[13], golden_dmem_temp[14],
            golden_dmem_temp[15], golden_dmem_temp[16], golden_dmem_temp[17], golden_dmem_temp[18], golden_dmem_temp[19],
            golden_dmem_temp[20], golden_dmem_temp[21], golden_dmem_temp[22], golden_dmem_temp[23], golden_dmem_temp[24],
            golden_dmem_temp[25], golden_dmem_temp[26], golden_dmem_temp[27], golden_dmem_temp[28], golden_dmem_temp[29],
            golden_dmem_temp[30], golden_dmem_temp[31], golden_dmem_temp[32], golden_dmem_temp[33], golden_dmem_temp[34],
            golden_dmem_temp[35], golden_dmem_temp[36], golden_dmem_temp[37], golden_dmem_temp[38], golden_dmem_temp[39],
            golden_dmem_temp[40], golden_dmem_temp[41], golden_dmem_temp[42], golden_dmem_temp[43], golden_dmem_temp[44],
            golden_dmem_temp[45], golden_dmem_temp[46], golden_dmem_temp[47], golden_dmem_temp[48], golden_dmem_temp[49],
            golden_dmem_temp[50], golden_dmem_temp[51], golden_dmem_temp[52], golden_dmem_temp[53], golden_dmem_temp[54],
            golden_dmem_temp[55], golden_dmem_temp[56], golden_dmem_temp[57], golden_dmem_temp[58], golden_dmem_temp[59],
            golden_dmem_temp[60], golden_dmem_temp[61], golden_dmem_temp[62], golden_dmem_temp[63], golden_dmem_temp[64],
            golden_dmem_temp[65], golden_dmem_temp[66], golden_dmem_temp[67], golden_dmem_temp[68], golden_dmem_temp[69],
            golden_dmem_temp[70], golden_dmem_temp[71], golden_dmem_temp[72], golden_dmem_temp[73], golden_dmem_temp[74],
            golden_dmem_temp[75], golden_dmem_temp[76], golden_dmem_temp[77], golden_dmem_temp[78], golden_dmem_temp[79],
            golden_dmem_temp[80], golden_dmem_temp[81], golden_dmem_temp[82], golden_dmem_temp[83], golden_dmem_temp[84],
            golden_dmem_temp[85], golden_dmem_temp[86], golden_dmem_temp[87], golden_dmem_temp[88], golden_dmem_temp[89],
            golden_dmem_temp[90], golden_dmem_temp[91], golden_dmem_temp[92], golden_dmem_temp[93], golden_dmem_temp[94],
            golden_dmem_temp[95], golden_dmem_temp[96], golden_dmem_temp[97], golden_dmem_temp[98], golden_dmem_temp[99],
            golden_dmem_temp[100], golden_dmem_temp[101], golden_dmem_temp[102], golden_dmem_temp[103], golden_dmem_temp[104],
            golden_dmem_temp[105], golden_dmem_temp[106], golden_dmem_temp[107], golden_dmem_temp[108], golden_dmem_temp[109],
            golden_dmem_temp[110], golden_dmem_temp[111], golden_dmem_temp[112], golden_dmem_temp[113], golden_dmem_temp[114],
            golden_dmem_temp[115], golden_dmem_temp[116], golden_dmem_temp[117], golden_dmem_temp[118], golden_dmem_temp[119],
            golden_dmem_temp[120], golden_dmem_temp[121], golden_dmem_temp[122], golden_dmem_temp[123], golden_dmem_temp[124],
            golden_dmem_temp[125], golden_dmem_temp[126], golden_dmem_temp[127], golden_dmem_temp[128], golden_dmem_temp[129],
            golden_dmem_temp[130], golden_dmem_temp[131], golden_dmem_temp[132], golden_dmem_temp[133], golden_dmem_temp[134],
            golden_dmem_temp[135], golden_dmem_temp[136], golden_dmem_temp[137], golden_dmem_temp[138], golden_dmem_temp[139],
            golden_dmem_temp[140], golden_dmem_temp[141], golden_dmem_temp[142], golden_dmem_temp[143], golden_dmem_temp[144],
            golden_dmem_temp[145], golden_dmem_temp[146], golden_dmem_temp[147], golden_dmem_temp[148], golden_dmem_temp[149],
            golden_dmem_temp[150], golden_dmem_temp[151], golden_dmem_temp[152], golden_dmem_temp[153], golden_dmem_temp[154],
            golden_dmem_temp[155], golden_dmem_temp[156], golden_dmem_temp[157], golden_dmem_temp[158], golden_dmem_temp[159],
            golden_dmem_temp[160], golden_dmem_temp[161], golden_dmem_temp[162], golden_dmem_temp[163], golden_dmem_temp[164],
            golden_dmem_temp[165], golden_dmem_temp[166], golden_dmem_temp[167], golden_dmem_temp[168], golden_dmem_temp[169],
            golden_dmem_temp[170], golden_dmem_temp[171], golden_dmem_temp[172], golden_dmem_temp[173], golden_dmem_temp[174],
            golden_dmem_temp[175], golden_dmem_temp[176], golden_dmem_temp[177], golden_dmem_temp[178], golden_dmem_temp[179],
            golden_dmem_temp[180], golden_dmem_temp[181], golden_dmem_temp[182], golden_dmem_temp[183], golden_dmem_temp[184],
            golden_dmem_temp[185], golden_dmem_temp[186], golden_dmem_temp[187], golden_dmem_temp[188], golden_dmem_temp[189],
            golden_dmem_temp[190], golden_dmem_temp[191], golden_dmem_temp[192], golden_dmem_temp[193], golden_dmem_temp[194],
            golden_dmem_temp[195], golden_dmem_temp[196], golden_dmem_temp[197], golden_dmem_temp[198], golden_dmem_temp[199],
            golden_dmem_temp[200], golden_dmem_temp[201], golden_dmem_temp[202], golden_dmem_temp[203], golden_dmem_temp[204],
            golden_dmem_temp[205], golden_dmem_temp[206], golden_dmem_temp[207], golden_dmem_temp[208], golden_dmem_temp[209],
            golden_dmem_temp[210], golden_dmem_temp[211], golden_dmem_temp[212], golden_dmem_temp[213], golden_dmem_temp[214],
            golden_dmem_temp[215], golden_dmem_temp[216], golden_dmem_temp[217], golden_dmem_temp[218], golden_dmem_temp[219],
            golden_dmem_temp[220], golden_dmem_temp[221], golden_dmem_temp[222], golden_dmem_temp[223], golden_dmem_temp[224],
            golden_dmem_temp[225], golden_dmem_temp[226], golden_dmem_temp[227], golden_dmem_temp[228], golden_dmem_temp[229],
            golden_dmem_temp[230], golden_dmem_temp[231], golden_dmem_temp[232], golden_dmem_temp[233], golden_dmem_temp[234],
            golden_dmem_temp[235], golden_dmem_temp[236], golden_dmem_temp[237], golden_dmem_temp[238], golden_dmem_temp[239],
            golden_dmem_temp[240], golden_dmem_temp[241], golden_dmem_temp[242], golden_dmem_temp[243], golden_dmem_temp[244],
            golden_dmem_temp[245], golden_dmem_temp[246], golden_dmem_temp[247], golden_dmem_temp[248], golden_dmem_temp[249],
            golden_dmem_temp[250], golden_dmem_temp[251], golden_dmem_temp[252], golden_dmem_temp[253], golden_dmem_temp[254],
            golden_dmem_temp[255]);

        if (i < NUMBER_OF_CYCLES) begin
            golden_pc[i] = golden_pc_temp;
            for (j = 0; j < 32; j++) begin
                golden_x[j][i] = golden_x_temp[j];
            end
            for (j = 0; j < 256; j++) begin
                golden_dmem[j][i] = golden_dmem_temp[j];
            end
            i = i + 1;
        end
    end
    $fclose(fd);

    #20;
    rst_n = 1;

    // Wait until the infinite loop is reached (Instruction = 00000063)
    while (dut.Instruction_out_top !== 32'h00000063) begin
        @(posedge clk);
        inst_cnt = inst_cnt + 1;
        timeout_cnt = timeout_cnt + 1;

        if (timeout_cnt > 50000) begin
            $display("❗ ERROR: Simulation timed out after 50000 cycles!");
            $display("Current PC = %h, Instruction = %h", dut.PC_out_top, dut.Instruction_out_top);
            $finish;
        end
        
        // Debug output every 1000 cycles
        if (inst_cnt % 1000 == 0) begin
            $display("Cycle %0d: PC = %h, Instruction = %h", inst_cnt, dut.PC_out_top, dut.Instruction_out_top);
            $display("  PC Write Enable = %b, Branch Taken = %b", dut.pc_write_en, dut.ex_pc_src);
            $display("  IF/ID Write Enable = %b, ID/EX Bubble = %b", dut.if_id_write_en, dut.id_ex_bubble);
        end
        
        // Debug output when branch is taken
        if (dut.ex_pc_src && dut.Instruction_out_top[6:0] == 7'b1100011) begin
            $display("Branch taken at cycle %0d: PC = %h, Target = %h", inst_cnt, dut.PC_out_top, dut.ex_pc_target);
            $display("  Instruction = %h, funct3 = %b", dut.Instruction_out_top, dut.Instruction_out_top[14:12]);
            $display("  IF/ID Instruction = %h, funct3 = %b", dut.if_id_instr, dut.if_id_instr[14:12]);
            $display("  Branch Flush = %b, IF/ID Write = %b", dut.branch_flush, dut.if_id_write_en);
            $display("  Expected funct3 for 0xfeb518e3 should be 110, but got %b", dut.Instruction_out_top[14:12]);
            $display("  Instruction at PC/4 = %d: %h", dut.PC_out_top >> 2, dut.IMEM_inst.memory[dut.PC_out_top >> 2]);
            $display("  Raw instruction bits 14:12 = %b", dut.IMEM_inst.memory[dut.PC_out_top >> 2][14:12]);
            $display("  This is a BNE instruction (funct3=001), not BLTU (funct3=110)");
            $display("  Branch target calculation: PC(%h) + immediate = %h", dut.PC_out_top, dut.ex_pc_target);
            $display("  BNE compares x10 vs x22: x10=%h, x22=%h", dut.Reg_inst.registers[10], dut.Reg_inst.registers[22]);
        end
        
        // Debug output when PC is at the store instruction
        if (dut.PC_out_top == 32'h78) begin
            $display("PC at 0x78 at cycle %0d: Instruction = %h", inst_cnt, dut.Instruction_out_top);
            $display("  PC Write Enable = %b, IF/ID Write = %b, ID/EX Bubble = %b", dut.pc_write_en, dut.if_id_write_en, dut.id_ex_bubble);
            $display("  Branch Taken = %b, Exception = %b", dut.ex_pc_src, dut.exception);
        end
        
        // Debug output when PC gets stuck
        if (inst_cnt > 10000 && dut.PC_out_top == 32'h78) begin
            $display("PC stuck at 0x78 at cycle %0d", inst_cnt);
            $display("  Current instruction = %h", dut.Instruction_out_top);
            $display("  PC Write Enable = %b, IF/ID Write = %b, ID/EX Bubble = %b", dut.pc_write_en, dut.if_id_write_en, dut.id_ex_bubble);
            $display("  Branch Taken = %b, Exception = %b", dut.ex_pc_src, dut.exception);
        end
        
        // Debug output for last few cycles before timeout
        if (inst_cnt > 9995) begin
            $display("Cycle %0d: PC = %h, Instruction = %h", inst_cnt, dut.PC_out_top, dut.Instruction_out_top);
            $display("  PC Write Enable = %b, IF/ID Write = %b, ID/EX Bubble = %b", dut.pc_write_en, dut.if_id_write_en, dut.id_ex_bubble);
        end
    end

    $display("✅ Program execution completed after %0d instructions.", inst_cnt);

    // Run a few more cycles to ensure the loop is stable
    repeat (5) @(posedge clk);

    if (err_count == 0)
        $display("🎉 All memory contents match golden output! All tests passed.");
    else
        $display("❗ Found %0d mismatches in Data Memory.", err_count);

    $finish;
end

endmodule
