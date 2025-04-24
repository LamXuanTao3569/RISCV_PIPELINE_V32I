
module Data_Memory(clk,rst,WE,WD,A,RD);

    input clk,rst,WE;
    input [31:0]A,WD;
    output [31:0]RD;

    reg [31:0] mem [1023:0];

    always @ (posedge clk)
    begin
        if(WE)
            mem[A[31:2]] <= WD; // Word-aligned: A chia cho 4
    end

    assign RD = (~rst) ? 32'd0 : mem[A[31:2]]; // Word-aligned

    initial begin
        mem[0] = 32'h00000000;
		  mem[4] = 32'h0000000a; // Cập nhật cho testbench: địa chỉ 16 (word 4)
        //mem[40] = 32'h00000002;
    end


endmodule
