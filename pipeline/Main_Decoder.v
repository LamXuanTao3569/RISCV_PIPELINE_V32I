/*module Main_Decoder(Op,RegWrite,ImmSrc,ALUSrc,MemWrite,ResultSrc,Branch,ALUOp);
    input [6:0]Op;
    output RegWrite,ALUSrc,MemWrite,ResultSrc,Branch;
    output [1:0]ImmSrc,ALUOp;

    assign RegWrite = (Op == 7'b0000011 | Op == 7'b0110011 | Op == 7'b0010011 ) ? 1'b1 :
                                                              1'b0 ;
    assign ImmSrc = (Op == 7'b0100011) ? 2'b01 : 
                    (Op == 7'b1100011) ? 2'b10 :    
                                         2'b00 ;
    assign ALUSrc = (Op == 7'b0000011 | Op == 7'b0100011 | Op == 7'b0010011) ? 1'b1 :
                                                            1'b0 ;
    assign MemWrite = (Op == 7'b0100011) ? 1'b1 :
                                           1'b0 ;
    assign ResultSrc = (Op == 7'b0000011) ? 1'b1 :
                                            1'b0 ;
    assign Branch = (Op == 7'b1100011) ? 1'b1 :
                                         1'b0 ;
    assign ALUOp = (Op == 7'b0110011) ? 2'b10 :
                   (Op == 7'b1100011) ? 2'b01 :
                                        2'b00 ;

endmodule
*/
module Main_Decoder (
    input [6:0] Op,
    output RegWrite, ALUSrc, MemWrite, Branch, Jump,
    output [1:0] ALUOp, 
	 output [1:0] ResultSrc,
    output [2:0] ImmSrc
);
    assign {RegWrite, ALUSrc, MemWrite, ResultSrc, Branch, Jump, ALUOp, ImmSrc} =
        (Op == 7'b0110011) ? {1'b1, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 2'b10, 3'bxxx} : // R-type
        (Op == 7'b0010011) ? {1'b1, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 2'b10, 3'b000} : // I-type (ADDI, etc.)
        (Op == 7'b0000011) ? {1'b1, 1'b1, 1'b0, 2'b01, 1'b0, 1'b0, 2'b00, 3'b000} : // Load (LW)
        (Op == 7'b0100011) ? {1'b0, 1'b1, 1'b1, 2'bxx, 1'b0, 1'b0, 2'b00, 3'b001} : // Store (SW)
        (Op == 7'b1100011) ? {1'b0, 1'b0, 1'b0, 2'bxx, 1'b1, 1'b0, 2'b01, 3'b010} : // Branch (BEQ)
        (Op == 7'b1101111) ? {1'b1, 1'bx, 1'b0, 2'b10, 1'b0, 1'b1, 2'b00, 3'b011} : // JAL
        (Op == 7'b1100111) ? {1'b1, 1'b1, 1'b0, 2'b10, 1'b0, 1'b1, 2'b00, 3'b000} : // JALR
        (Op == 7'b0110111) ? {1'b1, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 2'b00, 3'b100} : // LUI
        (Op == 7'b0010111) ? {1'b1, 1'b1, 1'b0, 2'b00, 1'b0, 1'b0, 2'b00, 3'b100} : // AUIPC
        {1'b0, 1'b0, 1'b0, 2'b00, 1'b0, 1'b0, 2'b00, 3'b000};
endmodule