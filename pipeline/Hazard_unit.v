module hazard_unit(rst, RegWriteM, RegWriteW, RD_M, RD_W, Rs1_E, Rs2_E, RS1D, RS2D, RDE, ResultSrcE_0, PCSrcE, ForwardAE, ForwardBE, StallF, StallD, FlushD, FlushE);
    // Declaration of I/Os
    input rst, RegWriteM, RegWriteW, ResultSrcE_0, PCSrcE;
    input [4:0] RD_M, RD_W, Rs1_E, Rs2_E, RS1D, RS2D, RDE;
    output [1:0] ForwardAE, ForwardBE;
    output StallF, StallD, FlushD, FlushE;

    // Forwarding logic
    assign ForwardAE = (rst == 1'b0) ? 2'b00 : 
                       ((RegWriteM == 1'b1) & (RD_M != 5'h00) & (RD_M == Rs1_E)) ? 2'b10 :
                       ((RegWriteW == 1'b1) & (RD_W != 5'h00) & (RD_W == Rs1_E)) ? 2'b01 : 2'b00;
                       
    assign ForwardBE = (rst == 1'b0) ? 2'b00 : 
                       ((RegWriteM == 1'b1) & (RD_M != 5'h00) & (RD_M == Rs2_E)) ? 2'b10 :
                       ((RegWriteW == 1'b1) & (RD_W != 5'h00) & (RD_W == Rs2_E)) ? 2'b01 : 2'b00;

    // Stalling for load-use hazard
    wire lwStall;
    assign lwStall = ResultSrcE_0 && ((RS1D == RDE) || (RS2D == RDE));
    assign StallF = lwStall;
    assign StallD = lwStall;

    // Flushing for branch/jump
    assign FlushD = PCSrcE;
    assign FlushE = lwStall || PCSrcE;
endmodule