`timescale 1ns/1ps



module tb_RISCV_sc2;


    localparam  NUMBER_OF_CYCLES = 112;
    logic clk;
    logic rst_n;
    integer inst_cnt;
    integer timeout_cnt;
    integer err_count;
    integer fd;
    reg [8*10000-1:0] line;  // Buffer for reading lines
    int addr, expected, actual;
    int code;


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

            for (integer k = 0; k < 32; k++) begin
                if (dut.Reg_inst.registers[k] !== golden_x[k][flag]) begin
                    $display("❗ x%0d mismatch at cycle %0d: DUT = %h, Golden = %h", k, flag, dut.Reg_inst.registers[k], golden_x[k][flag]);
                    err_count = err_count + 1;
                end
            end

            for (integer k = 0; k < 256; k++) begin
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
    end
    // Reset and simulation control
    initial begin
        clk = 0;
        i = 0;
          // Open and verify Data Memory
        $display("\n--- Verifying Data Memory ---");
        fd = $fopen("./mem/golden_output2.txt", "r");
        if (fd == 0) begin
            $display("❌ ERROR: Cannot open golden_output2.txt");
            $finish;
        end

        while (!$feof(fd)) begin
            line = "";
            status = $fgets(line, fd); // Read one line
            dummy = $sscanf(line, "PC = %h, x0 = %h, x1 = %h, x2 = %h, x3 = %h, x4 = %h, x5 = %h, x6 = %h, x7 = %h, x8 = %h, x9 = %h, x10 = %h, x11 = %h, x12 = %h, x13 = %h, x14 = %h, x15 = %h, x16 = %h, x17 = %h, x18 = %h, x19 = %h, x20 = %h, x21 = %h, x22 = %h, x23 = %h>
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

            if(i < NUMBER_OF_CYCLES) begin
                golden_pc[i] = golden_pc_temp;
                for (integer j = 0; j < 32; j++) begin
                    golden_x[j][i] = golden_x_temp[j];
                end
                for (integer j = 0; j < 256; j++) begin
                    golden_dmem[j][i] = golden_dmem_temp[j];
                end
                i = i + 1;
            end

        // Now you can compare this expected result with your DUT

        end
        $fclose(fd);

        rst_n = 0;
        inst_cnt = 0;
        timeout_cnt = 0;
        err_count = 0;


        #20;
        rst_n = 1;

        // // Wait until Instruction fetch stops (Instruction bus = xxxxxxxx)
        // while (dut.Instruction_out_top !== 32'h00000063) begin
        //     @(posedge clk);
        //     inst_cnt = inst_cnt + 1;
        //     timeout_cnt = timeout_cnt + 1;

        //     if (timeout_cnt > 10000) begin
        //         $display("❗ ERROR: Simulation timed out after 10000 cycles!");
        //         $finish;
        //     end
        // end

        // $display("✅ Program execution completed after %0d instructions.", inst_cnt);



        #200;

        if (err_count == 0)
            $display("🎉 All memory contents match golden output! All tests passed.");
        else
            $display("❗ Found %0d mismatches in Data Memory.", err_count);

        $finish;
    end

endmodule
