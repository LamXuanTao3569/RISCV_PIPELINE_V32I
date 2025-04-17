module alu (
    input  wire [31:0] a, b,
    input  wire [2:0]  control,
    output wire [31:0] result
);
    reg [31:0] res;
    always @(*) begin
        case (control)
            3'b000: res = a + b;
            default: res = a + b;
        endcase
    end
    assign result = res;
endmodule