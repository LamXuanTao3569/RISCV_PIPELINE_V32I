module hazard_unit(
    input clk, rst, RegWriteE_in, RegWriteM, RegWriteW, ResultSrcE_0, PCSrcE,
    input [4:0] RD_M, RD_W, Rs1_E, Rs2_E, RS1D, RS2D, RDE,
    output reg [1:0] ForwardA_E, ForwardB_E,
    output reg StallF, StallD, FlushD, FlushE
);

    // Stalling for load-use hazard
    wire lwStall;
    assign lwStall = ResultSrcE_0 && RegWriteE_in && ((RS1D == RDE) || (RS2D == RDE));

    // Forwarding logic (combinational)
    always @(*) begin
        // ForwardA_E logic
        if (RegWriteE_in && (RDE != 5'h00) && (RDE == Rs1_E))
            ForwardA_E = 2'b10;
        else if (RegWriteM && (RD_M != 5'h00) && (RD_M == Rs1_E))
            ForwardA_E = 2'b01;
        else
            ForwardA_E = 2'b00;

        // ForwardB_E logic
        if (RegWriteE_in && (RDE != 5'h00) && (RDE == Rs2_E))
            ForwardB_E = 2'b10;
        else if (RegWriteM && (RD_M != 5'h00) && (RD_M == Rs2_E))
            ForwardB_E = 2'b01;
        else
            ForwardB_E = 2'b00;
    end

    // Stalling and flushing logic
    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            StallF <= 1'b0;
            StallD <= 1'b0;
            FlushD <= 1'b0;
            FlushE <= 1'b0;
        end
        else begin
            // Stalling logic
            StallF <= lwStall;
            StallD <= lwStall;

            // Flushing logic
            FlushD <= PCSrcE;
            FlushE <= PCSrcE;
        end
    end
endmodule