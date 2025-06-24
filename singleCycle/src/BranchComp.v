module BranchComp(
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic BrUn,
    output logic BrEq,
    output logic BrLT
);
    assign BrEq = (A == B);
    assign BrLT = BrUn ? (A < B) : ($signed(A) < $signed(B));
endmodule 